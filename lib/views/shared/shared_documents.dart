import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:needsly/components/buttons/copy.dart';
import 'package:needsly/components/buttons/share_access.dart';
import 'package:needsly/components/rows/add_row.dart';
import 'package:needsly/components/rows/subcategory_row_buttons.dart';
import 'package:needsly/components/rows/item_row_buttons.dart';
import 'package:needsly/db/db.dart';
import 'package:needsly/repository/firestore.dart';
import 'package:provider/provider.dart';

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

// TODO: persist state changes to shared preferences as well??
// That would allow an offline mode but meanwhile make sync more challenging
// We'd need to keep client-server happen-before relation in order.
class SharedDocumentsPageState extends State<SharedDocumentsPage> {
  final String projectName;
  final FirebaseAuth auth;
  final FirestoreRepository firestoreRepository;

  final Map<String, List<String>> itemsByDocuments = {};

  late StreamSubscription<QuerySnapshot> _resolvedSubscription;
  late StreamSubscription<DocumentSnapshot> _syncSubscription;
  late String firebaseProjectName = 'firebase.$projectName';

  SharedDocumentsPageState({
    required this.projectName,
    required this.auth,
    required this.firestoreRepository,
  });

  void onShareAccess() {
    final TextEditingController shareWithController = TextEditingController(
      text: "",
    );
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Share access with'),
          content: TextField(
            controller: shareWithController,
            decoration: InputDecoration(hintText: 'Type email here'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final shareWith = shareWithController.text.trim();
                // todo: validate email format??
                final currentUser =
                    auth.currentUser?.email ?? auth.currentUser?.uid;
                if (currentUser == null) return;
                firestoreRepository.addDocument(
                  'allowed_users',
                  shareWith,
                  currentUser,
                );
                Navigator.of(context).pop();
              },
              child: Text('Share'),
            ),
          ],
        );
      },
    );
  }

  void onAddDocument(TextEditingController controller) {
    final newDocument = controller.text.trim();
    if (itemsByDocuments.keys.contains(newDocument)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Subcategory already exists!')));
      return;
    } else if (newDocument.isNotEmpty) {
      print('[onAddDocument] start changing state..');
      itemsByDocuments[newDocument] = [];
      controller.clear();
      print(
        '[onAddDocument] finish changing state, start saving to firestore..',
      );
      final currentUser = auth.currentUser?.email ?? auth.currentUser?.uid;
      if (currentUser == null) return;
      firestoreRepository.addDocument('active', newDocument, currentUser);
      print('[onAddDocument] finish saving to firestore..');
    }
  }

  void onRenameDocument(String fromDocument, String toDocument) async {
    final items = itemsByDocuments[fromDocument];
    itemsByDocuments.remove(fromDocument);
    itemsByDocuments[toDocument] = items ?? [];
    final currentUser = auth.currentUser?.email ?? auth.currentUser?.uid;
    if (currentUser == null) return;
    firestoreRepository.renameDocument(fromDocument, toDocument, currentUser);
  }

  void onRemoveDocument(String document) {
    itemsByDocuments.remove(document);
    firestoreRepository.deleteDocument(document);
  }

  void onAddItem(String document, TextEditingController controller) {
    final text = controller.text.trim();
    final items = itemsByDocuments[document] ?? [];
    if (items.contains(text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item already exists in this subcategory!')),
      );
      return;
    } else if (text.isNotEmpty) {
      final updatedItems = [...items, text];
      itemsByDocuments[document] = updatedItems;
      controller.clear();
      final currentUser = auth.currentUser?.email ?? auth.currentUser?.uid;
      if (currentUser == null) return;
      firestoreRepository.addItem(document, text, currentUser);
    }
  }

  void onRenameItem(String document, int itemIdx) {
    final items = itemsByDocuments[document];
    if (items == null) return;
    final TextEditingController renameController = TextEditingController(
      text: items[itemIdx],
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rename Item'),
          content: TextField(
            controller: renameController,
            decoration: InputDecoration(hintText: 'Enter new name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final itemNewName = renameController.text.trim();
                final removedValue = items.removeAt(itemIdx);
                items.add(itemNewName);
                itemsByDocuments[document] = items;
                renameController.clear();
                final currentUser =
                    auth.currentUser?.email ?? auth.currentUser?.uid;
                if (currentUser == null) return;
                firestoreRepository.renameItem(
                  document,
                  removedValue,
                  itemNewName,
                  currentUser,
                );
                Navigator.of(context).pop();
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  void onRemoveItem(String document, int itemIdx) {
    final items = itemsByDocuments[document];
    if (items == null) return;
    final removedValue = items.removeAt(itemIdx);
    itemsByDocuments[document] = items;
    final currentUser = auth.currentUser?.email ?? auth.currentUser?.uid;
    if (currentUser == null) return;
    firestoreRepository.removeItem(document, removedValue, currentUser);
  }

  void onResolveItem(String document, int itemIdx) {
    final item = itemsByDocuments[document]![itemIdx];
    final resolvedAt = DateTime.now();
    firestoreRepository.resolveItem(document, item, resolvedAt);
    onRemoveItem(document, itemIdx);
  }

  void onCopyDocumentItems(String document) {
    final items = itemsByDocuments[document] ?? [];
    final text = items.join(',');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Copied to clipboard")));
  }

  void onCopyDocumentsWithItems() {
    final text = itemsByDocuments.entries
        .map(
          (subcategoryEntry) =>
              '${subcategoryEntry.key}: ${subcategoryEntry.value.join(", ")}',
        )
        .join('\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Copied to clipboard")));
  }

  void setSyncFlag() {
    final currentUser = auth.currentUser?.email ?? auth.currentUser?.uid;
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('You are not logged in!')));
      return;
    }
    final now = DateTime.now();
    print('[Set sync flag] $now for $currentUser');
    firestoreRepository.addSyncResolved(currentUser);
  }

  @override
  void initState() {
    print('[initState]');
    super.initState();
    final db = Provider.of<DatabaseRepository>(context, listen: false);
    _resolvedSubscription = firestoreRepository
        .collectionSnapshots('resolved')
        .listen((resolvedCollectionSnap) {
          final docChanges = resolvedCollectionSnap.docChanges;
          var shouldSetSyncFlag = false;
          for (var docChange in docChanges) {
            final docData = docChange.doc.data();
            final docId = docChange.doc.id;
            final items = Map<String, dynamic>.from(docData?['items'] ?? {});
            if (items.entries.isNotEmpty) {
              shouldSetSyncFlag = true;
            }
            print('[received resolved snapshot] document=$docId items=$items');
            // TODO: use batch
            for (var item in items.entries) {
              final timestamps = List<Timestamp>.from(item.value);
              for (var ts in timestamps) {
                db.addResolvedItem(
                  firebaseProjectName,
                  docId,
                  item.key,
                  ts.toDate(),
                );
              }
            }
          }
          // TODO: only call if previous operations were completed successfully
          if (shouldSetSyncFlag) {
            setSyncFlag();
          }
        });

    _syncSubscription = firestoreRepository
        .documentSnapshots('sync', 'resolved')
        .listen((syncResolvedSnap) {
          final docData = syncResolvedSnap.data();
          print(
            '[received sync.resolved snapshot] document=${syncResolvedSnap.id}',
          );
          final resolvedByEmail = Map<String, Timestamp>.from(docData ?? {});
          firestoreRepository.cleanOutdatedResolved(resolvedByEmail);
        });
  }

  @override
  Widget build(BuildContext context) {
    print('[build]');
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreRepository.collectionSnapshots('active'),
      builder: (context, snapshot) {
        print(
          'Received a new snapshot. Status = ${snapshot.connectionState}. Current state: ${itemsByDocuments.toString()}',
        );
        if (snapshot.connectionState == ConnectionState.waiting) {
          // return const Center(child: CircularProgressIndicator());
          return render(context);
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text("No data"));
        }

        final snap = snapshot.data!;
        final itemsByDocumentsSnap = fromSnapshot(snap);
        final docChanges = snap.docChanges;

        for (var change in docChanges) {
          final snapDocId = change.doc.id;
          final snapItems = List<String>.from(change.doc['items'] ?? []);
          print(
            '[change] type=${change.type} snap doc id = $snapDocId; items = $snapItems',
          );
        }
        final mapsEq = const DeepCollectionEquality().equals;
        final stateIsTheSame = mapsEq(itemsByDocuments, itemsByDocumentsSnap);
        if (docChanges.isEmpty || stateIsTheSame) {
          return render(context);
        }

        if (snapshot.connectionState == ConnectionState.active &&
            snap.metadata.isFromCache == false &&
            itemsByDocuments.isEmpty) {
          initStateWithRemoteFirstSnapshot(snap);
        } else {
          updateStateWithRemoteLaterSnapshot(snap);
        }
        return render(context);
      },
    );
  }

  @override
  void dispose() {
    print('[dispose]');
    _resolvedSubscription.cancel();
    _syncSubscription.cancel();
    super.dispose();
  }

  Map<String, List<String>> fromSnapshot(QuerySnapshot<Object?> snap) {
    for (var change in snap.docChanges) {
      print(
        "doc=${change.doc.id}; has pending changes=${change.doc.metadata.hasPendingWrites}; from cache = ${change.doc.metadata.isFromCache}",
      );
    }
    final itemsByDocuments = Map.fromEntries(
      snap.docChanges.map((docChange) {
        final docId = docChange.doc.id;
        final items = List<String>.from(docChange.doc['items'] ?? []);
        return MapEntry(docId, items);
      }),
    );
    return itemsByDocuments;
  }

  void initStateWithRemoteFirstSnapshot(QuerySnapshot<Object?> snap) {
    print('init with a remote snapshot');
    final itemsByDocsRemote = snap.docs.fold<Map<String, List<String>>>({}, (
      itemsByDocs,
      nextDocSnapshot,
    ) {
      final items = List<String>.from(nextDocSnapshot['items'] ?? []);
      itemsByDocs[nextDocSnapshot.id] = items;
      return itemsByDocs;
    });
    itemsByDocuments.addAll(itemsByDocsRemote);
  }

  void updateStateWithRemoteLaterSnapshot(QuerySnapshot<Object?> snap) {
    print('update with a remote snapshot');
    for (var change in snap.docChanges) {
      final snapDocId = change.doc.id;
      final snapItems = List<String>.from(change.doc['items'] ?? []);
      if (change.type == DocumentChangeType.added ||
          change.type == DocumentChangeType.modified) {
        if (!isDocumentStateTheSame(snapDocId, snapItems)) {
          itemsByDocuments[snapDocId] = snapItems;
        } else {
          print('Document $snapDocId state is the same');
        }
      } else if (change.type == DocumentChangeType.removed) {
        if (itemsByDocuments.containsKey(snapDocId)) {
          itemsByDocuments.remove(snapDocId);
        }
      }
    }
  }

  bool isDocumentStateTheSame(String snapDocId, List<String> snapItems) {
    final unorderedEquals = const UnorderedIterableEquality().equals;
    final docFromState = itemsByDocuments.keys.firstWhereOrNull(
      (item) => item == snapDocId,
    );
    if (docFromState != null) {
      final itemsState = itemsByDocuments[snapDocId];
      if (itemsState != null) {
        return unorderedEquals(itemsState, snapItems);
      }
    }
    return false;
  }

  Scaffold render(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$projectName subcategories'),
        actions: [
          ShareAccessButton(onShareAccess: onShareAccess),
          CopyInnerStructureButton(onCopy: onCopyDocumentsWithItems),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            ...itemsByDocuments.entries.map((documentEntry) {
              final documentName = documentEntry.key;
              return documentsWithItemsList(
                documentName,
                context,
                documentEntry,
              );
            }),
            AddListRow(onAdd: onAddDocument, hintText: 'Add subcategory'),
          ],
        ),
      ),
    );
  }

  ExpansionTile documentsWithItemsList(
    String documentName,
    BuildContext context,
    MapEntry<String, List<String>> documentEntry,
  ) {
    return ExpansionTile(
      shape: const Border(),
      tilePadding: EdgeInsets.all(0),
      initiallyExpanded: true,
      title: Text(documentName, style: TextStyle(fontWeight: FontWeight.bold)),
      trailing: documentRowButtons(context, documentName),
      childrenPadding: EdgeInsets.all(20),
      children: [
        itemsList(documentEntry, documentName),
        AddItemRow(subcategory: documentName, onAdd: onAddItem),
      ],
    );
  }

  SubcategoryRowButtons documentRowButtons(
    BuildContext context,
    String documentName,
  ) {
    return SubcategoryRowButtons(
      context: context,
      category: firebaseProjectName,
      subcategory: documentName,
      onRename: onRenameDocument,
      onRemove: onRemoveDocument,
      onCopy: onCopyDocumentItems,
    );
  }

  SizedBox itemsList(
    MapEntry<String, List<String>> documentEntry,
    String documentName,
  ) {
    return SizedBox(
      height: documentEntry.value.length * 50,
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: documentEntry.value.length,
        itemBuilder: (_, index) => ListTile(
          contentPadding: EdgeInsets.all(0),
          key: Key(documentEntry.value[index]),
          title: Text(documentEntry.value[index]),
          trailing: itemRowButtons(documentName, index),
        ),
      ),
    );
  }

  ItemRowButtons itemRowButtons(String documentName, int index) {
    return ItemRowButtons(
      subcategory: documentName,
      itemIdx: index,
      onRename: onRenameItem,
      onRemove: onRemoveItem,
      onResolve: onResolveItem,
    );
  }
}
