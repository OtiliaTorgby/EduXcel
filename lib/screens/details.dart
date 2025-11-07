import 'package:flutter/material.dart';
import 'package:eduxcel/enrollment_form_page.dart';
import 'package:eduxcel/models/course.dart';



// ---------------------------------------------
// 3. DetailsPage Widget
// ---------------------------------------------
class DetailsPage extends StatelessWidget {
  final Course course;

  const DetailsPage({super.key, required this.course});

  static const Color primary = Color(0xFF673AB7); // deep purple

  // Utility Widget for the detailed content shown when the AppBar is expanded
  Widget _buildExpandedHeaderContent(Course course) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Simple circular icon as placeholder for course image
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book,
                size: 36,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 22, // Larger for expanded view
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'By ${course.instructor}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- Floating Action Button (Enroll Now) ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // ✅ Navigation to EnrollmentFormPage is UNCOMMENTED
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EnrollmentFormPage(course: course),
            ),
          );
        },
        backgroundColor: primary,
        label: const Text('Enroll Now'),
        icon: const Icon(Icons.school),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Center the FAB

      body: CustomScrollView(
        slivers: [
          // --- SliverAppBar (Collapsing Header) ---
          SliverAppBar(
            pinned: true,
            expandedHeight: 250, // More space for the expanded header
            backgroundColor: primary,
            foregroundColor: Colors.white, // For back button and title
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16), // Padding for the title when collapsed

              // This builder controls when the title appears (collapsed state)
              title: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double currentExtent = constraints.biggest.height;
                  final double toolbarHeight = MediaQuery.of(context).padding.top + kToolbarHeight;

                  // Only show title if AppBar is significantly collapsed
                  if (currentExtent > toolbarHeight + 10) {
                    return const SizedBox.shrink(); // Hide title when expanded
                  }
                  return Text(
                    course.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primary,
                      primary.withOpacity(0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: _buildExpandedHeaderContent(course),
              ),
            ),
          ),

          // --- Course details card ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              course.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            backgroundColor: primary.withOpacity(0.12),
                            label: Text(
                              '${course.chapters} chapters',
                              style: TextStyle(color: primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Instructor',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        course.instructor,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 8, thickness: 1),
                      const SizedBox(height: 12),
                      const Text(
                        'About this course',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        course.description,
                        style: const TextStyle(fontSize: 15, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- Course Content Header ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Text(
                'Course Content',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),

          // --- Chapter List ---
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final lesson = index + 1;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 1,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      leading: CircleAvatar(
                        backgroundColor: primary.withOpacity(0.14),
                        child: Text(
                          '$lesson',
                          style: TextStyle(color: primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text('Chapter $lesson: Topic Title'),
                      subtitle: const Text('Video · Reading · Quiz'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.chevron_right),
                        ],
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Open Chapter $lesson')),
                        );
                      },
                    ),
                  ),
                );
              },
              childCount: course.chapters,
            ),
          ),

          // Bottom padding to make space for floating button
          SliverToBoxAdapter(
            child: const SizedBox(height: 90),
          ),
        ],
      ),
    );
  }
}