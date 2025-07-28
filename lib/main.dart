import 'package:flutter/material.dart';
import 'package:needsly/views/categories.dart';

void main() => runApp(NeedslyApp());

class NeedslyApp extends StatelessWidget {
  const NeedslyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: BottomTabsPage());
  }
}

class BottomTabsPage extends StatefulWidget {
  const BottomTabsPage({super.key});

  @override
  BottomTabsPageState createState() => BottomTabsPageState();
}

class BottomTabsPageState extends State<BottomTabsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CategoriesPage()));
  }
}
