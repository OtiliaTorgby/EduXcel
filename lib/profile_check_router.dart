import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import necessary files
import 'role_based_router.dart';
import 'screens/complete_profile_screen.dart';

// Global app ID variable
const String __app_id = 'eduxcel';

class ProfileCheckRouter extends StatelessWidget {
  final User user;
  const ProfileCheckRouter({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // 1. Define the Firestore path for the user's profile document
    final userProfileDocRef = FirebaseFirestore.instance
        .collection('artifacts')
        .doc(__app_id)
        .collection('users')
        .doc(user.uid);

    // 2. Use a StreamBuilder to listen for changes to the user's profile document
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userProfileDocRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a simple loading indicator while waiting for the first snapshot
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error loading profile: ${snapshot.error}')),
          );
        }

        // Get the data from the snapshot
        final userData = snapshot.data?.data();

        // Check the 'profileComplete' flag (must be explicitly true)
        final bool isProfileComplete = userData?['profileComplete'] == true;

        if (isProfileComplete) {
          // If profile is complete, proceed to the next layer (RoleBasedRouter)
          return RoleBasedRouter(user: user);
        } else {
          // If profile is incomplete (or document is missing), show the completion screen
          return const CompleteProfileScreen();
        }
      },
    );
  }
}
