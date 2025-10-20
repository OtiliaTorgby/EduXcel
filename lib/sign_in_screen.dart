// sign_in_screen.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Enum to manage the state between Sign In and Sign Up
enum AuthMode { signIn, signUp }

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  AuthMode _authMode = AuthMode.signIn;
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  // --- Utility Functions ---

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // --- Core Authentication Logic ---

  Future<void> _submitAuthForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.signIn) {
        // Log user in
        await _auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
      } else {
        // Sign user up
        await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred, please check your credentials.';
      if (e.message != null) {
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

  // Function to handle Google Sign-In (Moved from home_page.dart)
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final GoogleSignIn googleSignIn;

      // Initialize GoogleSignIn with clientId only for web
      if (kIsWeb) {
        googleSignIn = GoogleSignIn(
          // PASTE YOUR WEB CLIENT ID HERE (Needed for web)
          clientId: "947251316245-t6f5iotprj122jrc9r8pddltl8rf9b2h.apps.googleusercontent.com",
        );
      } else {
        // For Android/iOS, no clientId needed here
        googleSignIn = GoogleSignIn();
      }

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign into Firebase with the Google credential
      await _auth.signInWithCredential(credential);

    } on FirebaseAuthException catch (e) {
      _showError('Failed to sign in with Google: ${e.message}');
    } catch (e) {
      _showError('Failed to sign in with Google: $e');
    } finally {
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
                    // Email Field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Username or email address',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.contains('@')) {
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _email = value!.trim();
                      },
                    ),
                    const SizedBox(height: 16),
                    // Password Field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty || value.length < 6) {
                          return 'Password must be at least 6 characters long.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _password = value!;
                      },
                    ),

                    if (isSignIn)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Implement forgot password logic
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
                          child: Text(isSignIn ? 'Submit' : 'Sign Up'),
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
                  icon: Image.asset(
                    'assets/google.png', // You MUST add a Google logo asset here
                    height: 24.0,
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
    );
  }
}