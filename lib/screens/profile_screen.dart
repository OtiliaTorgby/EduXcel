import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // For sign out action

// Assume this is where the Firebase user data is being fetched.
// To make this screen work, we'll fetch the current user.

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Get the current authenticated user (guaranteed to be non-null if navigated from HomePage)
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A148C)), // Using Deep Purple equivalent
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: const Color(0xFF4A148C),
          fontWeight: FontWeight.bold,
        ),
      ),
      // 2. Pass the user object to the body
      body: user == null
          ? const Center(child: Text('User not signed in.'))
          : SingleChildScrollView(child: ProfileBody(user: user)),
    );
  }
}

class ProfileBody extends StatelessWidget {
  final User user;
  const ProfileBody({super.key, required this.user});

  // Function to handle sign out
  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();

    // Navigate back to the sign-in screen by pushing the root route
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the theme colors for a consistent purple aesthetic
    final Color primaryColor = const Color(0xFF7B1FA2);

    // Fallback for display name
    final String displayName = user.displayName ?? user.email?.split('@')[0] ?? 'User';
    const String fallbackImageUrl = 'https://www.gravatar.com/avatar?d=mp';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          CircleAvatar(
            radius: 50,
            backgroundColor: primaryColor.withOpacity(0.1),
            // Use a child widget to handle network image loading and errors
            child: ClipOval(
              child: SizedBox(
                width: 100, // 2 * radius
                height: 100, // 2 * radius
                child: Image.network(
                  user.photoURL ?? fallbackImageUrl, // Use the user photo or a fallback
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    // Show a circular indicator while the image is loading
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    // 🛑 If the photoURL is invalid or loading fails, show the fallback icon
                    debugPrint('Profile photo loading failed: $error');
                    return Icon(
                      Icons.person,
                      size: 60,
                      color: primaryColor,
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              // TODO: Implement image selection and upload logic
            },
            child: Text(
              'Change Profile Picture',
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 20),

          // --- User Info Cards ---
          _buildInfoCard(
              context,
              icon: Icons.person_outline,
              label: 'Name',
              value: displayName,
              color: primaryColor
          ),
          const SizedBox(height: 10),
          _buildInfoCard(
              context,
              icon: Icons.email_outlined,
              label: 'Email',
              value: user.email ?? 'N/A',
              color: primaryColor
          ),
          const SizedBox(height: 20),

          // --- Action Button ---
          OutlinedButton(
            onPressed: () {
              // TODO: Implement password change dialog/screen
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: BorderSide(color: primaryColor),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Change Password'),
          ),

          // --- Certificates Section ---
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Certificates',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: primaryColor
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                CertificateCard(title: 'Java Beginner'),
                CertificateCard(title: 'LLMs'),
                CertificateCard(title: 'Prompting'),
                CertificateCard(title: 'Security Basics'),
                CertificateCard(title: 'Data Science'),
              ],
            ),
          ),

          // --- Bottom Actions ---
          const SizedBox(height: 40),
          _buildActionRow(
              context,
              icon: Icons.logout,
              label: 'Sign out',
              onTap: () => _signOut(context),
              color: primaryColor
          ),
          const SizedBox(height: 20),
          _buildActionRow(
              context,
              icon: Icons.dark_mode,
              label: 'Dark/Light Mode',
              onTap: () {
                // TODO: Implement theme toggle logic
              },
              color: primaryColor
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Helper Widget for structured info display
  Widget _buildInfoCard(BuildContext context, {required IconData icon, required String label, required String value, required Color color}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: color.withOpacity(0.8)
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                      color: Colors.black87
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for bottom actions
  Widget _buildActionRow(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap, required Color color}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 15),
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class CertificateCard extends StatelessWidget {
  final String title;
  const CertificateCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 120, // Increased width slightly
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.workspace_premium, size: 40, color: Colors.amber),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}