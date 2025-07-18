import 'package:flutter/material.dart';
import 'package:needsly/components/add_row.dart';
import 'package:needsly/components/category_row_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryPage extends StatefulWidget {
  final String categoryId;

  const CategoryPage({super.key, required this.categoryId});

  @override
  State<StatefulWidget> createState() =>
      CategoryPageState(categoryId: categoryId);
}

class CategoryPageState extends State<CategoryPage> {
  final String categoryId;
  final Map<String, List<String>> itemsBySubcategories = {};
  final prefsFuture = SharedPreferences.getInstance();
  final Map<String, TextEditingController> addItemsControllerBySubcategory = {};

  CategoryPageState({required this.categoryId});

  Future<List<String>> loadSubcategories() async {
    final prefs = await prefsFuture;
    return prefs.getStringList('needsly.$categoryId') ?? [];
  }

  void updateSubcategories(List<String> subcategories) async {
    final prefs = await prefsFuture;
    await prefs.setStringList('needsly.$categoryId', subcategories);
  }

  void removeSubcategory(String subcategory) async {
    final prefs = await prefsFuture;
    await prefs.remove('needsly.$categoryId.$subcategory');
    final subcategories = prefs.getStringList('needsly.$categoryId') ?? [];
    subcategories.remove(subcategory);
    updateSubcategories(subcategories);
  }

  void addSubcategoryWithItems(String subcategory, List<String> items) async {
    final prefs = await prefsFuture;
    final subcategories = prefs.getStringList('needsly.$categoryId') ?? [];
    await prefs.setStringList('needsly.$categoryId.$subcategory', items);
    updateSubcategories([...subcategories, subcategory]);
  }

  void renameSubcategory(String fromSubcategory, String toSubcategory) async {
    final items = itemsBySubcategories[fromSubcategory];

    addSubcategoryWithItems(toSubcategory, items ?? []);
    removeSubcategory(fromSubcategory);
  }

  Future<List<String>> loadItems(String subcategoryId) async {
    final prefs = await prefsFuture;
    return prefs.getStringList('needsly.$categoryId.$subcategoryId') ?? [];
  }

  Future<void> saveItems(String subcategoryId, List<String> items) async {
    final prefs = await prefsFuture;
    await prefs.setStringList('needsly.$categoryId.$subcategoryId', items);
  }

  void onRenameSubcategory(String subcategory, String toSubcategory) {
    final items = itemsBySubcategories[subcategory];
    setState(() {
      itemsBySubcategories.remove(subcategory);
      itemsBySubcategories[toSubcategory] = items ?? [];
    });
    renameSubcategory(subcategory, toSubcategory);
  }

  void onRemoveSubcategory(subcategory) {
    setState(() {
      itemsBySubcategories.remove(subcategory);
    });
    updateSubcategories(itemsBySubcategories.keys.toList());
  }

  void onAddSubcategory(TextEditingController controller) {
    final text = controller.text.trim();
    if (itemsBySubcategories.keys.contains(text)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Subcategory already exists!')));
      return;
    } else if (text.isNotEmpty) {
      setState(() {
        itemsBySubcategories[text] = [];
        controller.clear();
      });
      addSubcategoryWithItems(text, []);
    }
  }

  void onAddItem(String subcategory) {
    final controller = addItemsControllerBySubcategory[subcategory];
    final text = controller?.text.trim();
    final items = itemsBySubcategories[subcategory] ?? [];
    if (items.contains(text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item already exists in this subcategory!')),
      );
      return;
    } else if (text != null && text.isNotEmpty) {
      final updatedItems = [...items, text];
      setState(() {
        itemsBySubcategories[subcategory] = updatedItems;
        controller?.clear();
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
    return Scaffold(
      appBar: AppBar(title: Text('$categoryId list')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            AddCategoryRow(onAdd: onAddSubcategory),
            ...itemsBySubcategories.entries.map((subcategoryEntry) {
              final subcategoryKey = subcategoryEntry.key;
              addItemsControllerBySubcategory[subcategoryKey] =
                  TextEditingController();
              return ExpansionTile(
                title: Text(
                  subcategoryKey,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: ModifySubcategoryRow(
                  context: context,
                  subcategory: subcategoryKey,
                  onRename: onRenameSubcategory,
                  onRemove: onRemoveSubcategory,
                ),
                childrenPadding: EdgeInsets.all(16),
                children: [
                  ...subcategoryEntry.value.asMap().entries.map((item) {
                    return ListTile(
                      title: Text(item.value),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () =>
                                onRenameItem(subcategoryKey, item.key),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () =>
                                onRemoveItem(subcategoryKey, item.key),
                          ),
                          IconButton(
                            icon: Icon(Icons.done),
                            onPressed: () =>
                                onResolveItem(subcategoryKey, item.key),
                          ),
                        ],
                      ),
                    );
                  }),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller:
                              addItemsControllerBySubcategory[subcategoryKey],
                          decoration: InputDecoration(hintText: 'Add item'),
                          onSubmitted: (_) => onAddItem(subcategoryKey),
                        ),
                      ),
                      IconButton(
                        onPressed: () => onAddItem(subcategoryKey),
                        icon: Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
