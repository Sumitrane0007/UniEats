import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async {
    return await auth.currentUser;
  }

  Future<void> SignOut(BuildContext context) async {
    try {
      await auth.signOut();
      print("User signed out successfully");

      // ✅ Redirect user to the login screen
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false, // Clears navigation stack
      );
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  Future deleteuser() async {
    User? user = await FirebaseAuth.instance.currentUser;
    user?.delete();
  }
}
