import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:unknown/firebase_options.dart';
import 'package:unknown/landingpage.dart';
import 'package:unknown/login.dart';
import 'package:unknown/onboarding.dart';
import 'package:unknown/splash.dart';
import 'utils/permissions_helper.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'utils/app_settings.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request permissions safely
  PermissionsHelper.requestNotificationPermission();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); 

  if (kIsWeb) {
    try {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    } catch (e) {
      debugPrint("Firebase web persistence notice: $e");
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'SwachhSathi',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: AppSettings.instance.themeMode,
          // Define your routes
          routes: {
            '/login': (context) => const Login(),
            '/onboarding': (context) => const Onboarding(),
          },
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showingSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _showingSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showingSplash) {
      return const Splash();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Splash();
        }

        // User is logged in -> Navigate directly to Homepage (Landingpage)
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          final String username = user.displayName ??
              user.email?.split('@').first ??
              "User";
          return Landingpage(username: username);
        }

        // User is not logged in -> Show Onboarding
        return const Onboarding();
      },
    );
  }
}