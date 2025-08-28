import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:needsly/auth/google/credential_provider.dart';
import 'package:needsly/repository/firestore.dart';
import 'package:needsly/repository/prefs.dart';
import 'package:needsly/views/shared/shared_documents.dart';
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

class GoogleSignInPage extends StatelessWidget {
  final String projectName;

  const GoogleSignInPage({required this.projectName});

  Future<AuthCredential> _getGoogleUserCredential(
    GoogleSignInAccount signedInGoogleUser,
  ) async {
    final googleAuth = await signedInGoogleUser.authentication;
    return GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
  }

  Future<AuthCredential?> _signInWithGoogle(GoogleSignIn googleSignIn) async {
    final signedInGoogleUser = await googleSignIn.signIn();
    // User canceled auth
    if (signedInGoogleUser == null) return null;
    return _getGoogleUserCredential(signedInGoogleUser);
  }

  Widget _signInForm(BuildContext context) {
    final prefs = Provider.of<SharedPreferencesRepository>(context);
    final googleSignIn = Provider.of<GoogleSignIn>(context, listen: false);
    final projectToApp = Provider.of<Map<String, FirebaseApp>>(context);
    return ElevatedButton(
      onPressed: () async {
        final firebaseProjectOptions = await prefs.loadFirebaseProjectOptions(
          projectName,
        );
        final firebaseApp = await Firebase.initializeApp(
          name: projectName,
          options: firebaseProjectOptions,
        );
        final firebaseAuth = FirebaseAuth.instanceFor(app: firebaseApp);

        final googleCredential = await _signInWithGoogle(googleSignIn);
        if (googleCredential != null) {
          print(
            "Signed in with credential: accessToken=${googleCredential.accessToken} idToken=${googleCredential.idToken}",
          );
          // TODO: catch
          await firebaseAuth.signInWithCredential(googleCredential);
          projectToApp[projectName] = firebaseApp;
        }
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) {
              return SharedDocumentsPage(
                projectName: projectName,
                auth: firebaseAuth,
                firestoreRepository: FirestoreRepository(
                  firestore: FirebaseFirestore.instanceFor(app: firebaseApp),
                ),
              );
            },
          ),
        );
      },
      child: Text("Sign in with Google"),
    );
  }

  Future<AuthCredential?> _getAlreadySignedInCredential(
    GoogleSignIn googleSignIn,
  ) async {
    final previouslySignedInGoogleUser = await googleSignIn.signInSilently();
    if (previouslySignedInGoogleUser == null) return null;
    final alreadySignedInCredential = await _getGoogleUserCredential(
      previouslySignedInGoogleUser,
    );
    print(
      "Already signed in with credential: accessToken=${alreadySignedInCredential.accessToken} token=${alreadySignedInCredential.token}",
    );
    return alreadySignedInCredential;
  }

  @override
  Widget build(BuildContext context) {
    final googleSignIn = Provider.of<GoogleSignIn>(context, listen: false);
    final projectToApp = Provider.of<Map<String, FirebaseApp>>(context);
    final app = projectToApp[projectName];
    return FutureBuilder(
      future: _getAlreadySignedInCredential(googleSignIn),
      builder: (ctx, cred) {
        if (cred.hasData && cred.data != null) {
          // Already signed in
          if (app != null) {
            final firebaseAuth = FirebaseAuth.instanceFor(app: app);
            final currentUser = firebaseAuth.currentUser;
            if (currentUser != null) {
              return SharedDocumentsPage(
                projectName: projectName,
                auth: firebaseAuth,
                firestoreRepository: FirestoreRepository(
                  firestore: FirebaseFirestore.instanceFor(app: app),
                ),
              );
            }
          }
        }
        return _signInForm(context);
      },
    );
  }
}

Widget getGoogleSignInPage(String projectName) {
  return GoogleSignInPage(projectName: projectName);
}
