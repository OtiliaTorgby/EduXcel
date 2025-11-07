// home_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Keep your existing screen imports
import '../sign_in_screen.dart';
import 'package:eduxcel/profile_check_router.dart';

import '../../screens/feedbackScreen.dart';
import '../../screens/notifications_page.dart';
import '../../screens/profile_screen.dart';
import 'students/program_list_screen.dart';
import 'students/continue_learning.dart';
import 'students/achievements.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder reacts to auth changes and avoids manual subscription management.
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) return const SignInScreen();
        return ProfileCheckRouter(user: user);
      },
    );
  }
}

// ---------------------- Refined StudentHomePage ----------------------

class StudentHomePage extends StatelessWidget {
  final User user;
  const StudentHomePage({super.key, required this.user});

  String _displayName() {
    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      // return the first token of the display name
      return displayName.split(' ')[0];
    }
    // fallback to email local-part or generic label
    return user.email?.split('@')[0] ?? 'Learner';
  }

  // reusable action card
  Widget _actionCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required VoidCallback onTap,
        bool dense = false,
      }) {
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: primary.withOpacity(0.12)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: dense ? 12 : 16, horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: dense ? 22 : 28,
                backgroundColor: primary.withOpacity(0.12),
                child: Icon(icon, color: primary, size: dense ? 20 : 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.black54, fontSize: dense ? 12 : 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black45),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    // sign out from Firebase and Google (if used)
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed out successfully!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _displayName();
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;

    // Measurements for adjusting bottom padding to avoid FAB overlap:
    const double fabHeight = 56.0; // standard FAB size (use 56 for default)
    const double fabBottomMargin = 16.0;
    final double extraBottomPadding = fabHeight + fabBottomMargin + MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Explore Programs',
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgramListScreen())),
        child: const Icon(Icons.school),
      ),
      body: CustomScrollView(
        slivers: [
          // Collapsible header with gradient and actions
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: primary,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(3), bottomRight: Radius.circular(3)),
                ),
                padding: const EdgeInsets.fromLTRB(18, 36, 18, 16),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // top row: profile avatar + name + icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Content that includes Avatar and Text
                          Row(
                            children: [
                              InkWell(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                                borderRadius: BorderRadius.circular(32),
                                child: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.white.withOpacity(0.18),
                                  child: const Icon(Icons.person, color: Colors.white, size: 28),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Wrap the Column in Expanded to prevent horizontal overflow
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.45,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Hello, $name', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                                    const SizedBox(height: 4),
                                    const Text('Welcome back to your learning dashboard', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // Icon buttons on the right
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage(role: 'student'))),
                                icon: const Icon(Icons.notifications_none, color: Colors.white),
                                tooltip: 'Notifications',
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main content area with dynamic bottom padding to prevent FAB overlap
          SliverPadding(
            padding: EdgeInsets.fromLTRB(18, 14, 18, extraBottomPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  const SizedBox(height: 6),
                  const Text('Quick Access', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // Core navigation tiles (restored)
                  _actionCard(
                    context,
                    title: 'Courses',
                    subtitle: 'View available programs and enroll',
                    icon: Icons.school,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgramListScreen())),
                  ),

                  _actionCard(
                    context,
                    title: 'Continue Learning',
                    subtitle: 'Resume your last activity instantly',
                    icon: Icons.play_circle,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContinueLearningPage())),
                  ),

                  _actionCard(
                    context,
                    title: 'View Achievements',
                    subtitle: 'Track your badges, certificates, and progress',
                    icon: Icons.star,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsPage())),
                  ),

                  _actionCard(
                    context,
                    title: 'Send Feedback',
                    subtitle: 'Share feedback to help us improve EduXcel',
                    icon: Icons.rate_review,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackPage())),
                  ),



                  const SizedBox(height: 18),
                  const Text('Support & Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // Settings and Support Tiles
                  _actionCard(
                    context,
                    title: 'Profile Settings',
                    subtitle: 'Update personal details and preferences',
                    icon: Icons.person_pin,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                  ),

                  _actionCard(
                    context,
                    title: 'Help & Support',
                    subtitle: 'Get answers to common questions or contact us',
                    icon: Icons.support_agent,
                    onTap: () {
                      // TODO: Implement navigation to a Help/FAQ screen
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navigating to Help & Support...')));
                      }
                    },
                  ),

                  _actionCard(
                    context,
                    title: 'Sign Out',
                    subtitle: 'Sign out from your account on this device. Bye bye.',
                    icon: Icons.logout,
                    onTap: () async => _signOut(context),
                    dense: true,
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}