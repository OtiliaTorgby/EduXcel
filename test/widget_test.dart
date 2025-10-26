import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eduxcel_project/details.dart';

void main() {
  group('DetailsPage Widget Tests', () {
    testWidgets('displays course details correctly', (WidgetTester tester) async {
      final course = Course(
        title: 'Test Course',
        description: 'Test Description',
        chapters: 3,
        instructor: 'Test Instructor',
      );

      await tester.pumpWidget(MaterialApp(home: DetailsPage(course: course)));

      // Verify course title appears in both AppBar and content
      expect(find.text('Test Course'), findsNWidgets(2));
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.text('Instructor: Test Instructor'), findsOneWidget);
      expect(find.text('Chapters: 3'), findsOneWidget);
    });

    testWidgets('generates correct number of chapters', (WidgetTester tester) async {
      final course = Course(
        title: 'Test Course',
        description: 'Test Description',
        chapters: 2,
        instructor: 'Test Instructor',
      );

      await tester.pumpWidget(MaterialApp(home: DetailsPage(course: course)));

      // Verify chapter list items
      expect(find.text('Chapter 1: Lesson Title'), findsOneWidget);
      expect(find.text('Chapter 2: Lesson Title'), findsOneWidget);
      expect(find.byIcon(Icons.menu_book), findsNWidgets(2));
      expect(find.byIcon(Icons.arrow_forward_ios), findsNWidgets(2));
    });

    testWidgets('shows enroll button and triggers snackbar', (WidgetTester tester) async {
      final course = Course(
        title: 'Test Course',
        description: 'Test Description',
        chapters: 1,
        instructor: 'Test Instructor',
      );

      await tester.pumpWidget(MaterialApp(home: DetailsPage(course: course)));

      // Find and tap the enroll button
      expect(find.text('Enroll Now'), findsOneWidget);
      await tester.tap(find.text('Enroll Now'));
      await tester.pump();

      // Verify snackbar appears with correct message
      expect(find.text('Enrolling in Test Course...'), findsOneWidget);
    });

    testWidgets('handles zero chapters correctly', (WidgetTester tester) async {
      final course = Course(
        title: 'Test Course',
        description: 'Test Description',
        chapters: 0,
        instructor: 'Test Instructor',
      );

      await tester.pumpWidget(MaterialApp(home: DetailsPage(course: course)));

      // Verify no chapter list items are generated
      expect(find.byIcon(Icons.menu_book), findsNothing);
      expect(find.text('Chapter 1: Lesson Title'), findsNothing);

      // Verify other content is still present
      expect(find.text('Course Content (Chapters)'), findsOneWidget);
      expect(find.text('Chapters: 0'), findsOneWidget);
    });
  });
}
