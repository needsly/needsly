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
  String? token;
  String? idToken;

  GoogleCredentialProvider({this.token, this.idToken});

  void setValue(String? token, String? idToken) {
    token = token;
    idToken = idToken;
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

  Future<OAuthCredential?> _getAlreadySignedInUser(BuildContext ctx) async {
    // Check whether the user is already logged in via google
    final googleSignIn = Provider.of<GoogleSignIn>(ctx, listen: false);
    final previouslySignedInGoogleUser = await googleSignIn.signInSilently();
    if (previouslySignedInGoogleUser == null) return null;
    return _getCredential(previouslySignedInGoogleUser);
  }

  Future<void> _trySignIn(BuildContext ctx) async {
    final googleCredential = await _signInWithGoogle(ctx);
    if (googleCredential != null) {
      print(
        "Signed in with credential: accessToken=${googleCredential.accessToken} idToken=${googleCredential.idToken}",
      );
      // Update GoogleCredentialProvider
      final googleCredentialProvider = Provider.of<GoogleCredentialProvider>(
        ctx,
        listen: false,
      );
      googleCredentialProvider.setValue(
        googleCredential.accessToken,
        googleCredential.idToken,
      );
    }
  }

  Widget _getSignInForm(BuildContext ctx) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          await _trySignIn(ctx);
          Navigator.pop(ctx);
        },
        child: Text("Sign in with Google"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final signInForm = _getSignInForm(context);
    return FutureBuilder(
      future: _getAlreadySignedInUser(context),
      builder: (ctx, cred) {
        if (cred.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (cred.hasData && cred.data!.accessToken != null) {
          print(
            "Already signed in with credential: accessToken=${cred.data!.accessToken} idToken=${cred.data!.idToken}",
          );
          final googleCredentialProvider =
              Provider.of<GoogleCredentialProvider>(ctx, listen: false);
          googleCredentialProvider.setValue(
            cred.data!.accessToken,
            cred.data!.idToken,
          );
          return SharedProjectsPage();
        } else {
          print('not signed in');
          return signInForm;
        }
      },
    );
  }
}
