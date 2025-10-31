import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Global variables provided by the canvas environment
const String __app_id = 'eduxcel';
final Map<String, dynamic> firebaseConfig = {}; // Placeholder for __firebase_config

enum AuthMode { signIn, signUp }

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // New Fields for Sign Up
  final _formKey = GlobalKey<FormState>();
  AuthMode _authMode = AuthMode.signIn;
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _displayName = '';
  DateTime? _dateOfBirth;
  bool _isLoading = false;

  // Local variable to hold the main password controller's text for validation
  final TextEditingController _passwordController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? "947251316245-t6f5iotprj122jrc9r8pddltl8rf9b2h.apps.googleusercontent.com"
        : null,
  );

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  // --- Utility Functions ---

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Complex Password Validation Logic
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 8) {
      return 'Must be at least 8 characters.';
    }
    // Check for Uppercase, Lowercase, Digit, and Special Character
    final RegExp passwordRegExp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&*(),.?":{}|<>]).{8,}$',
    );

    if (!passwordRegExp.hasMatch(value)) {
      return 'Must be 8+ chars & include: Uppercase, Lowercase, Digit, Special Character.';
    }
    return null;
  }

  // Firestore Logic to Save Profile (DoB, default role)
  Future<DocumentSnapshot<Map<String, dynamic>>> _getProfileDocument(String uid) async {
    return _firestore
        .collection('artifacts')
        .doc(__app_id)
        .collection('users')
        .doc(uid)
        .collection('profiles')
        .doc(uid)
        .get();
  }

  Future<void> _saveProfileToFirestore(User user, {required DateTime dob, String role = 'Student', required String name}) async {
    final docRef = _firestore
        .collection('artifacts')
        .doc(__app_id)
        .collection('users')
        .doc(user.uid)
        .collection('profiles')
        .doc(user.uid);

    final profileData = {
      'displayName': name,
      'email': user.email,
      'dateOfBirth': dob.toIso8601String(), // Convert DateTime to String for storage
      'role': role, // Default role is Student
      'createdAt': FieldValue.serverTimestamp(),
    };

    await docRef.set(profileData, SetOptions(merge: true));
  }

  // --- Core Authentication Logic (Manual Sign In/Up) ---

  Future<void> _submitAuthForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    if (_authMode == AuthMode.signUp && _password.trim() != _confirmPassword.trim()) {
      _showError('Passwords do not match.');
      return;
    }

    if (_authMode == AuthMode.signUp && _dateOfBirth == null) {
      _showError('Please select your Date of Birth.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential;
      final email = _email.trim();
      final password = _password.trim();

      if (_authMode == AuthMode.signIn) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        // Sign user up
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await userCredential.user!.updateDisplayName(_displayName.trim());

        await _saveProfileToFirestore(
          userCredential.user!,
          dob: _dateOfBirth!,
          role: 'Student',
          name: _displayName.trim(),
        );
      }

      // Removed manual navigation: AuthWrapper will handle navigation to /home

    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred, please check your credentials.';
      if (e.code == 'invalid-credential' || e.code == 'wrong-password' || e.code == 'user-not-found') {
        message = "Invalid email or password. Please try again.";
      } else if (e.message != null) {
        message = e.message!;
      }
      _showError(message);
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

  // --- Core Authentication Logic (Google Sign-In) ---

  Future<void> _signInWithGoogle() async {
    if (_isLoading) return; // Prevent multiple clicks
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      // NOTE: Authentication is complete.
      // We no longer navigate manually here.
      // The AuthWrapper in main.dart will automatically detect the state change
      // and redirect the user to the correct screen (/home or /complete-profile).

    } on FirebaseAuthException catch (e) {
      _showError('Failed to sign in with Google: ${e.message}');
    } catch (e) {
      _showError('Operation failed: $e');
    } finally {
      // Reset loading state only if the widget is still mounted
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- Widget Build Methods ---

  @override
  Widget build(BuildContext context) {
    final isSignIn = _authMode == AuthMode.signIn;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Title and Welcome
                Text(
                  isSignIn ? 'Welcome back!' : 'Join EduXcel!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  isSignIn ? 'Sign In' : 'Sign Up',
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // Manual Sign In/Up Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      // --- Sign Up Fields Only ---
                      if (!isSignIn) ...[
                        TextFormField(
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
                            _displayName = value!.trim();
                          },
                        ),
                        const SizedBox(height: 16),
                        // Date of Birth Field (with date picker)
                        TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Date of Birth',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.calendar_today),
                              suffixIcon: _dateOfBirth != null
                                  ? TextButton(
                                onPressed: () {
                                  setState(() {
                                    _dateOfBirth = null;
                                  });
                                },
                                child: const Text('Clear'),
                              )
                                  : null,
                            ),
                            readOnly: true,
                            controller: TextEditingController(
                              text: _dateOfBirth == null
                                  ? ''
                                  : '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
                            ),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime(2000),
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
                              if (!isSignIn && _dateOfBirth == null) {
                                return 'Date of Birth is required.';
                              }
                              return null;
                            }
                        ),
                        const SizedBox(height: 16),
                      ],
                      // --- Common Fields (Email) ---
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Email address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty || !value.contains('@')) {
                            return 'Please enter a valid email address.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _email = value!;
                        },
                      ),
                      const SizedBox(height: 16),
                      // --- Common Fields (Password) ---
                      TextFormField(
                        controller: _passwordController, // Use the controller here
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          // Hint for complex validation
                          hintText: !isSignIn ? '8+ chars, Uppercase, Digit, Special' : null,
                        ),
                        obscureText: true,
                        // Apply complex validation only on Sign Up
                        validator: isSignIn ? null : _validatePassword,
                        onSaved: (value) {
                          _password = value!.trim();
                        },
                      ),

                      // --- Password Confirmation Field (Sign Up Only) ---
                      if (!isSignIn) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Confirm Password',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password.';
                            }
                            // Compare the current input value (value)
                            // against the main password field's text, trimmed.
                            if (value.trim() != _passwordController.text.trim()) {
                              return 'Passwords do not match.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _confirmPassword = value!.trim();
                          },
                        ),
                      ],


                      if (isSignIn)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              _showError('Forgot password functionality not yet implemented.');
                            },
                            child: const Text('Forgot your password?'),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Submit Button
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitAuthForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF673AB7), // Purple color
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(isSignIn ? 'Sign In' : 'Sign Up'),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Divider or Spacer
                const Text('OR', style: TextStyle(color: Colors.grey)),

                const SizedBox(height: 30),

                // Google Sign-In Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    // NOTE: You must provide a 'assets/google.png' image file in your Flutter assets folder.
                    icon: Image.asset(
                      'assets/google.png',
                      height: 24,
                    ),
                    label: Text('${isSignIn ? 'Sign In' : 'Sign Up'} with Google'),
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 18),
                      side: const BorderSide(color: Colors.grey, width: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Switch Auth Mode Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(isSignIn ? "Don't have an account yet?" : "Already have an account?"),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                        setState(() {
                          _authMode = isSignIn ? AuthMode.signUp : AuthMode.signIn;
                          _formKey.currentState!.reset(); // Clear form on switch
                          _passwordController.clear(); // Clear controller explicitly
                          _dateOfBirth = null; // Clear DOB explicitly
                        });
                      },
                      child: Text(isSignIn ? 'Sign up' : 'Sign in'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
