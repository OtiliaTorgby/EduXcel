import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/details.dart';

class ProgramListScreen extends StatefulWidget {
  const ProgramListScreen({super.key});

  @override
  State<ProgramListScreen> createState() => _ProgramListScreenState();
}

class _ProgramListScreenState extends State<ProgramListScreen> {
  List<dynamic> programs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  /// Load mock program data from JSON file
  Future<void> _loadPrograms() async {
    try {
      final String response = await rootBundle.loadString('assets/data/programs.json');
      final data = json.decode(response);
      setState(() {
        programs = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('❌ Error loading programs: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load programs: $e')),
      );
    }
  }


  /// Simulate refresh to mimic API
  Future<void> _refreshPrograms() async {
    await Future.delayed(const Duration(seconds: 1));
    await _loadPrograms();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Programs updated!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "Available Programs",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7B1FA2), Color(0xFF9C27B0), Color(0xFFBA68C8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Colors.white),
        )
            : RefreshIndicator(
          onRefresh: _refreshPrograms,
          color: Colors.white,
          backgroundColor: Colors.purpleAccent,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 100, bottom: 20),
            itemCount: programs.length,
            itemBuilder: (context, index) {
              final program = programs[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Card(
                  color: Colors.white.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF8E24AA),
                      child: Text(
                        program['title'][0],
                        style: const TextStyle(
                            color: Colors.white, fontSize: 20),
                      ),
                    ),
                    title: Text(
                      program['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A148C),
                      ),
                    ),
                    subtitle: Text(
                      program['description'],
                      style: const TextStyle(color: Colors.black87),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded,
                          color: Color(0xFF7B1FA2)),
                      onPressed: () {
                        final course = Course(
                          title: program['title'],
                          description: program['description'],
                          chapters: program['chapters'] ?? 10, // fallback value
                          instructor: program['instructor'] ?? "Unknown Instructor",
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsPage(course: course),
                          ),
                        );
                      },

                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

