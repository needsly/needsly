import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:needsly/repository/firestore.dart';

class SharedDocumentsPage extends StatefulWidget {
  final String projectName;
  final FirebaseAuth auth;
  final FirestoreRepository firestoreRepository;

  const SharedDocumentsPage({
    super.key,
    required this.projectName,
    required this.auth,
    required this.firestoreRepository,
  });

  @override
  State<StatefulWidget> createState() => SharedDocumentsPageState(
    projectName: projectName,
    auth: auth,
    firestoreRepository: firestoreRepository,
  );
}

class SharedDocumentsPageState extends State<SharedDocumentsPage> {
  final String projectName;
  final FirebaseAuth auth;
  final FirestoreRepository firestoreRepository;

  SharedDocumentsPageState({
    required this.projectName,
    required this.auth,
    required this.firestoreRepository,
  });

  @override
  void initState() {
    // final googleCredentialProvider = context.read<GoogleCredentialProvider>();
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
