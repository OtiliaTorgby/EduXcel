import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../details.dart';
import 'package:eduxcel/models/course.dart';

class ProgramListScreen extends StatefulWidget {
  const ProgramListScreen({super.key});

  @override
  State<ProgramListScreen> createState() => _ProgramListScreenState();
}

class _ProgramListScreenState extends State<ProgramListScreen> {
  List<Map<String, dynamic>> programs = [];
  List<Map<String, dynamic>> filteredPrograms = [];
  bool isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('artifacts')
          .doc('eduxcel')
          .collection('courses')
          .get();


      final data = querySnapshot.docs.map((doc) => doc.data()).toList();
      if (!mounted) return;
      setState(() {
        programs = List<Map<String, dynamic>>.from(data);
        _applyFilter();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      debugPrint('❌ Error loading programs: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load programs: $e')),
      );
    }
  }

  Future<void> _refreshPrograms() async {
    await Future.delayed(const Duration(milliseconds: 700));
    await _loadPrograms();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Programs updated!')),
    );
  }

  void _applyFilter() {
    if (_searchQuery.trim().isEmpty) {
      filteredPrograms = List<Map<String, dynamic>>.from(programs);
    } else {
      final q = _searchQuery.toLowerCase();
      filteredPrograms = programs.where((p) {
        final title = (p['title'] ?? '').toString().toLowerCase();
        final desc = (p['description'] ?? '').toString().toLowerCase();
        final instr = (p['instructor'] ?? '').toString().toLowerCase();
        return title.contains(q) || desc.contains(q) || instr.contains(q);
      }).toList();
    }
  }

  void _onSearchChanged(String v) {
    setState(() {
      _searchQuery = v;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    const headerGradient = LinearGradient(
      colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA), Color(0xFFAB47BC)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Available Programs',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.4,
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: headerGradient),
        child: SafeArea(
          bottom: true,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.school, color: Colors.white70),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Learn. Build. Ship.',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${programs.length}',
                                style: const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Material(
                  color: Colors.white.withOpacity(0.92),
                  elevation: 2,
                  borderRadius: BorderRadius.circular(12),
                  child: TextField(
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search programs, instructors, descriptions',
                      hintStyle: TextStyle(color: Colors.grey.shade700),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF6A1B9A)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF6A1B9A)),
                        onPressed: () => _onSearchChanged(''),
                      )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F6FB),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                    ),
                  ),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                    onRefresh: _refreshPrograms,
                    color: const Color(0xFF6A1B9A),
                    backgroundColor: Colors.white,
                    child: filteredPrograms.isEmpty
                        ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 40),
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.search_off,
                                  size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                'No programs found',
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                        : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      itemCount: filteredPrograms.length,
                      itemBuilder: (context, index) {
                        final program = filteredPrograms[index];
                        final title = (program['title'] ?? 'Untitled').toString();
                        final description = (program['description'] ?? '').toString();
                        final instructor = (program['instructor'] ?? 'Unknown Instructor').toString();
                        final chapters = program['chapters'] ?? 0;
                        final avatarTag = 'avatar_$index';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              final course = Course(
                                title: title,
                                description: description,
                                chapters: chapters,
                                instructor: instructor,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsPage(course: course),
                                ),
                              );
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Hero(
                                      tag: avatarTag,
                                      child: CircleAvatar(
                                        radius: 28,
                                        backgroundColor: const Color(0xFF8E24AA),
                                        child: Text(
                                          title.isNotEmpty ? title[0] : '?',
                                          style: const TextStyle(
                                              color: Colors.white, fontSize: 20),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  title,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 15,
                                                    color: Color(0xFF4A148C),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.purpleAccent.withOpacity(0.12),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.book,
                                                        size: 14, color: Color(0xFF6A1B9A)),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      '$chapters',
                                                      style: const TextStyle(
                                                          fontSize: 12, color: Color(0xFF6A1B9A)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            instructor,
                                            style: TextStyle(
                                                color: Colors.grey.shade700, fontSize: 13),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.grey.shade800, fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
