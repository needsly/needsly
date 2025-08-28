import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:needsly/repository/firestore.dart';
import 'package:needsly/repository/prefs.dart';
import 'package:needsly/views/shared/shared_documents.dart';
import 'package:provider/provider.dart';

class GoogleSignInPage extends StatelessWidget {
  final String projectName;

  const GoogleSignInPage({required this.projectName});

  Future<OAuthCredential> _getGoogleUserCredential(String token) async {
    return GoogleAuthProvider.credential(accessToken: null, idToken: token);
  }

  Future<AuthCredential?> _signInWithGoogle(FirebaseAuth auth) async {
    GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
    // Triggers a sign-in popup
    // If authentication is not successfull error will be triggered
    final userCredential = await auth.signInWithPopup(googleAuthProvider);
    return userCredential.credential;
  }

  Widget _signInForm(BuildContext context) {
    final prefs = Provider.of<SharedPreferencesRepository>(context);
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

        final googleCredential = await _signInWithGoogle(firebaseAuth);
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

  Future<OAuthCredential?> _getAlreadySignedInCredential(
    FirebaseApp? app,
  ) async {
    if (app == null) {
      return null;
    }
    final User? user = FirebaseAuth.instanceFor(app: app).currentUser;
    if (user == null) return null;
    final token = await user.getIdToken();
    if (token == null) {
      return null;
    }
    return _getGoogleUserCredential(token);
  }

  @override
  Widget build(BuildContext context) {
    final projectToApp = Provider.of<Map<String, FirebaseApp>>(context);
    final app = projectToApp[projectName];
    return FutureBuilder(
      future: _getAlreadySignedInCredential(app),
      builder: (ctx, cred) {
        if (cred.hasData && cred.data != null) {
          if (app != null) {
            final firebaseAuth = FirebaseAuth.instanceFor(app: app);
            final currentUser = firebaseAuth.currentUser;
            if (currentUser != null) {
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
        }
        return _signInForm(context);
      },
    );
  }
}

Widget getGoogleSignInPage(String projectName) {
  return GoogleSignInPage(projectName: projectName);
}
