// Save this file as 'enrollment_form_page.dart'

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/course.dart';


class EnrollmentFormPage extends StatefulWidget {
  final Course course;
  const EnrollmentFormPage({super.key, required this.course});

  @override
  State<EnrollmentFormPage> createState() => _EnrollmentFormPageState();
}

class _EnrollmentFormPageState extends State<EnrollmentFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _motivation = '';
  String _currentLevel = 'Beginner';
  double _timeCommitmentHours = 5.0;

  static const Color primary = Color(0xFF673AB7);
  static const List<String> _levelOptions = ['Beginner', 'Intermediate', 'Professional'];

  // --- Utility Function for Enhanced Input Decoration ---
  InputDecoration _getInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2.0),
      ),
      fillColor: primary.withOpacity(0.05), // Subtle fill color
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  // --- Submission Logic (Unchanged from your last version) ---
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in.')),
        );
        return;
      }

      final enrollmentData = {
        'timestamp': FieldValue.serverTimestamp(),
        'courseId': widget.course.title.replaceAll(' ', '_').toLowerCase(),
        'motivation': _motivation,
        'currentLevel': _currentLevel,
        'timeCommitmentHours': _timeCommitmentHours.toInt(),
        'status': 'Pending Approval',
      };

      try {
        final docRef = FirebaseFirestore.instance
            .collection('artifacts')
            .doc('eduxcel')
            .collection('users')
            .doc(userId)
            .collection('coursesEnrolled')
            .doc(widget.course.title.replaceAll(' ', '_').toLowerCase());

        await docRef.set(enrollmentData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Enrollment application for ${widget.course.title} submitted!'),
            backgroundColor: primary,
          ),
        );

        print('✅ Firestore Document written successfully.');
        print('Path: artifacts/eduxcel/users/$userId/coursesEnrolled/${widget.course.title.replaceAll(' ', '_').toLowerCase()}');

        Navigator.of(context).pop();

      } catch (e) {
        print('❌ Firestore Error during enrollment: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit enrollment: $e')),
        );
      }
    }
  }

  // ------------------------------------------------
  // 🎯 ENHANCED BUILD METHOD
  // ------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrollment Application'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      // Added a subtle background color for depth
      body: Container(
        color: Colors.grey[50],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                // --- Course Info Card (Elevated Visual) ---
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Applying for:', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          widget.course.title,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Instructor: ${widget.course.instructor}',
                          style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- Section 1: Motivation (Why enroll?) ---
                _buildSectionHeader(
                  title: '1. Your Motivation',
                  subtitle: 'Why are you interested in this course?',
                  icon: Icons.lightbulb_outline,
                ),
                TextFormField(
                  decoration: _getInputDecoration('Tell us your goals...', Icons.format_align_left),
                  maxLines: 4,
                  validator: (value) => (value == null || value.isEmpty) ? 'Please state your motivation for enrolling.' : null,
                  onSaved: (value) => _motivation = value!,
                ),
                const SizedBox(height: 30),

                // --- Section 2: Current Level ---
                _buildSectionHeader(
                  title: '2. Experience Level',
                  subtitle: 'What is your current experience level?',
                  icon: Icons.psychology_outlined,
                ),
                DropdownButtonFormField<String>(
                  decoration: _getInputDecoration('', Icons.trending_up).copyWith(
                    fillColor: Colors.white, // White fill for dropdown clarity
                    filled: true,
                  ),
                  value: _currentLevel,
                  items: _levelOptions.map((level) => DropdownMenuItem<String>(value: level, child: Text(level))).toList(),
                  onChanged: (newValue) => setState(() => _currentLevel = newValue!),
                  onSaved: (value) => _currentLevel = value!,
                ),
                const SizedBox(height: 30),

                // --- Section 3: Time Commitment ---
                _buildSectionHeader(
                  title: '3. Time Commitment',
                  subtitle: 'How many hours per week can you dedicate?',
                  icon: Icons.schedule,
                ),
                // Slider Section within a Card for better visual grouping
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Weekly Hours:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            // Current hours display
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_timeCommitmentHours.toInt()} hrs',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primary),
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _timeCommitmentHours,
                          min: 1,
                          max: 20,
                          divisions: 19,
                          onChanged: (value) => setState(() => _timeCommitmentHours = value),
                          activeColor: primary,
                          inactiveColor: primary.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // --- Submit Button ---
                Center(
                  child: SizedBox(
                    width: double.infinity, // Full width button
                    child: ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: const Icon(Icons.send_rounded, size: 20),
                      label: const Text('Submit Enrollment Application'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: primary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widget for Section Headers ---
  Widget _buildSectionHeader({required String title, required String subtitle, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primary, size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF303030),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
