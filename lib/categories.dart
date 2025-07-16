import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'subcategories.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final List<String> _defaultCategories = ['Shopping', 'Travel', 'Hobby'];
  final List<String> _categories = [];
  final prefsFuture = SharedPreferences.getInstance();

  final TextEditingController addCustomCategoryController = TextEditingController();

  Future<List<String>> loadCategories() async {
    final prefs = await prefsFuture;
    return prefs.getStringList('needsly.categories') ?? [];
  }

  Future<void> saveCategories(List<String> items) async {
    final prefs = await prefsFuture;
    await prefs.setStringList('needsly.categories', items);
  }

  void onAddCategory() {
    final text = addCustomCategoryController.text.trim();
    if (_categories.contains(text)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Option already exists!')));
      return;
    } else if (text.isNotEmpty) {
      setState(() {
        _categories.add(text);
        addCustomCategoryController.clear();
      });
      saveCategories(_categories);
    }
  }

  void onRemoveCategory(int index) {
    setState(() {
      _categories.removeAt(index);
    });
    saveCategories(_categories);
  }

  void onRenameCategory(int index) {
    final TextEditingController renameController = TextEditingController(
      text: _categories[index],
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rename Category'),
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
                setState(() {
                  _categories[index] = renameController.text.trim();
                });
                saveCategories(_categories);
                Navigator.of(context).pop();
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Load categories from shared preferences
    loadCategories().then((value) {
      setState(() {
        _categories.addAll(value.isNotEmpty ? value : _defaultCategories);
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
            // Text field to add custom option
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: addCustomCategoryController,
                    decoration: InputDecoration(
                      hintText: 'Add custom category',
                    ),
                    onSubmitted: (_) => onAddCategory(),
                  ),
                ),
                IconButton(icon: Icon(Icons.add), onPressed: onAddCategory),
              ],
            ),
            SizedBox(height: 16),
            // Display list
            Expanded(
              child: ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (_, index) => ListTile(
                  title: Text(_categories[index]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return CategoryPage(categoryId: _categories[index]);
                        },
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => onRenameCategory(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => onRemoveCategory(index),
                      ),
                    ],
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