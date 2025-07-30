import 'package:flutter/material.dart';
import 'package:needsly/components/lists/add_row.dart';
import 'package:needsly/components/lists/category_row_buttons.dart';
import 'package:needsly/repository/db.dart';
import 'package:needsly/repository/prefs.dart';

class CategoryPage extends StatefulWidget {
  final String category;

  const CategoryPage({super.key, required this.category});

  @override
  State<StatefulWidget> createState() => CategoryPageState(category: category);
}

class CategoryPageState extends State<CategoryPage> {
  final String category;
  final Map<String, List<String>> itemsBySubcategories = {};
  final Map<String, TextEditingController> addItemsControllerBySubcategory = {};
  final dbRepo = DatabaseRepository();
  final prefsRepo = SharedPreferencesRepository();

  CategoryPageState({required this.category});

  void onRenameSubcategory(String fromSubcategory, String toSubcategory) {
    final items = itemsBySubcategories[fromSubcategory];
    setState(() {
      itemsBySubcategories.remove(fromSubcategory);
      itemsBySubcategories[toSubcategory] = items ?? [];
    });
    prefsRepo.renameSubcategory(
      category,
      fromSubcategory,
      toSubcategory,
      items ?? [],
    );
  }

  void onRemoveSubcategory(subcategory) {
    setState(() {
      itemsBySubcategories.remove(subcategory);
    });
    prefsRepo.updateSubcategories(category, itemsBySubcategories.keys.toList());
  }

  void onAddSubcategory(TextEditingController controller) {
    final newCategory = controller.text.trim();
    if (itemsBySubcategories.keys.contains(newCategory)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Subcategory already exists!')));
      return;
    } else if (newCategory.isNotEmpty) {
      setState(() {
        itemsBySubcategories[newCategory] = [];
        controller.clear();
      });
      prefsRepo.addSubcategoryWithItems(category, newCategory, []);
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
      prefsRepo.saveItems(category, subcategory, updatedItems);
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
                prefsRepo.saveItems(category, subcategory, items);
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
    prefsRepo.saveItems(category, subcategory, items);
  }

  void onResolveItem(subcategory, itemIdx) {
    final item = itemsBySubcategories[subcategory]![itemIdx];
    final resolvedAt = DateTime.now();
    print(
      '### Add resolved: category=$category subcategory=$subcategory item=$item resolvedAt=$resolvedAt',
    );
    dbRepo.addResolved(category, subcategory, item, resolvedAt);
    onRemoveItem(subcategory, itemIdx);
  }

  @override
  void initState() {
    super.initState();
    prefsRepo.loadSubcategories(category).then((subcategories) {
      for (var subcategory in subcategories) {
        prefsRepo.loadItems(category, subcategory).then((items) {
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
      appBar: AppBar(title: Text(category)),
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
                trailing: SubcategoryRowButtons(
                  context: context,
                  category: category,
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
