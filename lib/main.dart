import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:needsly/auth/google_signin.dart';
import 'package:needsly/repository/db.dart';
import 'package:needsly/repository/prefs.dart';
import 'package:needsly/views/personal/categories.dart';
import 'package:provider/provider.dart';

void main() => runApp(
  MultiProvider(
    providers: [
      Provider<GoogleSignIn>(create: (_) => GoogleSignIn(scopes: ['email'])),
      Provider<GoogleCredentialProvider>(create: (_) => GoogleCredentialProvider()),
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

  final List<Widget> _pages = [
    Center(child: CategoriesPage()),
    Center(child: GoogleSignInPage()),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
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
