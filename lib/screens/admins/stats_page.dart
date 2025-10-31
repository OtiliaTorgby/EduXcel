import 'package:flutter/material.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({Key? key}) : super(key: key);

  // Sample data
  final int totalLearners = 120;
  final int totalPrograms = 8;
  final double averageCompletion = 76; // percent

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'EduXcel Stats Overview',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Row 1: Total Learners & Programs
              Row(
                children: [
                  Expanded(
                    child: _StatsCard(
                      title: 'Total Learners',
                      value: totalLearners.toString(),
                      icon: Icons.people,
                      color: Colors.deepPurple,
                      // Use default height, do NOT set
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatsCard(
                      title: 'Programs',
                      value: totalPrograms.toString(),
                      icon: Icons.school,
                      color: Colors.purpleAccent,
                      // Use default height, do NOT set
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Row 2: Average Completion (full card, not inside Row)
              _StatsCard(
                title: 'Average Completion',
                value: '$averageCompletion%',
                icon: Icons.bar_chart,
                color: Colors.deepPurple.shade300,
                height: 160, // Only here, since not in Expanded.
              ),
              const SizedBox(height: 20),

              // Additional Insights
              const Text(
                'Additional Insights',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'You can add pie charts, line charts, or progress indicators here '
                    'to show learner engagement, program performance, and completion trends.',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

// Stats Card Widget
class _StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double? height; // Make height nullable

  const _StatsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: color.withOpacity(0.2),
      child: Container(
        height: height,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
