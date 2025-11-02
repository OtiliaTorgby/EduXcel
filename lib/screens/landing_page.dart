import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ Real import

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  // Helper function to handle launching the URL asynchronously
  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final Uri uri = Uri.parse(urlString);

    try {
      // Check if the device can launch the URL
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // ✅ Opens in browser or app
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening ${urlString.contains('github') ? 'GitHub' : 'Video'} in browser...'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $urlString. Check your device or connection.'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const githubUrl = 'https://github.com/OtiliaTorgby/EduXcel';
    const videoUrl = 'https://youtu.be/xvFZjo5PgG0?list=RDxvFZjo5PgG0'; // Placeholder

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 1),
                const Icon(Icons.school, color: Colors.white, size: 90),
                const SizedBox(height: 20),
                const Text(
                  'Welcome to EduXcel',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Learn. Excel. Transform your journey.',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 30),

                // Description
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: const Text(
                      "Empowering learners and administrators to connect, grow, and manage education seamlessly.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white, height: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/sign-in'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.deepPurple,
                          minimumSize: const Size(double.infinity, 50),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Get Started'),
                      ),
                      const SizedBox(height: 16),

                      OutlinedButton.icon(
                        onPressed: () => _launchUrl(context, videoUrl),
                        icon: const Icon(Icons.ondemand_video),
                        label: const Text('Demo Video'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.deepPurple,
                          side: const BorderSide(color: Colors.white70),
                          minimumSize: const Size(double.infinity, 50),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      OutlinedButton.icon(
                        onPressed: () => _launchUrl(context, githubUrl),
                        icon: const Icon(Icons.code),
                        label: const Text('GitHub Repository'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.deepPurple,
                          side: const BorderSide(color: Colors.white70),
                          minimumSize: const Size(double.infinity, 50),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
