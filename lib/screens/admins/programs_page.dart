import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'new_programs_page.dart';

// Define a Program model class for better type safety
class Program {
  final String id;
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

  factory Program.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Program(
      id: doc.id,
      title: data['title'] ?? 'No Name',
      description: data['description'] ?? 'No Description',
      instructor: data['instructor'] ?? 'Unknown',
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

  // Collection reference based on your suggested path: /artifacts/eduxcel/courses
  final CollectionReference coursesCollection =
  FirebaseFirestore.instance.collection('artifacts').doc('eduxcel').collection('courses');

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }


  Future<void> _loadPrograms() async {
    try {
      final QuerySnapshot snapshot = await coursesCollection.get();

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
    }
  }

  void _navigateToCreateProgram() async {
    final bool? shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateProgramPage()),
    );

    if (shouldRefresh == true) {
      setState(() {
        isLoading = true;
      });
      _loadPrograms();
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
      // ⭐ UPDATED Floating Action Button for better visibility and appeal
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
        child: FloatingActionButton.extended(
          onPressed: _navigateToCreateProgram,
          // Use a custom shape and styling for a more appealing button
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Increased roundness
          ),
          backgroundColor: Colors.deepPurple.shade700, // Slightly darker, richer color
          foregroundColor: Colors.white,
          elevation: 8, // Higher elevation for better shadow/prominence

          icon: const Icon(Icons.add_circle, size: 26), // Bigger icon
          label: const Text(
            'Create New Program', // More descriptive text
            style: TextStyle(
              fontSize: 16, // Larger text
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}