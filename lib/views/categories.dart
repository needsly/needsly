import 'package:flutter/material.dart';
import 'package:needsly/components/rows/add_row.dart';
import 'package:needsly/components/rows/category_row_buttons.dart';
import 'package:needsly/repository/prefs.dart';
import 'package:needsly/utils/utils.dart';
import 'package:provider/provider.dart';

import 'subcategories.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final List<String> _defaultCategories = ['Shopping', 'Travel', 'Hobby'];
  final List<String> categories = [];

  final TextEditingController addCustomCategoryController =
      TextEditingController();

  void onAddCategory(TextEditingController controller) {  
    final prefsRepo = Provider.of<SharedPreferencesRepository>(context, listen: false);
    final text = controller.text.trim();
    if (categories.contains(text)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Option already exists!')));
      return;
    } else if (text.isNotEmpty) {
      setState(() {
        categories.add(text);
        controller.clear();
      });
      prefsRepo.saveCategories(categories);
    }
  }

  void onRemoveCategory(int idx) {
    final prefsRepo = Provider.of<SharedPreferencesRepository>(context, listen: false);
    setState(() {
      categories.removeAt(idx);
    });
    prefsRepo.removeCategory(idx);
  }

  void onRenameCategory(int idx, String toCategory) {
    final prefsRepo = Provider.of<SharedPreferencesRepository>(context, listen: false);
    setState(() {
      categories[idx] = toCategory;
    });
    prefsRepo.saveCategories(categories);
    prefsRepo.renameCategory(idx, toCategory);
  }

  void onReorderCategory(int oldIdx, int newIdx) {
    final prefsRepo = Provider.of<SharedPreferencesRepository>(context, listen: false);
    final reorderedCategories = reorderList(categories, oldIdx, newIdx);
    setState(() {
      categories.setAll(0, reorderedCategories);
    });
    prefsRepo.saveCategories(reorderedCategories);
  }

  @override
  void initState() {
    super.initState();
    final prefsRepo = Provider.of<SharedPreferencesRepository>(context, listen: false);
    // Load categories from shared preferences
    prefsRepo.loadCategories().then((value) {
      setState(() {
        categories.addAll(value.isNotEmpty ? value : _defaultCategories);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lists')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 12),
            AddCategoryRow(onAdd: onAddCategory),
            SizedBox(height: 16),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: categories.length,
                itemBuilder: (_, index) => ListTile(
                  key: Key(categories[index]),
                  title: Text(categories[index]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return SubcategoriesPage(category: categories[index]);
                        },
                      ),
                    );
                  },
                  trailing: CategoryRowButtons(
                    context: context,
                    category: categories[index],
                    index: index,
                    onRename: onRenameCategory,
                    onRemove: onRemoveCategory,
                  ),
                ),
                onReorder: (oldIdx, newIdx) =>
                    onReorderCategory(oldIdx, newIdx),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
