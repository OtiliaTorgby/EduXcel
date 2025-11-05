import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const String __app_id = 'eduxcel';

enum AuthMode { signIn, signUp }

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  AuthMode _authMode = AuthMode.signIn;
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _displayName = '';
  DateTime? _dateOfBirth;
  bool _isLoading = false;

  final TextEditingController _passwordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? "947251316245-t6f5iotprj122jrc9r8pddltl8rf9b2h.apps.googleusercontent.com"
        : null,
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween(begin: 0.0, end: 12.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_animationController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        }
      });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shakeForm() {
    _animationController.forward(from: 0.0);
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    // Strict validation only for sign-up
    if (_authMode == AuthMode.signUp) {
      if (value.length < 8) {
        return 'Must be at least 8 characters.';
      }
      final passRegExp = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&*(),.?\":{}|<>]).{8,}$');
      if (!passRegExp.hasMatch(value)) {
        return 'Must include uppercase, lowercase, digit, & special character.';
      }
    }
    return null;
  }

  Future<void> _saveProfileToFirestore(User user, {required DateTime dob, required String name}) async {
    final docRef = _firestore.collection('artifacts').doc(__app_id).collection('users').doc(user.uid);
    final profileData = {
      'displayName': name,
      'email': user.email,
      'dateOfBirth': dob.toIso8601String(),
      'role': 'Student',
      'createdAt': FieldValue.serverTimestamp(),
      'profileComplete': true,
      'authMethod': 'manual',
    };
    await docRef.set(profileData, SetOptions(merge: true));
  }

  Future<void> _submitAuthForm() async {
    if (!_formKey.currentState!.validate()) {
      _shakeForm();
      return;
    }
    _formKey.currentState!.save();

    if (_authMode == AuthMode.signUp) {
      if (_password.trim() != _confirmPassword.trim()) {
        _showError('Passwords do not match.');
        return;
      }
      if (_dateOfBirth == null) {
        _showError('Please select your Date of Birth.');
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      UserCredential userCredential;
      if (_authMode == AuthMode.signIn) {
        userCredential = await _auth.signInWithEmailAndPassword(email: _email.trim(), password: _password.trim());
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(email: _email.trim(), password: _password.trim());
        await userCredential.user!.updateDisplayName(_displayName.trim());
        await _saveProfileToFirestore(userCredential.user!, dob: _dateOfBirth!, name: _displayName.trim());
      }
      if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred. Please check your credentials.';
      if (e.code == 'invalid-credential' || e.code == 'wrong-password' || e.code == 'user-not-found') {
        message = "Invalid email or password. Please try again.";
        _shakeForm();
      } else if (e.message != null) {
        message = e.message!;
      }
      _showError(message);
    } catch (e) {
      _showError('Operation failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User user = userCredential.user!;

      final userDocRef = _firestore.collection('artifacts').doc(__app_id).collection('users').doc(user.uid);
      final docSnapshot = await userDocRef.get();

      if (!docSnapshot.exists) {
        await userDocRef.set({
          'email': user.email,
          'displayName': user.displayName ?? '',
          'role': 'Student',
          'createdAt': FieldValue.serverTimestamp(),
          'profileComplete': false,
          'authMethod': 'google',
        });
      }

      if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      _showError('Failed to sign in with Google: $e');
    } finally {
      if (mounted && _auth.currentUser == null) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSignIn = _authMode == AuthMode.signIn;
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_animation.value, 0),
            child: child,
          );
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Icon(Icons.school, color: Colors.white, size: 80),
                    const SizedBox(height: 20),
                    Text(
                      isSignIn ? 'Welcome Back!' : 'Create Account',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isSignIn ? 'Sign in to continue your journey' : 'Join the community to get started',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 40),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          if (!isSignIn) ...[
                            _buildTextField(label: 'Full Name', icon: Icons.person, onSaved: (v) => _displayName = v!, validator: (v) => v!.isEmpty ? 'Full Name is required.' : null),
                            const SizedBox(height: 16),
                            _buildDatePickerField(context),
                            const SizedBox(height: 16),
                          ],
                          _buildTextField(label: 'Email', icon: Icons.email, onSaved: (v) => _email = v!, validator: (v) => v!.isEmpty ? 'Email is required.' : null, keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 16),
                          _buildTextField(label: 'Password', icon: Icons.lock, onSaved: (v) => _password = v!, validator: _validatePassword, obscureText: true, controller: _passwordController),
                          if (!isSignIn) ...[
                            const SizedBox(height: 16),
                            _buildTextField(label: 'Confirm Password', icon: Icons.lock_outline, onSaved: (v) => _confirmPassword = v!, validator: (v) => v != _passwordController.text ? 'Passwords do not match.' : null, obscureText: true),
                          ],
                          const SizedBox(height: 30),
                          if (_isLoading)
                            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                          else ...[
                            _buildSubmitButton(isSignIn),
                            const SizedBox(height: 16),
                            _buildGoogleSignInButton(),
                          ],
                          const SizedBox(height: 20),
                          _buildAuthModeSwitch(isSignIn),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required IconData icon, required FormFieldSetter<String> onSaved, FormFieldValidator<String>? validator, bool obscureText = false, TextInputType? keyboardType, TextEditingController? controller}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.black.withOpacity(0.2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white, width: 2)),
        errorStyle: const TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold),
      ),
      style: const TextStyle(color: Colors.white),
      obscureText: obscureText,
      validator: validator,
      onSaved: onSaved,
      keyboardType: keyboardType,
    );
  }

  Widget _buildDatePickerField(BuildContext context) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(
        text: _dateOfBirth == null ? '' : '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
      ),
      decoration: InputDecoration(
        labelText: 'Date of Birth',
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
        filled: true,
        fillColor: Colors.black.withOpacity(0.2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      style: const TextStyle(color: Colors.white),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _dateOfBirth ?? DateTime(2000),
          firstDate: DateTime(1920),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: Color(0xFF8E2DE2), onPrimary: Colors.white)), child: child!); // Themed Date Picker
          },
        );
        if (date != null) setState(() => _dateOfBirth = date);
      },
    );
  }

  Widget _buildSubmitButton(bool isSignIn) {
    return ElevatedButton(
      onPressed: _submitAuthForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF4A00E0),
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.4),
      ),
      child: Text(isSignIn ? 'Sign In' : 'Create Account', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }

  Widget _buildGoogleSignInButton() {
    return OutlinedButton.icon(
      onPressed: _signInWithGoogle,
      icon: Image.asset('assets/google.png', height: 22.0),
      label: const Text('Sign in with Google', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white70, width: 1.5),
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget _buildAuthModeSwitch(bool isSignIn) {
    return TextButton(
      onPressed: () {
        _formKey.currentState?.reset();
        _dateOfBirth = null;
        setState(() {
          _authMode = isSignIn ? AuthMode.signUp : AuthMode.signIn;
        });
      },
      child: Text(
        isSignIn ? 'Don\'t have an account? Sign Up' : 'Already have an account? Sign In',
        style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
      ),
    );
  }
}
