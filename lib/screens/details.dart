import 'package:flutter/material.dart';

class Course {
  final String title;
  final String description;
  final int chapters; // Corrected to int
  final String instructor;

  Course({
    required this.title,
    required this.description,
    required this.chapters,
    required this.instructor,
  });
}

class DetailsPage extends StatelessWidget {
  final Course course;

  const DetailsPage({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
        backgroundColor: Color(0xFF673AB7),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    course.title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF673AB7),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Instructor: ${course.instructor}',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Chapters: ${course.chapters}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  Divider(height: 30, thickness: 1),
                  Text(
                    'About this Course',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    course.description,
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Enrolling in ${course.title}...')),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Enroll Now',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF673AB7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Course Content (Chapters)',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            ...List.generate(course.chapters, (index) {
              return ListTile(
                leading: Icon(Icons.menu_book, color: Color(0xFF673AB7)),
                title: Text('Chapter ${index + 1}: Lesson Title'),
                subtitle: Text('Video, Reading Material, Quiz'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              );
            }),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}