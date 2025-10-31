import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Global variables provided by the canvas environment or defined globally if needed.
// This is used for structuring your Firestore data in a multi-app scenario.
const String __app_id = 'eduxcel';
// firebaseConfig is generally handled by Firebase.initializeApp() and flutterfire config,
// so it's not directly used in the widget itself usually.
// final Map<String, dynamic> firebaseConfig = {}; // Keep if you use it elsewhere.

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  String? _displayName;
  DateTime? _dateOfBirth;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill display name if available from Google account
    _displayName = _auth.currentUser?.displayName;
  }

  void _showError(String message) {
    if (!mounted) return; // Ensure the widget is still in the tree
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if form validation fails
    }
    _formKey.currentState!.save(); // Save form fields to variables

    if (_dateOfBirth == null) {
      _showError('Please select your Date of Birth.');
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _showError('User not logged in.');
        return;
      }

      // 1. Update Display Name in Firebase Auth (if it changed or was empty)
      // Only update if the current Auth display name is different from the form,
      // or if the Auth display name was initially null/empty and we now have one.
      if (_displayName != null &&
          (user.displayName != _displayName!.trim() || user.displayName == null || user.displayName!.isEmpty)) {
        await user.updateDisplayName(_displayName!.trim());
      }

      // 2. Save extended profile data (DoB, role, and completion status) to Firestore
      // Using a streamlined Firestore path:
      final userProfileDocRef = _firestore
          .collection('artifacts') // Top-level collection for your app's data
          .doc(__app_id)           // Document for this specific application instance
          .collection('users')    // Subcollection for all user profiles
          .doc(user.uid);         // Document for the specific user, using their Firebase Auth UID

      final profileData = {
        'displayName': _displayName!.trim(),
        'email': user.email, // Include email for easy reference/querying
        'dateOfBirth': _dateOfBirth!.toIso8601String(), // ISO 8601 for consistent date storage
        'role': 'Student', // Default role for EduXcel sign-ups
        'createdAt': FieldValue.serverTimestamp(), // Timestamp for when the account was created
        'completedAt': FieldValue.serverTimestamp(), // Timestamp for when the profile was completed
        'profileComplete': true, // Crucial flag to indicate profile is fully set up
      };

      // Use set with merge: true to avoid overwriting existing data if any (e.g., createdAt from Cloud Function)
      await userProfileDocRef.set(profileData, SetOptions(merge: true));

      if (mounted) {
        // Navigate to home after successful profile completion
        // pushReplacementNamed prevents going back to the profile screen
        Navigator.of(context).pushReplacementNamed('/home');
      }

    } on FirebaseException catch (e) {
      // Catch specific Firebase errors
      _showError('Error saving profile: ${e.message}');
    } catch (e) {
      // Catch any other unexpected errors
      _showError('Operation failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        automaticallyImplyLeading: false, // Prevent going back to previous screens from here
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400), // Max width for larger screens
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Just a few more steps!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please confirm your details to finish setting up your EduXcel account.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  // Full Name Field
                  TextFormField(
                    initialValue: _displayName,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Full Name is required.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _displayName = value;
                    },
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),

                  // Date of Birth Field (with date picker)
                  TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.calendar_today),
                        // Clear button for date of birth
                        suffixIcon: _dateOfBirth != null
                            ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _dateOfBirth = null;
                            });
                          },
                        )
                            : null,
                      ),
                      readOnly: true, // Make the field non-editable by keyboard
                      controller: TextEditingController(
                        text: _dateOfBirth == null
                            ? ''
                            : '${_dateOfBirth!.day.toString().padLeft(2, '0')}/${_dateOfBirth!.month.toString().padLeft(2, '0')}/${_dateOfBirth!.year}',
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _dateOfBirth ?? DateTime(2000), // Use selected date or a reasonable default
                          firstDate: DateTime(1950), // Earliest selectable date
                          lastDate: DateTime.now(), // Latest selectable date (today)
                        );
                        if (date != null) {
                          setState(() {
                            _dateOfBirth = date;
                          });
                        }
                      },
                      validator: (value) {
                        if (_dateOfBirth == null) {
                          return 'Date of Birth is required.';
                        }
                        return null;
                      }),
                  const SizedBox(height: 40),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile, // Disable button while loading
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF673AB7), // Purple color (Firebase primary)
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Finish Profile'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}