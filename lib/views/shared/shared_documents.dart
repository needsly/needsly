import 'package:flutter/material.dart';
import 'package:needsly/auth/google_signin.dart';
import 'package:provider/provider.dart';

class SharedDocumentsPage extends StatefulWidget {
  final String projectName;

  const SharedDocumentsPage({super.key, required this.projectName});

  @override
  State<StatefulWidget> createState() =>
      SharedDocumentsPageState(projectName: projectName);
}

class SharedDocumentsPageState extends State<SharedDocumentsPage> {
  final String projectName;

  SharedDocumentsPageState({required this.projectName});

  @override
  void initState() {
    // Check if a connection to the project exists
    // If so - reuse it
    // Otherwise - connect to the project using existing google token
    // In case of connection issues - alert
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Project $projectName documents')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 12),
            // Display documents in the project
          ],
        ),
      ),
    );
  }
}
