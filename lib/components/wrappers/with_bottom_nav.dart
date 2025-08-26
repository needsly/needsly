import 'package:flutter/material.dart';

class WithBottomNav extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const WithBottomNav({
    required this.body,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: onTabSelected,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: ''),
        ],
      ),
    );
  }
}
