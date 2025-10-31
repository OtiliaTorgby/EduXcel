// role_based_router.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/admins/admin_page.dart';
import 'screens/home_page.dart'; // Contains StudentHomePage logic

// Base collection path
const String _baseCollectionPath = 'artifacts/eduxcel/users';

class RoleBasedRouter extends StatelessWidget {
  final User user;
  const RoleBasedRouter({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // 🚨 We are now specifically targeting the document in the 'profiles' subcollection.
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection(_baseCollectionPath)
          .doc(user.uid)
          .collection('profiles') // 👈 Step into the subcollection
          .doc(user.uid)           // 👈 Target the document with the UID
          .snapshots(),
      builder: (context, snapshot) {

        // 1. Waiting/Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Error State
        if (snapshot.hasError) {
          // Log the error for debugging
          debugPrint('Firestore Error: ${snapshot.error}');
          return Scaffold(
            body: Center(child: Text('Error loading user role.')),
          );
        }

        // 3. Data Available
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          // Ensure the role is read correctly, defaulting if it's missing
          final role = data['role'] as String? ?? 'Student';

          // Debugging Check
          debugPrint('User Role Found: $role');

          // Role-based Navigation Decision
          if (role == 'Admin') {
            return const AdminPage(); // Redirect to Admin Page
          } else {
            // All other roles (Student, Teacher, etc.) go to the Student Dashboard
            return StudentHomePage(user: user);
          }
        }

        // 4. Document does not exist (This means the profile document hasn't been created yet)
        // Default to the Student Page as a safe fallback.
        debugPrint('Profile document not found. Defaulting to Student.');
        return StudentHomePage(user: user);
      },
    );
  }
}