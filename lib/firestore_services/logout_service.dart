import 'package:shared_preferences/shared_preferences.dart';

// Get user loggedin status
Future<bool> isUserLoggedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool("isLoggedIn") ?? false;
}

// Logout user
Future<void> logoutUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}
