import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  void setValue(OAuthCredential? cred) {
    credential = cred;
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
    final googleSignIn = Provider.of<GoogleSignIn>(ctx, listen: false);
    final signedInGoogleUser = await googleSignIn.signIn();
    // User canceled auth
    if (signedInGoogleUser == null) return null;
    return _getCredential(signedInGoogleUser);
  }

  Future<OAuthCredential?> _trySignIn(BuildContext ctx) async {
    final googleCredential = await _signInWithGoogle(ctx);
    if (googleCredential != null) {
      print(
        "Signed in with credential: accessToken=${googleCredential.accessToken} idToken=${googleCredential.idToken}",
      );
    }
    return googleCredential;
  }

  @override
  Widget build(BuildContext context) {
    final googleCredentialProvider = context.read<GoogleCredentialProvider>();
    print(
      '2 [DEBUG] Context: ${context.hashCode} googleCredentialProvider: ${googleCredentialProvider.hashCode}',
    );
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          final credential = await _trySignIn(context);
          googleCredentialProvider.setValue(credential);
          if (!context.mounted) return;
          Navigator.pop(context);
        },
        child: Text("Sign in with Google"),
      ),
    );
  }
}
