// home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'sign_in_screen.dart'; // Import the new sign-in screen

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user; // Stores the current signed-in user

  @override
  void initState() {
    super.initState();
    // Listen to Firebase Authentication state changes
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _user = user;
      });
    });
  }

  // Function to handle Sign-Out
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    // Also sign out from Google if they used it to sign in
    // Note: GoogleSignIn().signOut() is safe to call even if they didn't use Google
    await GoogleSignIn().signOut();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed out successfully! 👋')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      // If no user is logged in, show the SignInScreen
      return const SignInScreen();
    } else {
      // If a user is logged in, show the main application content
      return Scaffold(
        appBar: AppBar(
          title: const Text('EduXcel App - Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _signOut,
              tooltip: 'Sign Out',
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                backgroundImage: NetworkImage(
                    _user!.photoURL ??
                        'https://www.gravatar.com/avatar?d=mp'),
                radius: 50,
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome, ${_user!.displayName ?? _user!.email!.split('@')[0]}!',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Email: ${_user!.email}',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'UID: ${_user!.uid}',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text('You are successfully authenticated!'),
            ],
          ),
        ),
      );
    }
  }
}