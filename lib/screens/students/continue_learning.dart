import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/screens/details.dart'; // <-- where DetailsPage is
import 'package:eduxcel/models/course.dart'; // <-- where Course is


class ContinueLearningPage extends StatefulWidget {
  const ContinueLearningPage({super.key});

  @override
  State<ContinueLearningPage> createState() => _ContinueLearningPageState();
}

class _ContinueLearningPageState extends State<ContinueLearningPage> {
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;
  static const Color primary = Color(0xFF673AB7);
  Stream<QuerySnapshot>? _enrollmentStream;

  @override
  void initState() {
    super.initState();
    if (_userId != null) {
      // Stream for the enrollment records (the outer layer)
      _enrollmentStream = FirebaseFirestore.instance
      // Path: artifacts/eduxcel/users/{userId}/coursesEnrolled
          .collection('artifacts')
          .doc('eduxcel')
          .collection('users')
          .doc(_userId)
          .collection('coursesEnrolled')
          .snapshots();
    }
  }

  // ------------------------------------------------------------------
  // Asynchronously fetches detailed course data from /courses/
  // ------------------------------------------------------------------
  Future<Course> _fetchCourseDetails(
      String courseId, Map<String, dynamic> enrollmentData) async {

    // Path: artifacts/eduxcel/courses/{courseId}
    final courseDoc = await FirebaseFirestore.instance
        .collection('artifacts')
        .doc('eduxcel')
        .collection('courses') // <-- Target the central courses collection
        .doc(courseId)
        .get();

    if (courseDoc.exists && courseDoc.data() != null) {
      final courseData = courseDoc.data()!;

      // Use the detailed course data to construct the final Course object
      return Course(
        // Prefer data from the central course document
        title: courseData['title'] ?? enrollmentData['courseTitle'] ?? 'Course Title Missing',
        description: courseData['description'] ?? 'Detailed description not available.',
        chapters: courseData['chapters'] ?? 0,
        instructor: courseData['instructor'] ?? 'Instructor not specified',
      );
    } else {
      // Fallback: Use minimal data from the enrollment record if central course is missing
      print('Warning: Central course details not found for ID: $courseId');
      return Course(
        title: enrollmentData['courseTitle'] ?? 'Course Title Missing',
        description: 'Failed to load full course details.',
        chapters: 0,
        instructor: enrollmentData['instructor'] ?? 'N/A',
      );
    }
  }

  // ------------------------------------------------------------------
  // 3. Build Method
  // ------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = theme.colorScheme.background;

    if (_userId == null) {
      return const Scaffold(
        body: Center(
            child: Text('Please log in to view your enrolled courses.',
                style: TextStyle(fontSize: 16, color: Colors.red))),
      );
    }

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
      // --- Outer StreamBuilder: Enrollment Records ---
      body: StreamBuilder<QuerySnapshot>(
        stream: _enrollmentStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading enrollments: ${snapshot.error}'));
          }

          final enrolledDocs = snapshot.data?.docs ?? [];

          if (enrolledDocs.isEmpty) {
            return const Center(
                child: Text('You are not currently enrolled in any courses.',
                    textAlign: TextAlign.center));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: enrolledDocs.length,
            itemBuilder: (context, index) {
              final enrollmentData = enrolledDocs[index].data() as Map<String, dynamic>;
              final courseId = enrollmentData['courseId'];

              if (courseId == null) {
                return const SizedBox.shrink(); // Skip if courseId is missing
              }

              // --- Inner FutureBuilder: Fetch detailed Course data ---
              return FutureBuilder<Course>(
                future: _fetchCourseDetails(courseId, enrollmentData),
                builder: (context, courseSnapshot) {
                  // Show loading placeholder while fetching details for this specific card
                  if (courseSnapshot.connectionState == ConnectionState.waiting) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      child: LinearProgressIndicator(color: primary.withOpacity(0.5), minHeight: 8),
                    );
                  }

                  if (courseSnapshot.hasError || !courseSnapshot.hasData) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Could not load details for ${enrollmentData['courseTitle'] ?? 'a course'}.'),
                      ),
                    );
                  }

                  final course = courseSnapshot.data!;

                  // Data from enrollment document (progress, status, etc.)
                  final status = enrollmentData['status'] ?? 'In Progress';
                  final currentLevel = enrollmentData['currentLevel'] ?? 'N/A';
                  final progress = (Random().nextInt(60) + 20) / 100; // Random progress simulation

                  // ------------------------------------------------------------------
                  // 🎯 LOGIC FOR DISABLING AND VISUAL CHANGES
                  // ------------------------------------------------------------------
                  final bool isPending = status == 'Pending Approval';

                  // Determine colors based on status
                  final Color cardColor = isPending ? Colors.grey.shade100 : Colors.white;
                  final Color contentColor = isPending ? Colors.grey.shade500 : Colors.black87;
                  final Color indicatorColor = isPending ? Colors.grey : primary;
                  final Color borderColor = isPending ? Colors.grey.shade300 : primary.withOpacity(0.12);

                  // Determine onTap action
                  final VoidCallback? onTapAction = isPending
                      ? null // Disable clicking
                      : () {
                    // Navigate to DetailsPage if approved
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailsPage(course: course),
                      ),
                    );
                  };
                  // ------------------------------------------------------------------

                  return Card(
                    // Apply disabled look if pending
                    color: cardColor,
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: borderColor),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      // Set onTap to null to disable interaction
                      onTap: onTapAction,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: contentColor, // Apply disabled color
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Display course metadata fetched from the central collection
                            Row(
                              children: [
                                Icon(Icons.person, size: 16, color: indicatorColor),
                                const SizedBox(width: 4),
                                Text(course.instructor, style: TextStyle(fontSize: 12, color: contentColor)),
                                const Spacer(),
                                Icon(Icons.menu_book, size: 16, color: indicatorColor),
                                const SizedBox(width: 4),
                                Text('${course.chapters} chapters', style: TextStyle(fontSize: 12, color: contentColor)),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Enrollment status and level from the enrollment record
                            Row(
                              children: [
                                Chip(
                                  label: Text(status, style: const TextStyle(fontSize: 11)),
                                  backgroundColor: status == 'Pending Approval' ? Colors.orange.shade100 : Colors.green.shade100,
                                ),
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text(currentLevel, style: const TextStyle(fontSize: 11)),
                                  backgroundColor: indicatorColor.withOpacity(0.1),
                                ),
                              ],
                            ),
                            // ------------------------------------------------------------------
                            // 🎯 CONDITIONAL WIDGETS (Progress Bar & Text)
                            // ------------------------------------------------------------------
                            if (!isPending) ...[
                              const SizedBox(height: 12),
                              // Progress Bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: indicatorColor.withOpacity(0.15),
                                  color: indicatorColor,
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${(progress * 100).toStringAsFixed(0)}% completed',
                                style: TextStyle(
                                  color: indicatorColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: 8),
                              Text(
                                'Awaiting approval...',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            // ------------------------------------------------------------------
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}