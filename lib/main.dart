// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';

// Screens
import 'sign_in_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/students/notifications_page.dart';
import 'screens/complete_profile_screen.dart';
import 'screens/home_page.dart';
import 'screens/landing_page.dart'; // Import LandingPage

void main() async {
  // Ensure Flutter and Firebase are initialized before the app starts
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Run the app normally
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduXcel Firebase App',

      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF9C27B0),
      ),
      debugShowCheckedModeBanner: false,

      // 🎯 CHANGED: Set initialRoute to '/landing'
      initialRoute: '/landing',

      // Define all app routes
      routes: {
        // 🎯 NEW: '/landing' is now the root view the user sees first
        '/landing': (context) => const LandingPage(),

        // AuthWrapper is now explicitly navigated to from the landing page or when needed
        '/': (context) => const AuthWrapper(),

        // Define explicit routes for navigation
        '/sign-in': (context) => const SignInScreen(), // Explicit sign-in route
        '/home': (context) => HomePage(),
        '/profile': (context) => const ProfileScreen(),
        '/notifications': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as String?;
          final role = args ?? 'student'; // default to student if no argument
          return NotificationsPage(role: role);
        },

        '/complete-profile': (context) => const CompleteProfileScreen(),
      },
      // Fallback route handler (optional, but good practice)
      onUnknownRoute: (settings) => MaterialPageRoute(builder: (context) => const AuthWrapper()),
    );
  }
}

// A simple wrapper to handle the initial routing based on Auth State
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // We use a StreamBuilder to react to real-time authentication state changes
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a splash screen or loading indicator while checking auth status
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF9C27B0)),
            ),
          );
        }

        final user = snapshot.data;

        if (user != null) {
          // Check if the email has been verified.
          if (user.emailVerified) {
            // Direct verified authenticated users to HomePage.
            return HomePage();
          } else {
            // If authenticated but NOT verified: Force them to the sign-in screen.
            return const SignInScreen();
          }

        } else {
          // Not signed in
          return const SignInScreen();
        }

      },
    );
  }
}