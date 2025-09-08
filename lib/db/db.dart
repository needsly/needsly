import 'package:drift/drift.dart';
import 'package:needsly/dto/dto.dart';
import 'connection/connection.dart';
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

  Future<int> addResolvedItem(
    String category,
    String subcategory,
    String item,
    DateTime resolvedAt,
  ) async {
    return into(resolvedItems).insert(
      ResolvedItemsCompanion.insert(
        category: category,
        subcategory: subcategory,
        item: item,
        resolvedAt: Value(resolvedAt),
      ),
    );
  }

  Future<List<SubcategoryRepetition>> getTopSubcategories({
    required int limit,
    required DateTime from,
    required DateTime to,
    required String category,
  }) async {
    final toInclusive = to.add(const Duration(days: 1));
    final countExpr = resolvedItems.subcategory.count();
    final result =
        (selectOnly(resolvedItems)
              ..addColumns([resolvedItems.subcategory, countExpr])
              ..where(resolvedItems.category.equals(category))
              ..where(resolvedItems.resolvedAt.isBetweenValues(from, toInclusive))
              ..groupBy([resolvedItems.subcategory]))
            .get();
    final finalResult = result.then((r) {
      return r.map((row) {
        return SubcategoryRepetition(
          category: category,
          subcategory: row.read(resolvedItems.subcategory)!,
          from: from,
          to: toInclusive,
          count: row.read(countExpr)!,
        );
      }).toList();
    });
    return finalResult;
  }

  Future<List<ItemRepetition>> getTopItems({
    required int limit,
    required DateTime from,
    required DateTime to,
    required String category,
    String? subcategory,
  }) async {
    final toInclusive = to.add(const Duration(days: 1));
    final countExpr = resolvedItems.item.count();
    final result = getTopItemsPerPeriodQuery(
      countExpr,
      category,
      subcategory,
      from,
      toInclusive,
      limit,
    ).get();
    final finalResult = result.then((r) {
      return r.map((row) {
        return ItemRepetition(
          category: category,
          subcategory: subcategory,
          item: row.read(resolvedItems.item)!,
          from: from,
          to: toInclusive,
          count: row.read(countExpr)!,
        );
      }).toList();
    });
    return finalResult;
  }

  JoinedSelectStatement<$ResolvedItemsTable, ResolvedItem>
  getTopItemsPerPeriodQuery(
    Expression<int> countExpr,
    String category,
    String? subcategory,
    DateTime from,
    DateTime to,
    int limit,
  ) {
    final toInclusive = to.add(const Duration(days: 1));
    print('getTopItemsPerPeriodQuery: from=$from to=$toInclusive');
    if (subcategory == null) {
      return (selectOnly(resolvedItems)
          ..addColumns([resolvedItems.item, countExpr])
          ..where(resolvedItems.category.equals(category))
          ..where(resolvedItems.resolvedAt.isBetweenValues(from, toInclusive))
          ..groupBy([resolvedItems.item]))
        ..limit(limit);
    } else {
      return (selectOnly(resolvedItems)
        ..addColumns([resolvedItems.item, countExpr])
        ..where(resolvedItems.category.equals(category))
        ..where(resolvedItems.subcategory.equals(subcategory))
        ..where(resolvedItems.resolvedAt.isBetweenValues(from, toInclusive))
        ..groupBy([resolvedItems.item]));
    }
  }
}
