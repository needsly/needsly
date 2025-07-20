import 'package:flutter/material.dart';
import 'package:needsly/components/add_row.dart';
import 'package:needsly/components/category_row_buttons.dart';
import 'package:needsly/repository/prefs.dart';

import 'subcategories.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final List<String> _defaultCategories = ['Shopping', 'Travel', 'Hobby'];
  final List<String> categories = [];
  final prefsRepo = SharedPreferencesRepository();

  final TextEditingController addCustomCategoryController =
      TextEditingController();

  void onAddCategory(TextEditingController controller) {
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

  void onRemoveCategory(int index) {
    setState(() {
      categories.removeAt(index);
    });
    prefsRepo.saveCategories(categories);
  }

  void onRenameCategory(int index, String toCategory) {
    setState(() {
      categories[index] = toCategory;
    });
    prefsRepo.saveCategories(categories);
  }

  @override
  void initState() {
    super.initState();
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
      appBar: AppBar(title: Text('Categories')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 12),
            AddCategoryRow(onAdd: onAddCategory),
            SizedBox(height: 16),
            // Display list
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (_, index) => ListTile(
                  title: Text(categories[index]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return CategoryPage(category: categories[index]);
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
