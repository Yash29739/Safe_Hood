import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:page_transition/page_transition.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:safe_hood/firebase_options.dart';
import 'package:safe_hood/firestore_services/logout_service.dart';
import 'package:safe_hood/login-signup/login_screen.dart';
import 'package:safe_hood/login-signup/signup_screen.dart';
import 'package:safe_hood/mainScreens/LandingScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Safe Hood',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const SplashScreen(),
      routes: {
        '/landingScreen': (context) => const LandingScreen(),
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
  Widget nextScreen = LoginScreen(); // ✅ Default screen

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    bool isLoggedIn = await isUserLoggedIn(); // ✅ Check login status

    if (isLoggedIn) {
      // ✅ Get userId from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("userId");

      if (userId != null) {
        try {
          // ✅ Fetch user data from Firestore
          DocumentSnapshot userDoc =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .get();

          if (userDoc.exists) {
            // ✅ Navigate to LandingScreen if document exists
            setState(() {
              nextScreen = const LandingScreen();
            });
          } else {
            // ❗️ User document not found, navigate to LoginScreen
            setState(() {
              nextScreen = LoginScreen();
            });
          }
        } catch (e) {
          print("Error fetching user data: $e");
          // ❗️ Handle Firestore error, fallback to LoginScreen
          setState(() {
            nextScreen = LoginScreen();
          });
        }
      } else {
        // ❗️ No userId in SharedPreferences, navigate to LoginScreen
        setState(() {
          nextScreen = LoginScreen();
        });
      }
    } else {
      // ❗️ Not logged in, navigate to LoginScreen
      setState(() {
        nextScreen = LoginScreen();
      });
    }
  }

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
              child: Image.asset('assets/logo.jpg', width: 150),
            ),
            const SizedBox(height: 10),
            const Text(
              "SafeHood",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      nextScreen: nextScreen, // ✅ Correctly assigned nextScreen
      splashIconSize: 520,
      centered: true,
      duration: 2000,
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
      animationDuration: const Duration(milliseconds: 2000),
    );
  }
}
