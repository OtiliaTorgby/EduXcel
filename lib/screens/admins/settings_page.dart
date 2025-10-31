import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({Key? key}) : super(key: key);

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  bool _darkMode = false;

  Future<void> _signOut() async {
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
  }

  void _showChangePasswordDialog() {
    String oldPassword = '';
    String newPassword = '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Old Password'),
              obscureText: true,
              onChanged: (val) => oldPassword = val,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
              onChanged: (val) => newPassword = val,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Here you can add your Firebase password change logic
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password changed successfully!')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Settings'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD1C4E9), // Light lavender
              Color(0xFFE1BEE7), // Soft pink
              Color(0xFFF3E5F5), // Very light purple
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Section
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 4,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: Icon(Icons.admin_panel_settings, color: Colors.white),
                ),
                title: const Text('Admin Profile'),
                subtitle: const Text('Manage your account settings'),
              ),
            ),
            const SizedBox(height: 16),

            // Change Password
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.lock, color: Colors.deepPurple),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _showChangePasswordDialog,
              ),
            ),
            const SizedBox(height: 16),

            // Notifications
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.notifications, color: Colors.deepPurple),
                title: const Text('Manage Notifications'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to your notifications settings page if needed
                },
              ),
            ),
            const SizedBox(height: 16),

            // Theme Toggle
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 4,
              child: SwitchListTile(
                title: const Text('Dark Mode'),
                secondary: const Icon(Icons.brightness_6, color: Colors.deepPurple),
                value: _darkMode,
                onChanged: (val) {
                  setState(() => _darkMode = val);
                  // Apply theme logic here if using a theme provider
                },
              ),
            ),
            const SizedBox(height: 16),

            // Sign Out
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              color: Colors.red.shade400,
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: _signOut,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
