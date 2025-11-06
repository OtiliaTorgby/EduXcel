//admin_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Import your pages
import '/screens/students/notifications_page.dart';
import 'learners_page.dart';
import 'programs_page.dart';
import 'stats_page.dart';
import 'settings_page.dart';
import 'new_programs_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  // Bottom nav logic
  void _onNavBarTap(int idx) async {
    if (idx == 4) {
      // Sign out
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed out!'),
            backgroundColor: Colors.deepPurple,
          ),
        );
      }
    } else {
      switch (idx) {
        case 0: // Dashboard
        // Already here
          break;
        case 1: // Settings
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminSettingsPage()),
          );
          break;
        case 2: // Programs
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProgramsPage()),
          );
          break;
        case 3: // Stats
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StatsPage()),
          );
          break;
      }
      setState(() => _selectedIndex = idx);
    }
  }

  void _showCreateProgramDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        String programName = '';
        return AlertDialog(
          title: const Text('Create New Program'),
          content: TextField(
            decoration: const InputDecoration(
              labelText: 'Program Name',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => programName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Program "$programName" created (not persisted yet)'),
                    backgroundColor: Colors.deepPurple,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Drawer menu item with navigation
  ListTile _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      onTap: () {
        Navigator.pop(context);
        switch (title) {
          case 'Dashboard':
            break; // Already on dashboard
          case 'Programs':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgramsPage()));
            break;
          case 'Learners':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LearnersPage()));
            break;
          case 'Settings':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSettingsPage()));
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 160,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7B1FA2), Color(0xFFBA68C8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const DrawerHeader(
                decoration: BoxDecoration(color: Colors.transparent),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Admin Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
            _buildMenuItem(Icons.dashboard, 'Dashboard'),
            _buildMenuItem(Icons.school, 'Programs'),
            _buildMenuItem(Icons.people, 'Learners'),
            _buildMenuItem(Icons.settings, 'Settings'),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.purple[300],
        elevation: 3,
        title: Row(
          children: const [
            Icon(Icons.shield_moon, color: Colors.white, size: 26),
            SizedBox(width: 4),
            Text('Admin Dashboard'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            color: Colors.white,
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsPage(role: 'admin')),
              );
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEDE7F6), Color(0xFFF8BBD0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B1FA2), Color(0xFFBA68C8)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                margin: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Welcome, Admin!',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Manage programs & communications',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.admin_panel_settings,
                          size: 28, color: Color(0xFF7B1FA2)),
                    ),
                  ],
                ),
              ),
              const Text(
                'EduXcel Overview',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _DashboardCard(
                    title: 'Active Learners',
                    icon: Icons.people,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LearnersPage()),
                    ),
                  ),
                  const SizedBox(width: 14),
                  _DashboardCard(
                    title: 'Engagement',
                    icon: Icons.bar_chart,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StatsPage()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _DashboardCard(
                    title: 'Active Programs',
                    icon: Icons.list_alt,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProgramsPage()),
                    ),
                  ),
                  const SizedBox(width: 14),
                  _DashboardCard(
                    title: 'Rate of Completion',
                    icon: Icons.show_chart,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StatsPage()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateProgramPage()),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  label: const Text(
                    'Create New Program',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 17),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onNavBarTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Programs'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.logout, color: Colors.red), label: 'Sign Out'),
        ],
      ),
    );
  }
}

// Dashboard Card Widget
class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          color: Colors.deepPurple.shade50,
          child: Container(
            height: 140,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.deepPurple.shade400),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
