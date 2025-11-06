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

    // Display string
    final String joinedDisplay = '$joinedDate $joinedTime';
    final Color detailColor = Colors.grey.shade700;


    return Card(
      elevation: 6, // Increased elevation for a floating effect
      shadowColor: primarySwatch.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: primarySwatch.withOpacity(0.1), width: 1), // Subtle border
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to a detailed Learner Profile View
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Viewing details for $name')),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: primarySwatch.shade400, // Slightly darker shade
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              // 2. Info Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 6),
                    // Use RichText for better visual separation of labels and values
                    _buildDetailRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: email,
                      color: detailColor,
                    ),
                    _buildDetailRow(
                      icon: Icons.access_time_filled,
                      label: 'Joined',
                      value: joinedDisplay,
                      color: detailColor,
                    ),
                    _buildDetailRow(
                      icon: Icons.cake_outlined,
                      label: 'DoB',
                      value: dobDate,
                      color: detailColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget for structured detail rows
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color.withOpacity(0.7)),
          const SizedBox(width: 6),
          // Using RichText for key/value distinction
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 13),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black87, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Use a neutral background
      appBar: AppBar(
        // Use a gradient background for a premium look
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        title: const Text('Learners Directory', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
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
    );
  }
}