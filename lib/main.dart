import 'package:flutter/material.dart';
import 'package:needsly/views/categories.dart';

void main() => runApp(NeedslyApp());

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
