import 'package:flutter/material.dart';
import 'package:needsly/categories.dart';
import 'package:needsly/stats.dart';

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
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Center(child: CategoriesPage()),
    Center(child: StatsPage()),
  ];


  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_graph), label: 'Stats')
        ]
      ),
    );
  }
}
