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
    // Load docs (~subcategories) and items [from local prefs]
    // Load snapshot version [from local prefs]
    // Load docs and items for `active` collection [from firestore]
    // Load metadata -> snapshot -> version field [from firestore] - last server snapshot version)
    // Merge based on alg described in /docs/sync.md
    // Update [local prefs]
    // Update [firestore]
    print('[init] Project $projectName docs');
    firestoreRepository.listDocuments("active");
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
