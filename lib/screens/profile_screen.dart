import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FB),
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: const Color(0xFF673AB7),
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: user == null
          ? const Center(
        child: Text(
          'User not signed in.',
          style: TextStyle(color: Colors.black54, fontSize: 18),
        ),
      )
          : SingleChildScrollView(child: ProfileBody(user: user)),
    );
  }
}

class ProfileBody extends StatelessWidget {
  final User user;
  const ProfileBody({super.key, required this.user});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF673AB7);
    const lightPurple = Color(0xFFD1C4E9);

    final String displayName = user.displayName ?? user.email?.split('@')[0] ?? 'User';
    const String fallbackImageUrl = 'https://www.gravatar.com/avatar?d=mp';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile avatar with a subtle accent border
          CircleAvatar(
            radius: 55,
            backgroundColor: lightPurple,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(user.photoURL ?? fallbackImageUrl),
              onBackgroundImageError: (_, __) {},
            ),
          ),
          const SizedBox(height: 12),
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            user.email ?? '',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 25),

          // Info Cards (white with subtle shadows)
          _buildInfoCard(
            icon: Icons.person_outline,
            label: 'Name',
            value: displayName,
          ),
          const SizedBox(height: 10),
          _buildInfoCard(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user.email ?? 'N/A',
          ),

          const SizedBox(height: 25),

          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.lock_outline),
            label: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w600)),
          ),

          const SizedBox(height: 35),

          // Certificates header
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Certificates',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.grey[800],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Certificates scroll (lighter purple tone)
          SizedBox(
            height: 130,
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

          const SizedBox(height: 35),

          // Action rows
          _buildActionRow(
            icon: Icons.logout,
            label: 'Sign Out',
            onTap: () => _signOut(context),
            color: Colors.redAccent,
          ),
          const SizedBox(height: 16),
          _buildActionRow(
            icon: Icons.dark_mode_outlined,
            label: 'Toggle Dark/Light Mode',
            onTap: () {},
            color: primary,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF673AB7)),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black45),
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
      width: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFB39DDB), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.workspace_premium, size: 38, color: Color(0xFF673AB7)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
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
