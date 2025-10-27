import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Screens
import 'sign_in_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notifications_page.dart';
import 'home_page.dart';

Future<void> main() async {
  // Ensure Flutter and Firebase are initialized before the app starts
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduXcel Firebase App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF9C27B0),
      ),

      // 👇 Set the first screen
      home: const SignInScreen(),

      // 👇 Define routes for smooth navigation
      routes: {
        '/home': (context) => const StudentHomePage(),
        '/profile': (context) => const ProfileScreen(),
        '/notifications': (context) => const NotificationsPage(),
      },
    );
  }
}
