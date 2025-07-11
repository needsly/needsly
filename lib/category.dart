import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// TODO: persistent storing does not work

class CategoryPage extends StatefulWidget {
  final String categoryId;

  const CategoryPage({super.key, required this.categoryId});

  @override
  State<StatefulWidget> createState() =>
      _CategoryPageState(categoryId: categoryId);
}

class _CategoryPageState extends State<CategoryPage> {
  final String categoryId;
  final Map<String, List<String>> itemsBySubcategories = {};
  final prefsFuture = SharedPreferences.getInstance();
  final TextEditingController addSubcategoryController =
      TextEditingController();
  final TextEditingController addItemController = TextEditingController();

  _CategoryPageState({required this.categoryId});

  Future<List<String>> loadSubcategories() async {
    final prefs = await prefsFuture;
    return prefs.getStringList('needsly.$categoryId') ?? [];
  }

  void saveSubcategories(List<String> subcategories) async {
    final prefs = await prefsFuture;
    await prefs.setStringList('needsly.$categoryId', subcategories);
  }

  void removeSubcategory(String subcategory) async {
    final prefs = await prefsFuture;
    await prefs.remove('needsly.$categoryId.$subcategory');
    saveSubcategories(itemsBySubcategories.keys.toList());
  }

  void addSubcategoryWithItems(String subcategory, List<String> items) async {
    final prefs = await prefsFuture;
    await prefs.setStringList('needsly.$categoryId.$subcategory', items);
  }

  void renameSubcategory(String fromSubcategory, String toSubcategory) async {
    final items = itemsBySubcategories[fromSubcategory];

    addSubcategoryWithItems(toSubcategory, items ?? []);
    removeSubcategory(fromSubcategory);
  }

  Future<List<String>> loadItems(String subcategoryId) async {
    final prefs = await prefsFuture;
    return prefs.getStringList('needsly.$categoryId.$subcategoryId.items') ??
        [];
  }

  Future<void> saveItems(String subcategoryId, List<String> items) async {
    final prefs = await prefsFuture;
    await prefs.setStringList(
      'needsly.$categoryId.$subcategoryId.items',
      items,
    );
  }

  void onRenameSubcategory(String subcategory) {
    final TextEditingController renameController = TextEditingController(
      text: subcategory,
    );

    final items = itemsBySubcategories[subcategory];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rename subcategory'),
          content: TextField(
            controller: renameController,
            decoration: InputDecoration(hintText: 'Enter new subcategory name'),
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
                final toSubcategory = renameController.text.trim();
                setState(() {
                  itemsBySubcategories.remove(subcategory);
                  itemsBySubcategories[toSubcategory] = items ?? [];
                  renameController.clear();
                });
                renameSubcategory(subcategory, toSubcategory);
                Navigator.of(context).pop();
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  void onRemoveSubcategory(subcategory) {
    setState(() {
      itemsBySubcategories.remove(subcategory);
    });
    saveSubcategories(itemsBySubcategories.keys.toList());
  }

  void onAddSubcategory() {
    final text = addSubcategoryController.text.trim();
    if (itemsBySubcategories.keys.contains(text)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Subcategory already exists!')));
      return;
    } else if (text.isNotEmpty) {
      setState(() {
        itemsBySubcategories[text] = [];
        addSubcategoryController.clear();
      });
      addSubcategoryWithItems(text, []);
    }
  }

  void onAddItem(String subcategory) {
    final text = addItemController.text.trim();
    final items = itemsBySubcategories[subcategory] ?? [];
    if (items.contains(text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item already exists in this subcategory!')),
      );
      return;
    } else if (text.isNotEmpty) {
      final updatedItems = [...items, text];
      setState(() {
        itemsBySubcategories[subcategory] = updatedItems;
        addItemController.clear();
      });
      saveItems(subcategory, updatedItems);
    }
  }

  void onRenameItem(String subcategory, int itemIdx) {
    final items = itemsBySubcategories[subcategory];
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
                items.removeAt(itemIdx);
                items.add(itemNewName);
                setState(() {
                  itemsBySubcategories[subcategory] = items;
                  renameController.clear();
                });
                saveItems(subcategory, items);
                Navigator.of(context).pop();
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  void onRemoveItem(String subcategory, int itemIdx) {
    final items = itemsBySubcategories[subcategory];
    if (items == null) return;
    items.removeAt(itemIdx);
    setState(() {
      itemsBySubcategories[subcategory] = items;
    });
    saveItems(subcategory, items);
  }

  void onResolveItem(subcategory, itemIdx) {
    onRemoveItem(subcategory, itemIdx);
    // TODO: besides, add a record about resolving fact => separate table (drift)
  }

  @override
  void initState() {
    super.initState();
    loadSubcategories().then((subcategories) {
      for (var subcategory in subcategories) {
        loadItems(subcategory).then((items) {
          setState(() {
            itemsBySubcategories[subcategory] = items;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final addSubcategorySegment = Row(
      children: [
        Expanded(
          child: TextField(
            controller: addSubcategoryController,
            decoration: InputDecoration(hintText: 'Add subcategory'),
            onSubmitted: (_) => onAddSubcategory(),
          ),
        ),
        IconButton(onPressed: onAddSubcategory, icon: Icon(Icons.add)),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text('$categoryId list')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            addSubcategorySegment,
            ...itemsBySubcategories.entries.map((subcategoryEntry) {
              return ExpansionTile(
                title: Text(subcategoryEntry.key),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () =>
                          onRenameSubcategory(subcategoryEntry.key),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () =>
                          onRemoveSubcategory(subcategoryEntry.key),
                    ),
                  ],
                ),
                childrenPadding: EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: addItemController,
                          decoration: InputDecoration(hintText: 'Add item'),
                          onSubmitted: (_) => onAddItem(subcategoryEntry.key),
                        ),
                      ),
                      IconButton(
                        onPressed: () => onAddItem(subcategoryEntry.key),
                        icon: Icon(Icons.add),
                      ),
                    ],
                  ),
                  ...subcategoryEntry.value.asMap().entries.map((item) {
                    return ListTile(
                      title: Text(item.value),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () =>
                                onRenameItem(subcategoryEntry.key, item.key),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () =>
                                onRemoveItem(subcategoryEntry.key, item.key),
                          ),
                          IconButton(
                            icon: Icon(Icons.done),
                            onPressed: () =>
                                onResolveItem(subcategoryEntry.key, item.key),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
