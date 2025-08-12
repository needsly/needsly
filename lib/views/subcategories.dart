import 'package:flutter/material.dart';
import 'package:needsly/components/rows/add_row.dart';
import 'package:needsly/components/rows/category_row_buttons.dart';
import 'package:needsly/components/rows/item_row_buttons.dart';
import 'package:needsly/repository/db.dart';
import 'package:needsly/repository/prefs.dart';
import 'package:needsly/utils/utils.dart';

class CategoryPage extends StatefulWidget {
  final String category;

  const CategoryPage({super.key, required this.category});

  @override
  State<StatefulWidget> createState() => CategoryPageState(category: category);
}

class CategoryPageState extends State<CategoryPage> {
  final String category;
  final Map<String, List<String>> itemsBySubcategories = {};
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

  void onAddItem(String subcategory, TextEditingController controller) {
    final text = controller.text.trim();
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
        controller.clear();
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

  void onResolveItem(String subcategory, int itemIdx) {
    final item = itemsBySubcategories[subcategory]![itemIdx];
    final resolvedAt = DateTime.now();
    dbRepo.addResolved(category, subcategory, item, resolvedAt);
    onRemoveItem(subcategory, itemIdx);
  }

  void onReorderSubcategoryItems(String subcategory, int oldIdx, int newIdx) {
    final items = itemsBySubcategories[subcategory] ?? [];
    final reorderedItems = reorderList(items, oldIdx, newIdx);
    setState(() {
      itemsBySubcategories[subcategory] = reorderedItems;
    });
    prefsRepo.saveItems(category, subcategory, reorderedItems);
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
            AddSubcategoryRow(onAdd: onAddSubcategory),
            ...itemsBySubcategories.entries.map((subcategoryEntry) {
              final subcategoryKey = subcategoryEntry.key;
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
                  SizedBox(
                    height: subcategoryEntry.value.length * 60,
                    child: ReorderableListView.builder(
                      itemCount: subcategoryEntry.value.length,
                      onReorder: (oldIdx, newIdx) => onReorderSubcategoryItems(
                        subcategoryEntry.key,
                        oldIdx,
                        newIdx,
                      ),
                      itemBuilder: (_, index) => ListTile(
                        title: Text(subcategoryEntry.value[index]),
                        trailing: ItemRowButtons(
                          subcategory: subcategoryKey,
                          itemIdx: index,
                          onRename: onRenameItem,
                          onRemove: onRemoveItem,
                          onResolve: onResolveItem,
                        ),
                      ),
                    ),
                  ),
                  AddItemRow(subcategory: subcategoryKey, onAdd: onAddItem),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
