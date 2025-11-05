import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ Real import

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  // Helper function to handle launching the URL asynchronously
  // NOTE: We rely solely on launchUrl and the surrounding try/catch block
  // for error handling, which is the recommended practice for standard
  // http/https links, making the code cleaner.
  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final Uri uri = Uri.parse(urlString);

    try {
      // Attempt to launch the URL directly
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Opens in browser or app
      );

      // Success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening ${urlString.contains('github') ? 'GitHub' : 'Video'} in browser...'),
          duration: const Duration(seconds: 2),
        ),
      );

    } catch (e) {
      // Failure message: This catches any exception thrown by launchUrl
      // (e.g., if no application can handle the URL, or a PlatformException occurs).
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open $urlString. Check device settings (Android Manifest for API 30+) or connection.'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const githubUrl = 'https://github.com/OtiliaTorgby/EduXcel';
    const videoUrl = 'https://www.youtube.com/watch?v=lDYnK-nOmR8'; // Placeholder

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Fallback color
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                // A more vibrant purple gradient
                colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                const Icon(Icons.school, color: Colors.white, size: 100),
                const SizedBox(height: 20),
                const Text(
                  'Welcome to EduXcel',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Learn. Excel. Transform your journey.',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                const SizedBox(height: 40),

                // Description
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    "Empowering learners and administrators to connect, grow, and manage education seamlessly.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white, height: 1.5),
                  ),
                ),

                const Spacer(flex: 3),

                // Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/sign-in'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4A00E0), // Match with gradient
                          minimumSize: const Size(double.infinity, 55),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 10,
                          shadowColor: Colors.black.withOpacity(0.3),
                        ),
                        child: const Text('Get Started'),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => _launchUrl(context, videoUrl),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white, width: 2),
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/youtube.png', height: 36),
                            const SizedBox(width: 12),
                            const Text('Demo Video', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      OutlinedButton(
                        onPressed: () => _launchUrl(context, githubUrl),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white, width: 2),
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/github.png', height: 36),
                            const SizedBox(width: 12),
                            const Text('GitHub Repository', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
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
