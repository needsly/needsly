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
  // final List<Widget> _pages = [
  //   Center(child: CategoriesPage()),
  //   Center(child: GoogleSignInPage()),
  // ];

  Future<OAuthCredential> getGoogleCredential(
    GoogleSignInAccount signedInGoogleUser,
  ) async {
    final googleAuth = await signedInGoogleUser.authentication;
    return GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
  }

  Future<OAuthCredential?> getAlreadySignedInCredential(BuildContext context) async {
    final googleSignIn = Provider.of<GoogleSignIn>(context, listen: false);
    final previouslySignedInGoogleUser = await googleSignIn.signInSilently();
    if (previouslySignedInGoogleUser == null) return null;

    final alreadySignedInCredential = await getGoogleCredential(
      previouslySignedInGoogleUser,
    );
    print(
      "Already signed in with credential: accessToken=${alreadySignedInCredential.accessToken} idToken=${alreadySignedInCredential.idToken}",
    );
    context.read<GoogleCredentialProvider>().setValue(alreadySignedInCredential);
    return alreadySignedInCredential;
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getTargetPage(OAuthCredential? credential, BuildContext ctx) {
    // Shared projects tab is tapped
    if (_selectedIndex == 1) {
      if (credential?.accessToken != null) {
        // return Change<GoogleCredentialProvider>(
        //   create: (_) => GoogleCredentialProvider(credential: credential),
        //   child: SharedProjectsPage(),
        // );
        // ctx.read<GoogleCredentialProvider>().setValue(credential);
        return sharedProjectsPage;
      }
      return googleSignInPage;
    }
    return categoriesPage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getAlreadySignedInCredential(context),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return _getTargetPage(snapshot.data, context);
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
