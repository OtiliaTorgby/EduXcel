import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

// Function to handle Google Sign-In
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn;

      // Initialize GoogleSignIn with clientId only for web
      if (kIsWeb) {
        googleSignIn = GoogleSignIn(
          clientId: "947251316245-t6f5iotprj122jrc9r8pddltl8rf9b2h.apps.googleusercontent.com", // PASTE YOUR WEB CLIENT ID HERE
        );
      } else {
        googleSignIn = GoogleSignIn(); // For Android/iOS, no clientId needed here
      }

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in with Google: $e')),
      );
    }
  }

  // Function to handle Sign-Out
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut(); // Also sign out from Google
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EduXcel Firebase App'),
        actions: [
          if (_user != null) // Show sign-out button only if user is logged in
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
            if (_user == null) // Show sign-in button if no user is logged in
              ElevatedButton.icon(
                icon: Image.asset(
                  'assets/google.png', // You'll need to add a Google logo asset
                  height: 24.0,
                ),
                label: const Text('Sign In with Google'),
                onPressed: _signInWithGoogle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              )
            else // Show user info if logged in
              Column(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(_user!.photoURL ?? 'https://www.gravatar.com/avatar?d=mp'),
                    radius: 40,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome, ${_user!.displayName ?? _user!.email}!',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'UID: ${_user!.uid}',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
