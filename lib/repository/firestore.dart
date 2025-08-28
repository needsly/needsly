import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreRepository {
  FirebaseFirestore firestore;

  FirestoreRepository({required this.firestore});

  void addDocument(String collection, String document) {
    firestore.collection(collection).doc(document).set({
      "items": [],
    }, SetOptions(merge: true));
  }

  void deleteDocument(String collection, String document) async {
    await firestore.collection(collection).doc(document).delete();
  }

  void overwriteDocument(
    String collection,
    String document,
    Map<String, dynamic> items,
  ) async {
    await firestore.collection(collection).doc(document).set(items);
  }

  void updateDocumentWithMerge(
    String collection,
    String document,
    Map<String, dynamic> items,
  ) async {
    await firestore.collection(collection).doc(document).set(items);
  }
}
