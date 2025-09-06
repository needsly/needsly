import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:needsly/dto/dto.dart';
import 'package:needsly/utils/utils.dart';

class FirestoreRepository {
  FirebaseFirestore firestore;

  FirestoreRepository({required this.firestore});

  CollectionReference<Map<String, dynamic>> getCollection(String collection) {
    return firestore.collection(collection);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> collectionSnapshots(
    String collection,
  ) {
    return firestore.collection(collection).snapshots();
  }

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

  Future<void> addDocumentWithData(
    String collection,
    String document,
    Map<String, dynamic> data,
  ) async {
    firestore
        .collection(collection)
        .doc(document)
        .set(data, SetOptions(merge: true));
  }

  Future<void> addItem(String collection, String document, String item) async {
    // firestore.collection(collection).doc(document).update({
    //   "items": [item],
    // });
    final fromDocSnapshot = await firestore
        .collection(collection)
        .doc(document)
        .get();
    final data = fromDocSnapshot.data();
    final itemsDynamic = data?["items"] ?? [];
    final items = List<String>.from(itemsDynamic);

    items.add(item);

    await updateDocumentWithData(collection, document, {"items": items});
  }

  Future<void> resolveItem(
    String document,
    String item,
    DateTime resolvedAt,
  ) async {
    final docSnapshot = await firestore
        .collection('resolved')
        .doc(document)
        .get();
    final data = docSnapshot.data();
    final itemsDynamic = data?["items"] ?? [];
    final items = List<Map<String, dynamic>>.from(itemsDynamic);

    items.add({"item": item, "resolved": resolvedAt});

    await updateDocumentWithData('resolved', document, {"items": items});
  }

  Future<void> renameItem(
    String collection,
    String document,
    String fromItem,
    String toItem,
  ) async {
    final fromDocSnapshot = await firestore
        .collection(collection)
        .doc(document)
        .get();
    final data = fromDocSnapshot.data();
    if (data == null) return;
    final itemsDynamic = data["items"];
    final items = List<String>.from(itemsDynamic);

    items.remove(fromItem);
    items.add(toItem);

    await updateDocumentWithData(collection, document, {"items": items});
  }

  Future<void> removeItem(
    String collection,
    String document,
    String item,
  ) async {
    final fromDocSnapshot = await firestore
        .collection(collection)
        .doc(document)
        .get();
    final data = fromDocSnapshot.data();
    if (data == null) return;
    final itemsDynamic = data["items"];
    final items = List<String>.from(itemsDynamic);

    items.remove(item);

    await updateDocumentWithData(collection, document, {"items": items});
  }

  Future<void> deleteDocument(String collection, String document) async {
    firestore.collection(collection).doc(document).delete();
  }

  Future<void> updateDocumentWithData(
    String collection,
    String document,
    Map<String, dynamic> items,
  ) async {
    firestore.collection(collection).doc(document).set(items);
  }

  Future<void> renameDocument(
    String collection,
    String fromDocument,
    String toDocument,
  ) async {
    final fromDocSnapshot = await firestore
        .collection(collection)
        .doc(fromDocument)
        .get();
    final data = fromDocSnapshot.data() ?? {};
    await addDocumentWithData(collection, toDocument, data);
    await deleteDocument(collection, fromDocument);
  }
}
