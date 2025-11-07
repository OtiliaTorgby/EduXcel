import 'package:flutter/material.dart';
// New Import for Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
// No need for 'dart:convert' or 'rootBundle' anymore

// Define a Program model class for better type safety
class Program {
  final String id; // Firestore document ID is a String
  final String title;
  final String description;
  final String instructor;
  final int users;

  Program({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.users,
  });

  // Factory constructor to create a Program from a Firestore DocumentSnapshot
  factory Program.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Program(
      id: doc.id, // Use the document ID for the Program ID
      title: data['title'] ?? 'No Name',
      description: data['description'] ?? 'No Description',
      instructor: data['instructor'] ?? 'Unknown',
      // Safely convert 'enrolled' to int. Firestore often stores numbers as 'num'
      users: (data['users'] as num?)?.toInt() ?? 0,
    );
  }
}

class ProgramsPage extends StatefulWidget {
  const ProgramsPage({super.key});

  @override
  State<ProgramsPage> createState() => _ProgramsPageState();
}

class _ProgramsPageState extends State<ProgramsPage> {
  List<Program> programs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Ensure Firebase is initialized before calling _loadPrograms in main.dart
    _loadPrograms();
  }

  // Collection reference based on your suggested path: /artifacts/eduxcel/courses
  final CollectionReference coursesCollection =
  FirebaseFirestore.instance.collection('artifacts').doc('eduxcel').collection('courses');


  Future<void> _loadPrograms() async {
    try {
      // 1. Fetch data from the Firestore collection
      final QuerySnapshot snapshot = await coursesCollection.get();

      // 2. Convert the documents into a list of Program objects
      final List<Program> fetchedPrograms = snapshot.docs.map((doc) {
        return Program.fromFirestore(doc);
      }).toList();

      setState(() {
        programs = fetchedPrograms;
        isLoading = false;
      });

    } catch (e) {
      debugPrint('Error loading programs from Firestore: $e');
      setState(() {
        isLoading = false;
      });
      // Optionally show a user-friendly error message here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Programs Directory'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : programs.isEmpty
          ? const Center(child: Text('No programs found.'))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: programs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final program = programs[index];

          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade200,
                child: Text(
                  program.title.isNotEmpty ? program.title[0] : '?',
                  style: const TextStyle(fontSize: 22, color: Colors.white),
                ),
              ),
              title: Text(
                program.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Instructor: ${program.instructor}'),
                  Text('Description: ${program.description}'),
                  Text('Enrolled: ${program.users}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}