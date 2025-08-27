import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:needsly/auth/google_signin.dart';
import 'package:needsly/repository/db.dart';
import 'package:needsly/repository/prefs.dart';
import 'package:needsly/views/personal/categories.dart';
import 'package:needsly/views/shared/shared_projects.dart';
import 'package:provider/provider.dart';

void main() => runApp(
  MultiProvider(
    providers: [
      Provider<GoogleSignIn>(create: (_) => GoogleSignIn(scopes: ['email'])),
      ChangeNotifierProvider<GoogleCredentialProvider>(
        create: (_) => GoogleCredentialProvider(),
      ),
      Provider<DatabaseRepository>(create: (_) => DatabaseRepository()),
      Provider<SharedPreferencesRepository>(
        create: (_) => SharedPreferencesRepository(),
      ),
    ],
    child: NeedslyApp(),
  ),
);

class NeedslyApp extends StatelessWidget {
  const NeedslyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: NeedslyAppPage());
  }
}

class NeedslyAppPage extends StatefulWidget {
  const NeedslyAppPage({super.key});

  @override
  NeedslyAppPageState createState() => NeedslyAppPageState();
}

class NeedslyAppPageState extends State<NeedslyAppPage> {
  int _selectedIndex = 0;

  final Widget categoriesPage = CategoriesPage();
  final Widget googleSignInPage = GoogleSignInPage();
  final Widget sharedProjectsPage = SharedProjectsPage();

  Future<OAuthCredential> getGoogleCredential(
    GoogleSignInAccount signedInGoogleUser,
  ) async {
    final googleAuth = await signedInGoogleUser.authentication;
    return GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
  }

  Future<OAuthCredential?> getAlreadySignedInCredential(
    BuildContext context,
  ) async {
    final googleSignIn = Provider.of<GoogleSignIn>(context, listen: false);
    final previouslySignedInGoogleUser = await googleSignIn.signInSilently();
    if (previouslySignedInGoogleUser == null) return null;
    final alreadySignedInCredential = await getGoogleCredential(
      previouslySignedInGoogleUser,
    );
    print(
      "Already signed in with credential: accessToken=${alreadySignedInCredential.accessToken} idToken=${alreadySignedInCredential.idToken}",
    );
    return alreadySignedInCredential;
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getTargetPage(OAuthCredential? credential) {
    if (_selectedIndex == 1) {
      // Shared projects tab is tapped
      if (credential?.accessToken != null) {
        return sharedProjectsPage;
      }
      return googleSignInPage;
    }
    return categoriesPage;
  }

  Future<OAuthCredential?> updateCredential(
    GoogleCredentialProvider provider,
    OAuthCredential? credential,
  ) async {
    if (credential != null) {
      provider.setValue(credential);
    }
    return credential;
  }

  Widget getBody(
    AsyncSnapshot<OAuthCredential?> snapshot,
    GoogleCredentialProvider googleCredentialProvider,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    print(
      '1 [DEBUG] Context: ${context.hashCode} googleCredentialProvider: ${googleCredentialProvider.hashCode}',
    );
    return _getTargetPage(snapshot.data);
  }

  @override
  Widget build(BuildContext context) {
    final googleCredentialProvider = context.read<GoogleCredentialProvider>();
    return Scaffold(
      body: FutureBuilder(
        future: getAlreadySignedInCredential(context).then((cred) {
          return updateCredential(googleCredentialProvider, cred);
        }),
        builder: (_, snapshot) {
          return getBody(snapshot, googleCredentialProvider);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: ''),
        ],
      ),
    );
  }
}
