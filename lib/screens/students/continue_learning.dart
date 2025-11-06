import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '/screens/details.dart'; // <-- where DetailsPage & Course are
import 'package:eduxcel/models/course.dart';

class ContinueLearningPage extends StatefulWidget {
  const ContinueLearningPage({super.key});

  @override
  State<ContinueLearningPage> createState() => _ContinueLearningPageState();
}

class _ContinueLearningPageState extends State<ContinueLearningPage> {
  List<dynamic> _programs = [];
  bool _isLoading = true;

  Future<void> _loadPrograms() async {
    try {
      final String response = await rootBundle.loadString('assets/data/programs.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        _programs = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load programs: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final background = theme.colorScheme.background;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Continue Learning'),
        backgroundColor: primary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _programs.isEmpty
          ? const Center(child: Text('No programs found.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _programs.length,
        itemBuilder: (context, index) {
          final program = _programs[index];
          final title = program['title'] ?? 'Untitled Program';
          final desc = program['description'] ?? '';
          final instructor = program['instructor'] ?? 'Unknown';
          final chapters = program['chapters'] ?? 0;
          final progress = (Random().nextInt(60) + 20) / 100; // 20–80%

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: primary.withOpacity(0.12)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                // ✅ Create a Course object and navigate to DetailsPage
                final course = Course(
                  title: title,
                  description: desc,
                  chapters: chapters,
                  instructor: instructor,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailsPage(course: course),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      desc,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: primary),
                        const SizedBox(width: 4),
                        Text(instructor,
                            style: const TextStyle(fontSize: 12)),
                        const Spacer(),
                        Icon(Icons.menu_book, size: 16, color: primary),
                        const SizedBox(width: 4),
                        Text('$chapters chapters',
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: primary.withOpacity(0.15),
                        color: primary,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}% completed',
                      style: TextStyle(
                        color: theme.colorScheme.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
