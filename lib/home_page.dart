// home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

// Import screens and router
import 'sign_in_screen.dart';
import 'role_based_router.dart'; // 👈 NEW IMPORT

// UI imports for the StudentHomePage part
import '../screens/feedbackScreen.dart';
import '../screens/notifications_page.dart';
import '../screens/profile_screen.dart';
import '../screens/program_list_screen.dart';

// =========================================================================
// 🔑 AUTHENTICATION WRAPPER (Handles login state and routes to RoleChecker)
// =========================================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user;
  late final StreamSubscription<User?> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed out successfully! 👋')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      // 1. Not logged in: show sign-in screen
      return const SignInScreen();
    } else {
      // 2. Logged in: Route to the Role Checker
      return RoleBasedRouter(user: _user!);
    }
  }
}


// =========================================================================
// 🏠 STUDENT DASHBOARD UI (Accepts User object)
// =========================================================================

class StudentHomePage extends StatelessWidget {
  // 👈 REQUIRED USER OBJECT
  final User user;
  const StudentHomePage({super.key, required this.user});

  Widget _buildHomeCard(BuildContext context,
      {required String title,
        required IconData icon,
        required Color color,
        required VoidCallback onTap}) {
    // ... (Your existing _buildHomeCard implementation)
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: color,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 40),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use the passed 'user' object for display name and sign out logic
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'EduXcel Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.account_circle, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
          ),
          // We need a way to sign out from the StudentHomePage,
          // but _signOut is in the State object of HomePage.
          // For simplicity here, we'll keep the navigation, but in a real app,
          // you'd pass a sign-out callback or use a Provider/Bloc.
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              // Note: This sign-out relies on the fact that HomePage
              // is still in the widget tree and will rebuild on auth state change.
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7B1FA2), Color(0xFF9C27B0), Color(0xFFBA68C8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 120, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome Back, ${user.displayName ?? user.email!.split('@')[0]} 👋",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Continue learning with EduXcel",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  children: [
                    _buildHomeCard(
                      context,
                      title: "My Courses",
                      icon: Icons.school,
                      color: Colors.deepPurple.shade400,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProgramListScreen()),
                      ),
                    ),
                    _buildHomeCard(
                      context,
                      title: "Profile",
                      icon: Icons.person,
                      color: Colors.purple.shade600,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfileScreen()),
                      ),
                    ),
                    _buildHomeCard(
                      context,
                      title: "Notifications",
                      icon: Icons.notifications_active,
                      color: Colors.purple.shade700,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NotificationsPage()),
                      ),
                    ),
                    _buildHomeCard(
                      context,
                      title: "Feedback",
                      icon: Icons.feedback_rounded,
                      color: Colors.deepPurple.shade600,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FeedbackPage()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}