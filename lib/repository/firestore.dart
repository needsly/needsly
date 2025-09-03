import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:needsly/utils/utils.dart';

class FirestoreRepository {
  FirebaseFirestore firestore;

  FirestoreRepository({required this.firestore});

  Future<int> getLatestVersion(String collection, String document) async {
    final versionDynamic = await firestore
        .collection(collection)
        .doc(document)
        .get()
        .then((snapshot) {
          return snapshot.data()?.values.last;
        });

    final int? version = int.tryParse(versionDynamic);
    if (version.runtimeType != int) {
      throw Exception('`version` field has invalid type!');
    }
    return version!;
  }

  Future<List<String>> listDocuments(String collection) async {
    final docNames = await firestore.collection(collection).get().then((
      snapshot,
    ) {
      return snapshot.docs.map((docSnapshot) => docSnapshot.id);
    });
    return docNames.toList();
  }

  Future<Map<String, List<String>>> listItemsByDocuments(
    String collection,
  ) async {
    final itemsByDocuments = await firestore.collection(collection).get().then((
      snapshot,
    ) {
      final docSnapshots = snapshot.docs;
      return docSnapshots.fold<Map<String, List<String>>>({}, (prev, next) {
        final docName = next.id;
        final docItemsDynamic = next.get('items');
        final items = toStringList(docItemsDynamic);
        prev[docName] = items;
        return prev;
      });
    });
    return itemsByDocuments;
  }

  Future<List<dynamic>> listItems(String collection, String document) async {
    final res = firestore.collection(collection).doc(document).get().then((
      snapshot,
    ) {
      final items = snapshot.data()?.values ?? [];
      return items.toList();
    });
    return res;
  }

  Future<void> addDocument(String collection, String document) async {
    firestore.collection(collection).doc(document).set({
      "items": [],
    }, SetOptions(merge: true));
  }

  Future<void> deleteDocument(String collection, String document) async {
    firestore.collection(collection).doc(document).delete();
  }

  Future<void> overwriteDocument(
    String collection,
    String document,
    Map<String, dynamic> items,
  ) async {
    firestore.collection(collection).doc(document).set(items);
  }

  Future<void> updateDocumentWithMerge(
    String collection,
    String document,
    Map<String, dynamic> items,
  ) async {
    firestore.collection(collection).doc(document).set(items);
  }
}
