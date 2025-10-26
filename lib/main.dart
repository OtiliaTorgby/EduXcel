import 'package:flutter/material.dart';
import 'package:eduxcel_project/details.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final course = Course(
      title: 'Sample Course',
      description:
          'This is a sample course description. It demonstrates the DetailsPage and how it handles zero chapters.',
      chapters: 0,
      instructor: 'Jane Doe',
    );

    return MaterialApp(
      title: 'Eduxcel Demo',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: DetailsPage(course: course),
    );
  }
}
