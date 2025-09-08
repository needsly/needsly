import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:needsly/components/rows/add_row.dart';
import 'package:needsly/components/rows/category_row_buttons.dart';
import 'package:needsly/components/rows/item_row_buttons.dart';
import 'package:needsly/db/db.dart';
import 'package:needsly/repository/firestore.dart';
import 'package:needsly/repository/prefs.dart';
import 'package:needsly/utils/utils.dart';
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
  final _sharedProjectsPrefix = 'needsly.firebase.projects';

  final String projectName;
  final FirebaseAuth auth;
  final FirestoreRepository firestoreRepository;

  final Map<String, List<String>> itemsByDocuments = {};

  late StreamSubscription<QuerySnapshot> _resolvedSubscription;
  late StreamSubscription<DocumentSnapshot> _syncSubscription;

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
                firestoreRepository.addDocument('allowed_users', shareWith);
                Navigator.of(context).pop();
              },
              child: Text('Share'),
            ),
          ],
        );
      },
    );
  }

  void onReorderDocumentItems(String subcategory, int oldIdx, int newIdx) {
    final prefsRepo = Provider.of<SharedPreferencesRepository>(
      context,
      listen: false,
    );
    final items = itemsByDocuments[subcategory] ?? [];
    final reorderedItems = reorderList(items, oldIdx, newIdx);
    setState(() {
      itemsByDocuments[subcategory] = reorderedItems;
    });
    prefsRepo.saveItems(
      _sharedProjectsPrefix,
      projectName,
      subcategory,
      reorderedItems,
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
      setState(() {
        itemsByDocuments[newDocument] = [];
        controller.clear();
      });
      firestoreRepository.addDocument('active', newDocument);
    }
  }

  void onRenameDocument(String fromDocument, String toDocument) async {
    final items = itemsByDocuments[fromDocument];
    setState(() {
      itemsByDocuments.remove(fromDocument);
      itemsByDocuments[toDocument] = items ?? [];
    });
    firestoreRepository.renameDocument('active', fromDocument, toDocument);
  }

  void onRemoveDocument(String document) {
    setState(() {
      itemsByDocuments.remove(document);
    });
    firestoreRepository.deleteDocument('active', document);
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
      setState(() {
        itemsByDocuments[document] = updatedItems;
        controller.clear();
      });
      firestoreRepository.addItem('active', document, text);
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
                setState(() {
                  itemsByDocuments[document] = items;
                  renameController.clear();
                });
                firestoreRepository.renameItem(
                  'active',
                  document,
                  removedValue,
                  itemNewName,
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
    setState(() {
      itemsByDocuments[document] = items;
    });
    firestoreRepository.removeItem('active', document, removedValue);
  }

  void onResolveItem(String document, int itemIdx) {
    final item = itemsByDocuments[document]![itemIdx];
    final resolvedAt = DateTime.now();
    firestoreRepository.resolveItem(document, item, resolvedAt);
    onRemoveItem(document, itemIdx);
  }

  void onCopyDocument(String document) {
    final items = itemsByDocuments[document] ?? [];
    final text = items.join(',');
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
    firestoreRepository.addDocumentWithData('sync', 'resolved', {
      currentUser: now,
    });
  }

  @override
  void initState() {
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
            final items = Map<String, Timestamp>.from(docData?['items'] ?? {});
            if (items.entries.isNotEmpty) {
              shouldSetSyncFlag = true;
            }
            print('[received resolved snapshot] document=$docId items=$items');
            // TODO: use batch
            for (var item in items.entries) {
              db.addResolvedItem(
                'firebase.$projectName',
                docId,
                item.key,
                item.value.toDate(),
              );
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
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreRepository.collectionSnapshots('active'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text("No data"));
        }

        final snap = snapshot.data!;

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
    _resolvedSubscription.cancel();
    _syncSubscription.cancel();
    super.dispose();
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
      final docId = change.doc.id;
      final items = List<String>.from(change.doc['items'] ?? []);
      if (change.type == DocumentChangeType.added ||
          change.type == DocumentChangeType.modified) {
        itemsByDocuments[docId] = items;
      } else if (change.type == DocumentChangeType.removed) {
        itemsByDocuments.remove(docId);
      }
    }
  }

  Scaffold render(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project $projectName documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: "Share access",
            onPressed: onShareAccess,
            iconSize: 40.0,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            AddListRow(onAdd: onAddDocument, hintText: 'Add subcategory'),
            ...itemsByDocuments.entries.map((documentEntry) {
              final documentName = documentEntry.key;
              return ExpansionTile(
                initiallyExpanded: true,
                title: Text(
                  documentName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: SubcategoryRowButtons(
                  context: context,
                  category: 'firebase.$projectName',
                  subcategory: documentName,
                  onRename: onRenameDocument,
                  onRemove: onRemoveDocument,
                  onCopy: onCopyDocument,
                ),
                childrenPadding: EdgeInsets.all(16),
                children: [
                  SizedBox(
                    height: documentEntry.value.length * 60,
                    child: ReorderableListView.builder(
                      itemCount: documentEntry.value.length,
                      onReorder: (oldIdx, newIdx) => onReorderDocumentItems(
                        documentEntry.key,
                        oldIdx,
                        newIdx,
                      ),
                      itemBuilder: (_, index) => ListTile(
                        key: Key(documentEntry.value[index]),
                        title: Text(documentEntry.value[index]),
                        trailing: itemRowButtons(documentName, index),
                      ),
                    ),
                  ),
                  AddItemRow(subcategory: documentName, onAdd: onAddItem),
                ],
              );
            }),
          ],
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
