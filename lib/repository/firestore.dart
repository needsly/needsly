import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreRepository {
  FirebaseFirestore firestore;

  FirestoreRepository({required this.firestore});

  void listDocuments(String collection) async {
    final res = firestore.collection(collection).get().then((snapshot) {
      for (var doc in snapshot.docs) {
        print("${doc.id} => ${doc.data()}");
      }
    });
    return await res;
  }

  Future<dynamic> listItems(String collection, String document) async {
    final res = firestore.collection(collection).doc(document).get().then((
      snapshot,
    ) {
      final items = snapshot.data()?.values ?? [];
      for (var i in items) {
        print("$i");
      }
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
