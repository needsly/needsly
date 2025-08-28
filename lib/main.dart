import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:needsly/db/db.dart';
import 'package:needsly/repository/prefs.dart';
import 'package:needsly/views/personal/categories.dart';
import 'package:needsly/views/shared/shared_projects.dart';
import 'package:provider/provider.dart';

void main() => runApp(
  MultiProvider(
    providers: [
      Provider<GoogleSignIn>(
        create: (_) => GoogleSignIn(
          scopes: ['email', 'profile'],
          // clientId:
          // '65855428233-akgqmb2jsa88umj1qo2i1iinenh25806.apps.googleusercontent.com',
        ),
      ),
      Provider<Map<String, FirebaseApp>>(
        create: (_) => <String, FirebaseApp>{},
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

  final _pages = [CategoriesPage(), SharedProjectsPage()];

  void _onItemTapped(int index) async {
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
