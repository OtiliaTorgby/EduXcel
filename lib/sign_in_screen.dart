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

  // FIX: Initialize GoogleSignIn once as a state variable with the correct Client ID
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // NOTE: Replace this placeholder with your actual Web Client ID if it changes.
    // The format is: <ID>.apps.googleusercontent.com
    clientId: kIsWeb
        ? "947251316245-t6f5iotprj122jrc9r8pddltl8rf9b2h.apps.googleusercontent.com"
        : null, // Null for mobile/desktop
  );

  final _formKey = GlobalKey<FormState>();
  AuthMode _authMode = AuthMode.signIn;
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  // --- Utility Functions ---

  void _showError(String message) {
    // Check if the widget is still in the tree before showing the Snackbar
    if (!mounted) return;
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
    // This calls the onSaved callbacks which set _email and _password
    _formKey.currentState!.save();

    // Now that the data is saved, we trim it once more just to be safe
    final email = _email.trim();
    final password = _password.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.signIn) {
        // CORRECT: Using the standard method for Email/Password Sign In
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        // CORRECT: Using the standard method for Email/Password Sign Up
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      // Navigate on success
      if (mounted) {
        // We use pushReplacementNamed to prevent the user from going back to the sign-in screen
        Navigator.of(context).pushReplacementNamed('/home');
      }

    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred, please check your credentials.';

      // The search results confirm that Firebase sometimes returns the generic 'invalid-credential'
      // or 'The supplied auth credential is incorrect' error even for wrong password/user not found
      // due to email enumeration protection (since September 2023).
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

  // Function to handle Google Sign-In
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // CORRECT: This is where signInWithCredential is properly used (with Google tokens)
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      // Navigate on success (Google)
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }

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
                        labelText: 'Email address',
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
                        _email = value!.trim(); // Email is trimmed
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
                        // FIX: Add .trim() here to prevent whitespace from causing "malformed credential"
                        _password = value!.trim();
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
