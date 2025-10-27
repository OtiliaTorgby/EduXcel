// home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'sign_in_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _user = user;
      });
    });
  }

  Future<void> _signOut() async {
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
