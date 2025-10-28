// home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async'; // <-- 1. Import dart:async for StreamSubscription
import 'sign_in_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user;
  // 2. Declare a variable to hold the stream subscription
  late final StreamSubscription<User?> _authStateSubscription;

  @override
  void initState() {
    super.initState();

    // 3. Store the subscription when you start listening
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      // 4. Always check if the widget is mounted before calling setState
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    });
  }

  // 5. Override dispose() to cancel the subscription
  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  Future<void> _signOut() async {
    // Note: The GoogleSignIn initialization error (ClientID not set)
    // must be fixed in your web/index.html file or main.dart.
    await FirebaseAuth.instance.signOut();
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
      // It is good practice to ensure this navigator push replacement
      // is not happening when the widget is still in the process of building.
      // However, since the build method is returning a different screen, this is usually fine.
      return const SignInScreen();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('EduXcel Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _signOut,
              tooltip: 'Sign Out',
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    _user!.photoURL ??
                        'https://www.gravatar.com/avatar?d=mp',
                  ),
                  radius: 50,
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome, ${_user!.displayName ?? _user!.email!.split('@')[0]}!',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Email: ${_user!.email}',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // ✅ Navigation buttons
                ElevatedButton.icon(
                  icon: const Icon(Icons.person),
                  label: const Text('Go to Profile'),
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.notifications),
                  label: const Text('View Notifications'),
                  onPressed: () {
                    Navigator.pushNamed(context, '/notifications');
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'You are successfully authenticated!',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}