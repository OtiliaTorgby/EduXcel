import 'package:flutter/material.dart';

// Improved Stats Page - keeps purple theme, responsive layout, subtle animations
// Paste this file into your Flutter project (e.g. lib/screens/Improved_StatsPage.dart)

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage>
    with SingleTickerProviderStateMixin {
  // Sample data (could come from an API or provider)
  final int totalLearners = 120;
  final int totalPrograms = 8;
  final double averageCompletion = 76; // percent
  final int activePrograms = 5;
  final int completedPrograms = 3;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    // kick off a small entrance animation
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use MaterialColor so `.shadeXXX` is available
    final MaterialColor primary = Colors.deepPurple;
    final onPrimary = Colors.white;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: AppBar(
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primary.shade900, primary.shade600],
                ),
              ),
              padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
              child: SafeArea(
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.school, size: 28, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'EduXcel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Learner & Program Insights',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
      // Use a subtle background color instead of calling a widget property
      backgroundColor: Colors.grey.shade50,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overview',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),

                // Responsive grid of stat cards
                isWide
                    ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildStatsGrid(primary)),
                    const SizedBox(width: 16),
                    SizedBox(width: 320, child: _buildRightColumn(primary)),
                  ],
                )
                    : Column(
                  children: [
                    _buildStatsGrid(primary),
                    const SizedBox(height: 16),
                    _buildRightColumn(primary),
                  ],
                ),

                const SizedBox(height: 24),

                const Text(
                  'Additional Insights',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Engagement and completion trends can be represented using line charts or sparklines.\nUse cohort retention and weekly active learners to monitor health.',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Tip: Combine quantitative metrics with qualitative feedback for better curriculum decisions.',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36),
              ],
            ),
          );
        }),
      ),
    );
  }

  // accept MaterialColor so .shadeXXX is valid
  Widget _buildStatsGrid(MaterialColor primary) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          title: 'Total Learners',
          value: totalLearners.toString(),
          icon: Icons.people_alt,
          gradient: LinearGradient(colors: [primary.shade800, primary.shade400]),
        ),
        _StatCard(
          title: 'Programs',
          value: totalPrograms.toString(),
          icon: Icons.menu_book,
          gradient: LinearGradient(colors: [Colors.purpleAccent, primary.shade400]),
        ),
        _StatCard(
          title: 'Active Programs',
          value: activePrograms.toString(),
          icon: Icons.play_circle_fill,
          gradient: LinearGradient(colors: [primary.shade700, primary.shade300]),
        ),
        _StatCard(
          title: 'Completed',
          value: completedPrograms.toString(),
          icon: Icons.check_circle,
          gradient: LinearGradient(colors: [Colors.indigo, primary.shade300]),
        ),
      ],
    );
  }

  Widget _buildRightColumn(MaterialColor primary) {
    final completionValue = (averageCompletion / 100).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _CircularStat(
                      percent: completionValue,
                      label: '${averageCompletion.toInt()}%',
                      size: 84,
                      color: primary,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Average Completion',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This shows the percentage of course content completed on average across learners. Track this weekly to spot dips.',
                            style: TextStyle(color: Colors.black54, fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: completionValue,
                              minHeight: 10,
                              // color the progress with the theme color
                              valueColor: AlwaysStoppedAnimation(primary),
                              backgroundColor: primary.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Quick filters / tags
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Quick Filters', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    FilterChip(label: const Text('Last 7 days'), onSelected: (_) {}),
                    FilterChip(label: const Text('Last 30 days'), onSelected: (_) {}),
                    FilterChip(label: const Text('Top programs'), onSelected: (_) {}),
                    FilterChip(label: const Text('Low completion'), onSelected: (_) {}),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: const Offset(0, 6),
            blurRadius: 12,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _CircularStat extends StatelessWidget {
  final double percent; // 0.0 - 1.0
  final String label;
  final double size;
  final Color color;

  const _CircularStat({
    required this.percent,
    required this.label,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: percent,
              strokeWidth: 8,
              valueColor: AlwaysStoppedAnimation(color),
              backgroundColor: color.withOpacity(0.15),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: color)),
              const SizedBox(height: 2),
              const Text('avg', style: TextStyle(fontSize: 11, color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }
}

// Simple subtle background helper - keeps page from being plain white
class LinearGradientBackground extends StatelessWidget {
  const LinearGradientBackground({super.key});

  Color get color => Colors.grey.shade50;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade50, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
