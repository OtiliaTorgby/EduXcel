import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

// Import screens and router
import '../sign_in_screen.dart';
import '../role_based_router.dart';
import 'package:eduxcel/profile_check_router.dart';

// UI imports for the StudentHomePage part
import '../../screens/feedbackScreen.dart';
import '../../screens/notifications_page.dart';
import '../../screens/profile_screen.dart';
import 'students/program_list_screen.dart';

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
      return const SignInScreen();
    } else {
      // Use the ProfileCheckRouter as the next step after successful login
      return ProfileCheckRouter(user: _user!);
    }
  }
}

// --------------------------------------------------------------
// Redesigned StudentHomePage
// --------------------------------------------------------------

class StudentHomePage extends StatelessWidget {
  final User user;
  const StudentHomePage({super.key, required this.user});

  String _displayName() {
    if (user.displayName?.isNotEmpty == true) {
      return user.displayName!.split(' ')[0];
    }
    return user.email!.split('@')[0];
  }

  Widget _featureChip({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15), // Slightly increased opacity for better visibility
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(BuildContext context,
      {required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      // Themed Border
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: primaryColor.withOpacity(0.15), width: 1.5),
      ),
      elevation: 2, // Reduced elevation for a modern look
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                // Themed CircleAvatar background
                backgroundColor: primaryColor.withOpacity(0.1),
                child: Icon(icon, size: 28, color: primaryColor), // Themed Icon color
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black45)
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = _displayName();
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: Colors.white, // Changed from light gray to pure white for better contrast
      body: SafeArea(
        child: Column(
          children: [
            // Hero header (Deeper Gradient)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  // Deeper, richer violet gradient
                  colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32), // Increased curve
                  bottomRight: Radius.circular(32), // Increased curve
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                            child: CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              child: const Icon(Icons.person, color: Colors.white, size: 28),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Hello, $name', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              const Text('Continue your learning journey', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage(role: 'student'))),
                            icon: const Icon(Icons.notifications_none, color: Colors.white),
                          ),
                          IconButton(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              await GoogleSignIn().signOut();
                            },
                            icon: const Icon(Icons.logout, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Bar (Added subtle shadow for depth)
                  Container(
                    margin: const EdgeInsets.only(top: 6, bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.search, color: Colors.black54),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search courses, topics, or instructors',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Horizontal quick features
                  SizedBox(
                    height: 54,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _featureChip(icon: Icons.school, label: 'My Courses', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgramListScreen()))),
                        _featureChip(icon: Icons.play_circle, label: 'Continue Learning', onTap: () {}),
                        _featureChip(icon: Icons.calendar_today, label: 'Schedule', onTap: () {}),
                        _featureChip(icon: Icons.star, label: 'Achievements', onTap: () {}),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      // Large vertical action cards (uses themed _actionCard)
                      _actionCard(
                        context,
                        title: 'My Courses',
                        subtitle: 'View and resume courses you are enrolled in',
                        icon: Icons.school,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgramListScreen())),
                      ),

                      _actionCard(
                        context,
                        title: 'Send Feedback',
                        subtitle: 'Share feedback to help us improve EduXcel',
                        icon: Icons.rate_review,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackPage())),
                      ),

                      _actionCard(
                        context,
                        title: 'Notifications',
                        subtitle: 'See the latest announcements and messages',
                        icon: Icons.campaign,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage(role:'student'))),
                      ),

                      // Promotional / info card (Thematic coloring applied)
                      Card(
                        // Themed border
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: primaryColor.withOpacity(0.3), width: 1.5),
                        ),
                        // Light purple background tint
                        color: primaryColor.withOpacity(0.03),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('New Program: Design Thinking', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                                    const SizedBox(height: 6),
                                    Text('Enroll now to learn practical problem solving techniques and projects.', style: TextStyle(color: secondaryColor)),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  // Themed button color
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Explore'),
                              )
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Text('Settings & Support', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      _actionCard(
                        context,
                        title: 'Profile Settings',
                        subtitle: 'Update personal details and preferences',
                        icon: Icons.person_pin,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                      ),

                      _actionCard(
                        context,
                        title: 'Sign Out',
                        subtitle: 'Sign out from your account on this device',
                        icon: Icons.logout,
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          await GoogleSignIn().signOut();
                        },
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgramListScreen())),
        // Themed FAB
        backgroundColor: primaryColor,
        label: const Text('Start Learning', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.play_arrow, color: Colors.white),
      ),
    );
  }
}