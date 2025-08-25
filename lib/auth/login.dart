import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:needsly/views/shared_projects.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

// class AuthGate extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           // user logged in
//           return CategoriesPage();
//         } else {
//           // show login form
//           return LoginPage();
//         }
//       },
//     );
//   }
// }

class LoginPage extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<OAuthCredential> _getCredential(
    GoogleSignInAccount signedInGoogleUser,
  ) async {
    final googleAuth = await signedInGoogleUser.authentication;
    return GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
  }

  Future<OAuthCredential?> signInWithGoogle() async {
    // // Check whether the user is already logged in via google
    // final previouslySignedInGoogleUser = await _googleSignIn.signInSilently();
    // if (previouslySignedInGoogleUser == null) {
    // Force authentication via google sign-in form
    final signedInGoogleUser = await _googleSignIn.signIn();
    // User canceled auth
    if (signedInGoogleUser == null) return null;
    return _getCredential(signedInGoogleUser);
    // }
    // return _getCredential(previouslySignedInGoogleUser);
    // final userCredential = await FirebaseAuth.instance.signInWithCredential(
    //   credential,
    // );
  }

  Future<OAuthCredential?> getAlreadySignedInUser() async {
    // Check whether the user is already logged in via google
    final previouslySignedInGoogleUser = await _googleSignIn.signInSilently();
    if (previouslySignedInGoogleUser == null) return null;
    return _getCredential(previouslySignedInGoogleUser);
  }

  Widget getSignInForm(BuildContext ctx) {
    return ElevatedButton(
      onPressed: () async {
        final googleCredential = await signInWithGoogle();
        if (googleCredential != null) {
          print(
            "Signed in with credential: accessToken=${googleCredential.accessToken} idToken=${googleCredential.idToken}",
          );
        }
        Navigator.pop(
          ctx,
          Provider<OAuthCredential?>(
            create: (_) => googleCredential,
            child: SharedProjectsPage(),
          ),
        );
      },
      child: Text("Sign in with Google"),
    );
  }

  @override
  Widget build(BuildContext context) {
    final signInForm = getSignInForm(context);
    return FutureBuilder(
      future: getAlreadySignedInUser(),
      builder: (ctx, cred) {
        if (cred.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (cred.hasData &&
            cred.data!.idToken != null &&
            cred.data!.accessToken != null) {
          print(
            "Already signed in with credential: accessToken=${cred.data!.accessToken} idToken=${cred.data!.idToken}",
          );
          return Provider<OAuthCredential?>(
            create: (_) => cred.data,
            child: SharedProjectsPage(),
          );
        } else {
          return signInForm;
        }
      },
    );
  }
}
