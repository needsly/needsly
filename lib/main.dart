import 'package:flutter/material.dart';
import 'package:needsly/repository/db.dart';
import 'package:needsly/repository/prefs.dart';
import 'package:needsly/views/categories.dart';
import 'package:provider/provider.dart';

void main() => runApp(
  MultiProvider(
    providers: [
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CategoriesPage()));
  }
}
