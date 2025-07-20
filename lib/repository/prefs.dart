import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesRepository {
  final prefsFuture = SharedPreferences.getInstance();

  Future<List<String>> loadCategories() async {
    final prefs = await prefsFuture;
    return prefs.getStringList('needsly.categories') ?? [];
  }

  Future<void> saveCategories(List<String> items) async {
    final prefs = await prefsFuture;
    await prefs.setStringList('needsly.categories', items);
  }

  Future<List<String>> loadSubcategories(String category) async {
    final prefs = await prefsFuture;
    return prefs.getStringList('needsly.$category') ?? [];
  }

  void updateSubcategories(String category, List<String> subcategories) async {
    final prefs = await prefsFuture;
    await prefs.setStringList('needsly.$category', subcategories);
  }

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

  void removeSubcategory(String category, String subcategory) async {
    final prefs = await prefsFuture;
    await prefs.remove('needsly.$category.$subcategory');
    final subcategories = prefs.getStringList('needsly.$category') ?? [];
    subcategories.remove(subcategory);
    updateSubcategories(category, subcategories);
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
}
