import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:needsly/components/buttons/copy.dart';
import 'package:needsly/components/rows/add_row.dart';
import 'package:needsly/components/rows/subcategory_row_buttons.dart';
import 'package:needsly/components/rows/item_row_buttons.dart';
import 'package:needsly/db/db.dart';
import 'package:needsly/repository/prefs.dart';
import 'package:needsly/utils/utils.dart';
import 'package:provider/provider.dart';

class SubcategoriesPage extends StatefulWidget {
  final String category;

  const SubcategoriesPage({super.key, required this.category});

  @override
  State<StatefulWidget> createState() =>
      SubcategoriesPageState(category: category);
}

class SubcategoriesPageState extends State<SubcategoriesPage> {
  // TODO: move to global constants
  final _personalCategoriesPrefix = 'needsly.categories';
  final String category;
  final Map<String, List<String>> itemsBySubcategories = {};

  SubcategoriesPageState({required this.category});

  void onRenameSubcategory(String fromSubcategory, String toSubcategory) {
    final prefs = Provider.of<SharedPreferencesRepository>(
      context,
      listen: false,
    );
    final items = itemsBySubcategories[fromSubcategory];
    setState(() {
      itemsBySubcategories.remove(fromSubcategory);
      itemsBySubcategories[toSubcategory] = items ?? [];
    });
    prefs.renameSubcategory(
      _personalCategoriesPrefix,
      category,
      fromSubcategory,
      toSubcategory,
      items ?? [],
    );
  }

  void onRemoveSubcategory(String subcategory) {
    final prefs = Provider.of<SharedPreferencesRepository>(
      context,
      listen: false,
    );
    setState(() {
      itemsBySubcategories.remove(subcategory);
    });
    prefs.updateSubcategories(
      _personalCategoriesPrefix,
      category,
      itemsBySubcategories.keys.toList(),
    );
  }

  void onAddSubcategory(TextEditingController controller) {
    final prefs = Provider.of<SharedPreferencesRepository>(
      context,
      listen: false,
    );
    final newSubcategory = controller.text.trim();
    if (itemsBySubcategories.keys.contains(newSubcategory)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Subcategory already exists!')));
      return;
    } else if (newSubcategory.isNotEmpty) {
      setState(() {
        itemsBySubcategories[newSubcategory] = [];
        controller.clear();
      });
      prefs.addSubcategoryWithItems(
        _personalCategoriesPrefix,
        category,
        newSubcategory,
        [],
      );
    }
  }

  void onAddItem(String subcategory, TextEditingController controller) {
    final prefs = Provider.of<SharedPreferencesRepository>(
      context,
      listen: false,
    );
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
      prefs.saveItems(
        _personalCategoriesPrefix,
        category,
        subcategory,
        updatedItems,
      );
    }
  }

  void onRenameItem(String subcategory, int itemIdx) {
    final prefs = Provider.of<SharedPreferencesRepository>(
      context,
      listen: false,
    );
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
                prefs.saveItems(
                  _personalCategoriesPrefix,
                  category,
                  subcategory,
                  items,
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

  void onRemoveItem(String subcategory, int itemIdx) {
    final prefs = Provider.of<SharedPreferencesRepository>(
      context,
      listen: false,
    );
    final items = itemsBySubcategories[subcategory];
    if (items == null) return;
    items.removeAt(itemIdx);
    setState(() {
      itemsBySubcategories[subcategory] = items;
    });
    prefs.saveItems(_personalCategoriesPrefix, category, subcategory, items);
  }

  void onResolveItem(String subcategory, int itemIdx) {
    final item = itemsBySubcategories[subcategory]![itemIdx];
    final resolvedAt = DateTime.now();
    final dbRepo = Provider.of<DatabaseRepository>(context, listen: false);
    dbRepo.addResolvedItem(category, subcategory, item, resolvedAt);
    onRemoveItem(subcategory, itemIdx);
  }

  void onCopySubcategoriesWithItems() {
    final text = itemsBySubcategories.entries
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

  void onCopySubcategory(String subcategory) {
    final items = itemsBySubcategories[subcategory] ?? [];
    final text = items.join(',');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Copied to clipboard")));
  }

  @override
  void initState() {
    super.initState();
    final prefs = Provider.of<SharedPreferencesRepository>(
      context,
      listen: false,
    );
    prefs.loadSubcategories(_personalCategoriesPrefix, category).then((
      subcategories,
    ) {
      for (var subcategory in subcategories) {
        prefs.loadItems(_personalCategoriesPrefix, category, subcategory).then((
          items,
        ) {
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
      appBar: AppBar(
        title: Text(category),
        actions: [
          CopyInnerStructureButton(onCopy: onCopySubcategoriesWithItems),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ...itemsBySubcategories.entries.map((subcategoryEntry) {
              final subcategoryKey = subcategoryEntry.key;
              return ExpansionTile(
                shape: const Border(),
                tilePadding: EdgeInsets.zero,
                initiallyExpanded: true,
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
                  onCopy: onCopySubcategory,
                ),
                childrenPadding: EdgeInsets.all(20),
                children: [
                  SizedBox(
                    height: subcategoryEntry.value.length * 50,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: subcategoryEntry.value.length,
                      itemBuilder: (_, index) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        key: Key(subcategoryEntry.value[index]),
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
            AddListRow(onAdd: onAddSubcategory, hintText: 'Add subcategory'),
          ],
        ),
      ),
    );
  }
}
