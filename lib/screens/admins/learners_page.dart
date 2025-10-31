import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class LearnersPage extends StatefulWidget {
  const LearnersPage({Key? key}) : super(key: key);

  @override
  State<LearnersPage> createState() => _LearnersPageState();
}

class _LearnersPageState extends State<LearnersPage> {
  List<Map<String, dynamic>> learners = [];

  @override
  void initState() {
    super.initState();
    _loadLearners();
  }

  Future<void> _loadLearners() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/learners.json');
      final List<dynamic> data = json.decode(jsonString);
      setState(() {
        learners = data.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      debugPrint('Error loading learners: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
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
        child: learners.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: learners.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final learner = learners[index];
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple.shade200,
                  child: Text(
                    learner['name'][0].toUpperCase(),
                    style: const TextStyle(
                        fontSize: 22, color: Colors.white),
                  ),
                ),
                title: Text(
                  learner['name'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${learner['email']}'),
                      Text('Programme: ${learner['programme']}'),
                      Text('Joined: ${learner['joined']}'),
                    ],
                  ),
                ),
                trailing: Text(
                  'ID: ${learner['id']}',
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
