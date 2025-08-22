import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesRepository {
  final prefsFuture = SharedPreferences.getInstance();

  // Categories
  Future<List<String>> loadCategories() async {
    final prefs = await prefsFuture;
    return prefs.getStringList('needsly.categories') ?? [];
  }

  Future<void> saveCategories(List<String> categories) async {
    final prefs = await prefsFuture;
    await prefs.setStringList('needsly.categories', categories);
  }

  Future<void> removeCategory(int idx) async {
    final prefs = await prefsFuture;
    final categories = prefs.getStringList('needsly.categories') ?? [];
    final removedCategory = categories.removeAt(idx);
    saveCategories(categories);
    removeSubcategories(removedCategory);
  }

  Future<void> renameCategory(int idx, String fromCategory, String toCategory) async {
    final prefs = await prefsFuture;
    final categories = prefs.getStringList('needsly.categories') ?? [];
    categories[idx] = toCategory;

    final subcategories = await loadSubcategories(fromCategory);

    for (var subcategory in subcategories) {
      final items = await loadItems(fromCategory, subcategory);
      addSubcategoryWithItems(toCategory, subcategory, items);
    }

    removeSubcategories(fromCategory);
    saveCategories(categories);
  }

  // Subcategories
  Future<List<String>> loadSubcategories(String category) async {
    final prefs = await prefsFuture;
    return prefs.getStringList('needsly.$category') ?? [];
  }

  void updateSubcategories(String category, List<String> subcategories) async {
    final prefs = await prefsFuture;
    await prefs.setStringList('needsly.$category', subcategories);
  }

  void removeSubcategory(String category, String subcategory) async {
    final prefs = await prefsFuture;
    await prefs.remove('needsly.$category.$subcategory');
    final subcategories = prefs.getStringList('needsly.$category') ?? [];
    subcategories.remove(subcategory);
    updateSubcategories(category, subcategories);
  }
  
  void removeSubcategories(String category) async {
    final prefs = await prefsFuture;
    final subcategoriesToRemove = prefs.getStringList('needsly.$category') ?? [];    
    await prefs.remove('needsly.$category');
    removeItems(category, subcategoriesToRemove);
  }

  void renameSubcategory(
    String category,
    String fromSubcategory,
    String toSubcategory,
    List<String> items,
  ) async {
    addSubcategoryWithItems(category, toSubcategory, items);
    removeSubcategory(category, fromSubcategory);
  }

  // Items
  void addSubcategoryWithItems(
    String category,
    String subcategory,
    List<String> items,
  ) async {
    final prefs = await prefsFuture;
    final subcategories = prefs.getStringList('needsly.$category') ?? [];
    await prefs.setStringList('needsly.$category.$subcategory', items);
    updateSubcategories(category, [...subcategories, subcategory]);
  }

  Future<List<String>> loadItems(String category, String subcategory) async {
    final prefs = await prefsFuture;
    return prefs.getStringList('needsly.$category.$subcategory') ?? [];
  }

  Future<void> saveItems(
    String category,
    String subcategory,
    List<String> items,
  ) async {
    final prefs = await prefsFuture;
    await prefs.setStringList('needsly.$category.$subcategory', items);
  }

  Future<void> removeItems(String category, List<String> subcategories) async {
    final prefs = await prefsFuture;
    for (var subcategory in subcategories) {
      await prefs.remove('needsly.$category.$subcategory');
    }
  }
}
