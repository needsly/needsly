import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
part 'db.g.dart';

class ResolvedItems extends Table {
  TextColumn get category => text().withLength(min: 1, max: 100)();
  TextColumn get subcategory => text().withLength(min: 1, max: 100)();
  TextColumn get item => text().withLength(min: 1, max: 100)();
  DateTimeColumn get resolvedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [ResolvedItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;

  Future<int> addResolved(String category, String subcategory, String item, DateTime resolvedAt) {
    return into(resolvedItems).insert(
      ResolvedItemsCompanion.insert(
        category: category,
        subcategory: subcategory,
        item: item,
        resolvedAt: Value(resolvedAt),
      ),
    );
  }

  Future<List<ResolvedItem>> getAllResolved() => select(resolvedItems).get();

  // Future<Map<String, Map<String, List<ResolvedItem>>> getResolvedByCategories() => select(
  //   resolvedItems.map((item) => {
      
  //   })
  //   ).get();
}

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'app.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
