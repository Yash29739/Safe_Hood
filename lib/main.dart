import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:safe_hood/login-signup/login_screen.dart';
import 'package:safe_hood/login-signup/signup_screen.dart';
import 'package:safe_hood/users/LandingScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeHood',
      theme: ThemeData(primarySwatch: Colors.purple),

      home: const SplashScreen(),
      routes: {
        '/landingScreen': (content) => const LandingScreen(),
        '/signup': (context) => const SignupScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      backgroundColor: Colors.purple,
      splash: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset('assets/logo.j pg', width: 150),
            ),
            SizedBox(height: 10),
            Text(
              'SafeHood',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      nextScreen: LoginScreen(),
      splashIconSize: 520,
      centered: true,
      duration: 2000,
      splashTransition: SplashTransition.fadeTransition,
      animationDuration: Duration(milliseconds: 2000),
    );
  }
}
