import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

const String _kLearnersCollection = 'users';

class LearnersPage extends StatefulWidget {
  const LearnersPage({super.key});

  @override
  State<LearnersPage> createState() => _LearnersPageState();
}

class _LearnersPageState extends State<LearnersPage> {
  // Target the specific collection: artifacts/eduxcel/users
  final Stream<QuerySnapshot> _learnersStream = FirebaseFirestore.instance
      .collection('artifacts')
      .doc('eduxcel')
      .collection('users')
      .snapshots();

  // Use the full MaterialColor (the swatch) for shade access
  final MaterialColor primarySwatch = Colors.deepPurple;

  // --- Helper function to safely extract and format DATE (YYYY-MM-DD) ---
  String _formatDate(dynamic field) {
    if (field is Timestamp) {
      return field.toDate().toIso8601String().split('T')[0];
    }
    if (field is String) {
      if (field.contains('T')) {
        return field.split('T')[0];
      }
      return field.split(' ')[0];
    }
    return 'N/A';
  }

  // --- Helper function to safely extract and format TIME (HH:MM:SS) ---
  String _formatTime(dynamic field) {
    String timeString = 'N/A';

    if (field is Timestamp) {
      timeString = field.toDate().toIso8601String().split('T')[1];
    } else if (field is String) {
      if (field.contains('T')) {
        timeString = field.split('T')[1];
      } else if (field.contains(' ')) {
        timeString = field.split(' ')[1];
      }
    }

    // Clean up the time string (remove milliseconds and timezone)
    if (timeString.contains('.')) {
      timeString = timeString.split('.')[0];
    }
    if (timeString.contains('Z')) {
      timeString = timeString.split('Z')[0];
    }

    // Return time if valid, otherwise 'N/A'
    return timeString != 'N/A' ? timeString : 'N/A';
  }


  // --- Helper to build a ListTile from a Firestore DocumentSnapshot ---
  Widget _buildLearnerTile(BuildContext context, DocumentSnapshot document) {
    // Safely cast data
    final learner = document.data()! as Map<String, dynamic>;

    // Extract necessary fields with safe fallbacks
    final String name = learner['displayName'] ?? learner['name'] ?? 'No Name';
    final String email = learner['email'] ?? 'No Email';

    // Format Date and Time fields
    final String joinedDate = _formatDate(learner['createdAt']);
    final String joinedTime = _formatTime(learner['createdAt']);

    final String dobDate = _formatDate(learner['dateOfBirth']);

    // 🎯 Only display time for Joined field, side-by-side
    final String joinedDisplay = '$joinedDate $joinedTime';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: CircleAvatar(
          backgroundColor: primarySwatch.shade200,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(fontSize: 22, color: Colors.white),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: $email'),
              // ✅ Joined: Date and Time displayed in parallel
              Text('Joined: $joinedDisplay'),
              // ✅ DoB: Only Date displayed
              Text('Date of Birth: $dobDate'),
            ],
          ),
        ),
        onTap: () {
          // TODO: Navigate to a detailed Learner Profile View
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Viewing details for $name')),
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primarySwatch,
        foregroundColor: Colors.white,
        title: const Text('Learners Directory'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD1C4E9), // Light Lavender
              Color(0xFFE1BEE7), // Soft Pink-Purple
              Color(0xFFF3E5F5), // Very Light Purple
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _learnersStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error loading data: ${snapshot.error}'));
            }

            final documents = snapshot.data?.docs ?? [];

            if (documents.isEmpty) {
              return const Center(child: Text('No learners found in the database.'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: documents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildLearnerTile(context, documents[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
