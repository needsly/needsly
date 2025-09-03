import 'package:needsly/repository/firestore.dart';
import 'package:needsly/repository/prefs.dart';
import 'package:needsly/utils/utils.dart';

class SharedSync {
  FirestoreRepository firestoreRepository;
  SharedPreferencesRepository prefs;

  SharedSync({required this.firestoreRepository, required this.prefs});

  Future<Map<String, List<String>>> mergeDocumentSnapshots(
    String project,
  ) async {
    final itemsByDocumentsLocal = await prefs.loadItemsBySubcategories(
      'needsly.firebase.projects',
      project,
    );
    final itemsByDocumentsRemote = await firestoreRepository
        .listItemsByDocuments('active');
    final merged = mergeMaps(itemsByDocumentsRemote, itemsByDocumentsLocal);
    return merged;
  }
}
