import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../screens/Login/login_screen.dart';

class LogoutUtils {
  /// Performs logout while preserving Remember Me credentials
  static Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Preserve Remember Me credentials
    bool? rememberMe = prefs.getBool('rememberMe');
    String? savedEmail = prefs.getString('savedEmail');
    String? savedPassword = prefs.getString('savedPassword');

    // Clear all preferences
    prefs.clear();

    // Restore Remember Me credentials if they exist
    if (rememberMe == true && savedEmail != null && savedPassword != null) {
      await prefs.setBool('rememberMe', true);
      await prefs.setString('savedEmail', savedEmail);
      await prefs.setString('savedPassword', savedPassword);
    }

    // Navigate to login screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login_Screen()),
      (route) => false,
    );
  }

  /// Performs logout and clears ALL data including Remember Me (for account deactivation)
  static Future<void> logoutAndClearAll(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login_Screen()),
      (route) => false,
    );
  }
}
