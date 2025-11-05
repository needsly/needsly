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
  CategoriesPageState createState() => CategoriesPageState();
}

class CategoriesPageState extends State<CategoriesPage> {
  // TODO: move to global constants
  final _personalCategoriesPrefix = 'needsly.categories';
  final List<String> _defaultCategories = ['Shopping', 'Travel', 'Hobby'];
  final List<String> categories = [];

  final TextEditingController addCustomCategoryController =
      TextEditingController();

  void onAddCategory(TextEditingController controller) {
    final prefsRepo = Provider.of<SharedPreferencesRepository>(
      context,
      listen: false,
    );
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
      prefsRepo.saveCategories(_personalCategoriesPrefix, categories);
    }
  }

  void onRemoveCategory(int idx) {
    final prefsRepo = Provider.of<SharedPreferencesRepository>(
      context,
      listen: false,
    );
    setState(() {
      categories.removeAt(idx);
    });
    prefsRepo.removeCategory(_personalCategoriesPrefix, idx);
  }

  void onRenameCategory(int idx, String toCategory) {
    final prefsRepo = Provider.of<SharedPreferencesRepository>(
      context,
      listen: false,
    );
    final fromCategory = categories[idx];
    setState(() {
      categories[idx] = toCategory;
    });
    prefsRepo.saveCategories(_personalCategoriesPrefix, categories);
    prefsRepo.renameCategory(
      _personalCategoriesPrefix,
      idx,
      fromCategory,
      toCategory,
    );
  }

  @override
  void initState() {
    super.initState();
    final prefsRepo = Provider.of<SharedPreferencesRepository>(
      context,
      listen: false,
    );
    loadCategoriesFromStorage(prefsRepo);
  }

  void loadCategoriesFromStorage(SharedPreferencesRepository prefsRepo) {
    prefsRepo.loadCategories(_personalCategoriesPrefix).then((cats) {
      setState(() {
        categories.addAll(cats.isNotEmpty ? cats : _defaultCategories);
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
            SizedBox(
              height: categories.length * 50,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: categories.length,
                itemBuilder: (_, index) => ListTile(
                  contentPadding: EdgeInsets.zero,
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
              ),
            ),
            AddListRow(onAdd: onAddCategory, hintText: 'Add category'),
          ],
        ),
      ),
    );
  }
}
