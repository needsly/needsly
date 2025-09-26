import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesRepository {
  final prefsFuture = SharedPreferences.getInstance();

  // Categories
  Future<List<String>> loadCategories(String prefix) async {
    final prefs = await prefsFuture;
    return prefs.getStringList(prefix) ?? [];
  }

  Future<void> saveCategories(String prefix, List<String> categories) async {
    final prefs = await prefsFuture;
    await prefs.setStringList(prefix, categories);
  }

  Future<void> removeCategory(String prefix, int idx) async {
    final prefs = await prefsFuture;
    final categories = prefs.getStringList(prefix) ?? [];
    final removedCategory = categories.removeAt(idx);
    saveCategories(prefix, categories);
    _removeSubcategories(prefix, removedCategory);
  }

  Future<void> renameCategory(
    String prefix,
    int idx,
    String fromCategory,
    String toCategory,
  ) async {
    final prefs = await prefsFuture;
    final categories = prefs.getStringList(prefix) ?? [];
    categories[idx] = toCategory;

    final subcategories = await loadSubcategories(prefix, fromCategory);

    for (var subcategory in subcategories) {
      final items = await loadItems(prefix, fromCategory, subcategory);
      addSubcategoryWithItems(prefix, toCategory, subcategory, items);
    }

    _removeSubcategories(prefix, fromCategory);
    saveCategories(prefix, categories);
  }

  // Subcategories
  Future<List<String>> loadSubcategories(String prefix, String category) async {
    final prefs = await prefsFuture;
    return prefs.getStringList('$prefix.$category') ?? [];
  }

  Future<Map<String, List<String>>> loadItemsBySubcategories(
    String prefix,
    String category,
  ) async {
    final prefs = await prefsFuture;
    final subcategories = prefs.getStringList('$prefix.$category') ?? [];

    final itemsBySubcategories = subcategories.fold<Map<String, List<String>>>(
      {},
      (prev, next) {
        final items = prefs.getStringList('$prefix.$category.$next') ?? [];
        prev[next] = items;
        return prev;
      },
    );
    return itemsBySubcategories;
  }

  void updateSubcategories(
    String prefix,
    String category,
    List<String> subcategories,
  ) async {
    final prefs = await prefsFuture;
    await prefs.setStringList('$prefix.$category', subcategories);
  }

  void _removeSubcategory(
    String prefix,
    String category,
    String subcategory,
  ) async {
    final prefs = await prefsFuture;
    await prefs.remove('$prefix.$category.$subcategory');
    final subcategories = prefs.getStringList('$prefix.$category') ?? [];
    subcategories.remove(subcategory);
    updateSubcategories(prefix, category, subcategories);
  }

  void _removeSubcategories(String prefix, String category) async {
    final prefs = await prefsFuture;
    final subcategoriesToRemove =
        prefs.getStringList('$prefix.$category') ?? [];
    await prefs.remove('$prefix.$category');
    _removeItems(prefix, category, subcategoriesToRemove);
  }

  void renameSubcategory(
    String prefix,
    String category,
    String fromSubcategory,
    String toSubcategory,
    List<String> items,
  ) async {
    addSubcategoryWithItems(prefix, category, toSubcategory, items);
    _removeSubcategory(prefix, category, fromSubcategory);
  }

  // Items
  void addSubcategoryWithItems(
    String prefix,
    String category,
    String subcategory,
    List<String> items,
  ) async {
    final prefs = await prefsFuture;
    final subcategories = prefs.getStringList('$prefix.$category') ?? [];
    await prefs.setStringList('$prefix.$category.$subcategory', items);
    updateSubcategories(prefix, category, [...subcategories, subcategory]);
  }

  Future<List<String>> loadItems(
    String prefix,
    String category,
    String subcategory,
  ) async {
    final prefs = await prefsFuture;
    return prefs.getStringList('$prefix.$category.$subcategory') ?? [];
  }

  Future<void> saveItems(
    String prefix,
    String category,
    String subcategory,
    List<String> items,
  ) async {
    final prefs = await prefsFuture;
    await prefs.setStringList('$prefix.$category.$subcategory', items);
  }

  Future<void> _removeItems(
    String prefix,
    String category,
    List<String> subcategories,
  ) async {
    final prefs = await prefsFuture;
    for (var subcategory in subcategories) {
      await prefs.remove('$prefix.$category.$subcategory');
    }
  }

  // Shared projects
  Future<void> updateFirebaseProjectCreds(
    String projectName,
    String apiKey,
    String appId,
    String projectId,
    String messagingSenderId,
    String authDomain,
  ) async {
    final prefs = await prefsFuture;
    prefs.setString(
      'needsly.firebase.$projectName.credentials.api_key',
      apiKey,
    );
    prefs.setString('needsly.firebase.$projectName.credentials.app_id', appId);
    prefs.setString(
      'needsly.firebase.$projectName.credentials.project_id',
      projectId,
    );
    prefs.setString(
      'needsly.firebase.$projectName.credentials.messaging_sender_id',
      messagingSenderId,
    );
    prefs.setString(
      'needsly.firebase.$projectName.credentials.auth_domain',
      authDomain,
    );
  }

  Future<FirebaseOptions?> loadFirebaseProjectOptions(
    String projectName,
  ) async {
    final prefs = await prefsFuture;

    final apiKey = prefs.getString(
      'needsly.firebase.$projectName.credentials.api_key',
    );
    final appId = prefs.getString(
      'needsly.firebase.$projectName.credentials.app_id',
    );
    final projectId = prefs.getString(
      'needsly.firebase.$projectName.credentials.project_id',
    );
    final senderId = prefs.getString(
      'needsly.firebase.$projectName.credentials.messaging_sender_id',
    );
    final authDomain = prefs.getString(
      'needsly.firebase.$projectName.credentials.auth_domain',
    );
    if (apiKey == null ||
        appId == null ||
        senderId == null ||
        projectId == null ||
        authDomain == null) {
      return null;
    }
    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: senderId,
      projectId: projectId,
      authDomain: authDomain,
    );
  }
}
