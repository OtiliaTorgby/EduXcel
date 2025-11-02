// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:device_preview/device_preview.dart';

import 'firebase_options.dart';

// Screens
import 'sign_in_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notifications_page.dart';
import 'screens/complete_profile_screen.dart';
import 'screens/home_page.dart';
import 'screens/admins/admin_page.dart';
import 'screens/landing_page.dart';

void main() async {
  // Ensure Flutter and Firebase are initialized before the app starts
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. Wrap the runApp with DevicePreview
  runApp(
    DevicePreview(
      // Set to false when ready for production or specific platform builds
      enabled: true,
      // The builder function takes the context and returns your root widget (MyApp)
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduXcel Firebase App',
      // 3. Configure MaterialApp to use DevicePreview settings
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context), // Apply device locale settings
      builder: DevicePreview.appBuilder,      // Apply device framing and accessibility features

      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF9C27B0),
      ),
      debugShowCheckedModeBanner: false,

      // Starting the app using the AuthWrapper for initial routing logic
      initialRoute: '/landing',

      // Define all app routes
      routes: {
        // The root route checks auth state and directs the user (AuthWrapper)
        '/': (context) => const AuthWrapper(),
        '/landing': (context) => const LandingPage(),

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
          // ✅ FIX: Remove hardcoded check.
          // Direct all authenticated users to HomePage.
          // The HomePage widget will contain the logic (via ProfileCheckRouter)
          // to route the user based on their Firestore 'role' and 'profileComplete' status.
          return const HomePage();
        } else {
          return const SignInScreen(); // Not signed in
        }

      },
    );
  }
}