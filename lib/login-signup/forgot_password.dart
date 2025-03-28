import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:safe_hood/login-signup/login_screen.dart';
import 'package:safe_hood/mainScreens/LandingScreen.dart';
import 'package:safe_hood/widgets/popup.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  void _resetPassword() async {
    String? email = emailController.text;
    String? phonenumber = phoneController.text;
    String? password = passwordController.text;
    String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection("users").doc(email).get();
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        String storedPhone = userData["phone"];
        if (storedPhone == phonenumber) {
          // Update password field
          await FirebaseFirestore.instance.collection("users").doc(email).update({
            "password":
                hashedPassword, // Assuming "password" is the field name in Firestore
          });

          // ignore: use_build_context_synchronously
          Utils.showSuccess("Password updated successfully.", context);
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          // ignore: use_build_context_synchronously
          Utils.showError("Phone number does not match.", context);
        }
      } else {
        // ignore: use_build_context_synchronously
        Utils.showError("User does not exist.", context);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2E3FF),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset('assets/logo.jpg', width: 120),
                ),
                const SizedBox(height: 20),
                Text(
                  "Password Reset",
                  style: TextStyle(
                    fontSize: 30,
                    color: Color(0xFF6A007C),
                    fontWeight: FontWeight.bold,
                    fontFamily: "Merriweather",
                  ),
                ),
                SizedBox(height: 30),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "New Password",
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    labelText: "Confirm Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed:
                        () => {
                          _resetPassword(),
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LandingScreen(),
                            ),
                          ),
                        },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6A007C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      "Reset Password",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
