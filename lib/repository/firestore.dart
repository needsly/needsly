import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

class FirestoreRepository {
  FirebaseFirestore firestore;

  FirestoreRepository({required this.firestore});

  Stream<QuerySnapshot<Map<String, dynamic>>> collectionSnapshots(
    String collection,
  ) {
    return firestore.collection(collection).snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> documentSnapshots(
    String collection,
    String document,
  ) {
    return firestore.collection(collection).doc(document).snapshots();
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
    final itemsDynamic = data?["items"] ?? {};
    final items = Map<String, dynamic>.from(itemsDynamic);

    items.putIfAbsent(item, () => resolvedAt);

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
    final fromDocRef = firestore.collection(collection).doc(fromDocument);
    final toDocRef = firestore.collection(collection).doc(toDocument);
    firestore.runTransaction((transaction) async {
      final fromDocSnapshot = await transaction.get(fromDocRef);
      final data = fromDocSnapshot.data() ?? {};
      transaction.set(toDocRef, data);
      transaction.delete(fromDocRef);
    });
  }

  Future<void> cleanOutdatedResolved(
    Map<String, Timestamp> resolvedByEmail,
  ) async {
    final allowedUsersCollectionSnap = await firestore
        .collection('allowed_users')
        .get();
    final allowedUsers = allowedUsersCollectionSnap.docs
        .map((doc) => doc.id)
        .toList();

    final unorderedEquals = const UnorderedIterableEquality().equals;
    final shouldBeCleanedUp = unorderedEquals(
      allowedUsers,
      resolvedByEmail.keys,
    );
    print(
      '[Clean outdated resolved] allowedUsers=$allowedUsers resolvedByEmail=${resolvedByEmail.keys} shouldBeCleanedUp=$shouldBeCleanedUp',
    );
    if (!shouldBeCleanedUp) return;
    // cleanup

    final earliestSynced = resolvedByEmail.entries.reduce((prev, next) {
      return prev.value.compareTo(next.value) < 0 ? prev : next;
    }).value;
    print(
      '[Clean outdated resolved] resolvedByEmail timestamps=${resolvedByEmail.values} earliestSynced=$earliestSynced',
    );

    final resolvedCollectionSnap = await firestore.collection('resolved').get();
    for (var docSnap in resolvedCollectionSnap.docs) {
      final data = docSnap.data();
      final itemsDynamic = data["items"] ?? {};
      final items = Map<String, Timestamp>.from(itemsDynamic);
      print(
        '[Clean outdated resolved] doc=${docSnap.id} resolved items before cleanup: $items',
      );
      // Clean all items which were resolved earlier than the `earliestSynced` timestamp.
      // So, we want to
      items.removeWhere((item, resolved) {
        return resolved.compareTo(earliestSynced) < 0;
      });
      print(
        '[Clean outdated resolved] doc=${docSnap.id} resolved items after cleanup: $items',
      );
      updateDocumentWithData('resolved', docSnap.id, items);
    }
  }
}
