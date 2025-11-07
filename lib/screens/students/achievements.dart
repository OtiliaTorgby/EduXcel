import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../screens/profile_screen.dart'; // Import CertificateCard

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final primaryColor = const Color(0xFF7B1FA2);

    // Example user certificates — later you can fetch these dynamically.
    final List<String> certificates = [
      'Java Beginner',
      'Prompt Engineering',
      'Cyber Security Basics',
      'Mobile App Development',
      'Database Systems',
      'Web Development',
      'Machine Learning',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      appBar: AppBar(
        title: const Text('Achievements'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A148C)),
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
      body: user == null
          ? const Center(child: Text('User not signed in.'))
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Certificates',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),

            // ✅ Grid of certificates
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(top: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: certificates.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Later: show enlarged certificate or share option
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Viewing ${certificates[index]} certificate'),
                        ),
                      );
                    },
                    child: CertificateCard(title: certificates[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
