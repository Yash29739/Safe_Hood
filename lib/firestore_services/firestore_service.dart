// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> loginUser({
    required String? email,
    required String? password,
  }) async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection(
        "users",
      );

      QuerySnapshot? snapshot =
          await users.where("email", isEqualTo: email).limit(1).get();

      if (snapshot.docs.isEmpty) {
        return 'User not found';
      }

      // Extract user data
      Map<String, dynamic> userData =
          snapshot.docs.first.data() as Map<String, dynamic>;
      String? hashedPassword = userData["password"];
      String? flatCode = userData["flatCode"];
      String? userName = userData["name"];

      // Verify the password usng bcrypt
      bool passwordMatched = BCrypt.checkpw(password!, hashedPassword!);
      if (!passwordMatched) {
        return 'Invalid Credentials';
      }

      // Save login session
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("userId", email!);
      await prefs.setString("userName", userName!);
      await prefs.setString("flatCode", flatCode!);
      await prefs.setBool("isLoggedIn", true);

      // Updating status of login
      await updateUserLoginStatus(prefs.getString('userId'), true);

      // Creating user logs
      await FirebaseFirestore.instance.collection('userLogs').doc(email).set({
        'email': email,
        'action': "Login",
        'timestamp': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return e.toString(); // unsuccessful
    }
  }

  // Login or Logout status update in database
  Future<void> updateUserLoginStatus(String? userId, bool isLoggedIn) async {
    // Update user login status in Firestore
    await _firestore.collection("users").doc(userId).update({
      "isLoggedIn": isLoggedIn,
    });
  }
}
