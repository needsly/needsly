import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:needsly/views/shared/shared_projects.dart';
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

class GoogleCredentialProvider with ChangeNotifier {
  OAuthCredential? credential;

  GoogleCredentialProvider({this.credential});

  void setValue(OAuthCredential? credential) {
    credential = credential;
    notifyListeners();
  }
}

class GoogleSignInPage extends StatelessWidget {
  Future<OAuthCredential> _getCredential(
    GoogleSignInAccount signedInGoogleUser,
  ) async {
    final googleAuth = await signedInGoogleUser.authentication;
    return GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
  }

  Future<OAuthCredential?> _signInWithGoogle(BuildContext ctx) async {
    // // Check whether the user is already logged in via google
    // final previouslySignedInGoogleUser = await _googleSignIn.signInSilently();
    // if (previouslySignedInGoogleUser == null) {
    // Force authentication via google sign-in form
    final googleSignIn = Provider.of<GoogleSignIn>(ctx, listen: false);
    final signedInGoogleUser = await googleSignIn.signIn();
    // User canceled auth
    if (signedInGoogleUser == null) return null;
    return _getCredential(signedInGoogleUser);
    // }
    // return _getCredential(previouslySignedInGoogleUser);
    // final userCredential = await FirebaseAuth.instance.signInWithCredential(
    //   credential,
    // );
  }

  // Future<OAuthCredential?> _getAlreadySignedInUser(BuildContext ctx) async {
  //   // Check whether the user is already logged in via google
  //   final googleSignIn = Provider.of<GoogleSignIn>(ctx, listen: false);
  //   final previouslySignedInGoogleUser = await googleSignIn.signInSilently();
  //   if (previouslySignedInGoogleUser == null) return null;
  //   return _getCredential(previouslySignedInGoogleUser);
  // }

  Future<OAuthCredential?> _trySignIn(BuildContext ctx) async {
    final googleCredential = await _signInWithGoogle(ctx);
    if (googleCredential != null) {
      print(
        "Signed in with credential: accessToken=${googleCredential.accessToken} idToken=${googleCredential.idToken}",
      );
      // Update GoogleCredentialProvider
      ctx.read<GoogleCredentialProvider>().setValue(googleCredential);
    }
    return googleCredential;
  }

  Widget _getSignInForm(BuildContext ctx) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          final credential = await _trySignIn(ctx);
          Navigator.pop(ctx);
          // Navigator.push(
          //   ctx,
          //   MaterialPageRoute(
          //     builder: (_) {
          //       // return InheritedProvider<GoogleCredentialProvider>(
          //       //   create: (_) =>
          //       //       GoogleCredentialProvider(credential: credential),
          //       //   child: SharedProjectsPage(),
          //       // );
          //     },
          //   ),
          // );
        },
        child: Text("Sign in with Google"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getSignInForm(context);

    // return FutureBuilder(
    //   future: _getAlreadySignedInUser(context),
    //   builder: (ctx, cred) {
    //     if (cred.connectionState == ConnectionState.waiting) {
    //       return const Center(child: CircularProgressIndicator());
    //     }
    //     if (cred.hasData && cred.data!.accessToken != null) {
    //       print(
    //         "Already signed in with credential: accessToken=${cred.data!.accessToken} idToken=${cred.data!.idToken}",
    //       );
    //       context.read<GoogleCredentialProvider>().setValue(
    //         cred.data!.accessToken,
    //         cred.data!.idToken,
    //       );
    //       // Navigator.push(
    //       //   context,
    //       //   MaterialPageRoute(builder: (_) => SharedProjectsPage()),
    //       // );
    //       return Center();
    //     } else {
    //       print('not signed in');
    //       return signInForm;
    //     }
    //   },
    // );
  }
}
