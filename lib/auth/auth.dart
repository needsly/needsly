import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:needsly/views/categories.dart';

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return CategoriesPage(); // user logged in
        } else {
          return LoginPage(); // show login
        }
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  Future<UserCredential> signInWithGoogle() async {
    // Google sign-in works directly in browser for Flutter Web
    GoogleAuthProvider googleProvider = GoogleAuthProvider();
    return await FirebaseAuth.instance.signInWithPopup(googleProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: signInWithGoogle,
        child: Text("Sign in with Google"),
      ),
    );
  }
}
