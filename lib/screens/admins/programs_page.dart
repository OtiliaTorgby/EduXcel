import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class ProgramsPage extends StatefulWidget {
  const ProgramsPage({Key? key}) : super(key: key);

  @override
  State<ProgramsPage> createState() => _ProgramsPageState();
}

class _ProgramsPageState extends State<ProgramsPage> {
  List<Map<String, dynamic>> programs = [];

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/programs.json');
      final List<dynamic> data = json.decode(jsonString);

      setState(() {
        // Safely cast to List<Map<String, dynamic>>
        programs = data.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    } catch (e) {
      debugPrint('Error loading programs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Programs Directory'),
      ),
      body: programs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: programs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final program = programs[index];
          final name = program['title'] ?? 'No Name';
          final description = program['description'] ?? 'No Description';
          final instructor = program['instructor'] ?? 'Unknown';
          final enrolled = program['enrolled']?.toString() ?? '0';
          final id = program['id']?.toString() ?? '-';

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
                  name.isNotEmpty ? name[0] : '?',
                  style: const TextStyle(fontSize: 22, color: Colors.white),
                ),
              ),
              title: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Instructor: $instructor'),
                  Text('Description: $description'),
                  Text('Enrolled: $enrolled'),
                ],
              ),
              trailing: Text(
                'ID: $id',
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
