import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Global app ID variable
const String __app_id = 'eduxcel';

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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    if (_dateOfBirth == null) {
      _showError('Please select your Date of Birth.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _showError('User not logged in.');
        return;
      }

      // 1. Update Display Name in Firebase Auth (if necessary)
      if (_displayName != null && _displayName!.trim().isNotEmpty && user.displayName != _displayName!.trim()) {
        await user.updateDisplayName(_displayName!.trim());
      }

      // 2. Save extended profile data to Firestore
      final userProfileDocRef = _firestore
          .collection('artifacts')
          .doc(__app_id)
          .collection('users')
          .doc(user.uid);

      final profileData = {
        'displayName': _displayName!.trim(),
        'email': user.email,
        // Using ISO 8601 String for consistency with what we chose for manual sign-up
        'dateOfBirth': _dateOfBirth!.toIso8601String(),
        'role': 'Student', // Default role for EduXcel sign-ups
        // --- CRITICAL ADDITIONS ---
        'profileComplete': true, // SET FLAG TO TRUE
        'completedAt': FieldValue.serverTimestamp(), // Track completion time
        // -------------------------
      };

      // Use merge: true to avoid overwriting fields like 'createdAt' or 'authMethod'
      await userProfileDocRef.set(profileData, SetOptions(merge: true));

      if (mounted) {
        // Pop the screen. The ProfileCheckRouter below it will now rebuild,
        // read 'profileComplete: true', and route the user to the RoleBasedRouter.
        Navigator.of(context).pop();
      }

    } on FirebaseException catch (e) {
      _showError('Error saving profile: ${e.message}');
    } catch (e) {
      _showError('Operation failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        // Use the primary color from the theme
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Must complete profile to proceed
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
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
                      readOnly: true,
                      controller: TextEditingController(
                        text: _dateOfBirth == null
                            ? ''
                            : '${_dateOfBirth!.day.toString().padLeft(2, '0')}/${_dateOfBirth!.month.toString().padLeft(2, '0')}/${_dateOfBirth!.year}',
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _dateOfBirth ?? DateTime(2000),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
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
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary, // Using theme primary color
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
