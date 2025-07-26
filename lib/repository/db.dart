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
class DatabaseRepository extends _$DatabaseRepository {
  DatabaseRepository() : super(openConnection());

  @override
  int get schemaVersion => 1;

  Future<int> addResolved(
    String category,
    String subcategory,
    String item,
    DateTime resolvedAt,
  ) {
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

  Future<List<ItemRepetition>> getTopItemsPerPeriod({
    required int limit,
    required DateTime from,
    required DateTime to,
    required String category,
    required String subcategory,
  }) async {
    final countExpr = resolvedItems.item.count();
    final result =
        (selectOnly(resolvedItems)
              ..addColumns([resolvedItems.item, countExpr])
              ..where(resolvedItems.category.equals(category))
              ..where(resolvedItems.subcategory.equals(subcategory))
              ..where(resolvedItems.resolvedAt.isBetweenValues(from, to))
              ..groupBy([resolvedItems.item]))
            .get();
    final finalResult = result.then((r) {
      return r.map((row) {
        return ItemRepetition(
          category: category,
          subcategory: subcategory,
          item: row.read(resolvedItems.item)!,
          from: from,
          to: to,
          count: row.read(countExpr)!,
        );
      }).toList();
    });
    return finalResult;
    // TODO
  }
}

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'app.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

class ItemRepetition {
  final String category;
  final String subcategory;
  final String item;
  final DateTime from;
  final DateTime to;
  final int count;

  ItemRepetition({
    required this.category,
    required this.subcategory,
    required this.item,
    required this.from,
    required this.to,
    required this.count,
  });
}
