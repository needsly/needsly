// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// ignore_for_file: type=lint
class $ResolvedItemsTable extends ResolvedItems
    with TableInfo<$ResolvedItemsTable, ResolvedItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResolvedItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subcategoryMeta = const VerificationMeta(
    'subcategory',
  );
  @override
  late final GeneratedColumn<String> subcategory = GeneratedColumn<String>(
    'subcategory',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemMeta = const VerificationMeta('item');
  @override
  late final GeneratedColumn<String> item = GeneratedColumn<String>(
    'item',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    category,
    subcategory,
    item,
    resolvedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'resolved_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResolvedItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('subcategory')) {
      context.handle(
        _subcategoryMeta,
        subcategory.isAcceptableOrUnknown(
          data['subcategory']!,
          _subcategoryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subcategoryMeta);
    }
    if (data.containsKey('item')) {
      context.handle(
        _itemMeta,
        item.isAcceptableOrUnknown(data['item']!, _itemMeta),
      );
    } else if (isInserting) {
      context.missing(_itemMeta);
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  ResolvedItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResolvedItem(
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      subcategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subcategory'],
      )!,
      item: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      )!,
    );
  }

  @override
  $ResolvedItemsTable createAlias(String alias) {
    return $ResolvedItemsTable(attachedDatabase, alias);
  }
}

class ResolvedItem extends DataClass implements Insertable<ResolvedItem> {
  final String category;
  final String subcategory;
  final String item;
  final DateTime resolvedAt;
  const ResolvedItem({
    required this.category,
    required this.subcategory,
    required this.item,
    required this.resolvedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['category'] = Variable<String>(category);
    map['subcategory'] = Variable<String>(subcategory);
    map['item'] = Variable<String>(item);
    map['resolved_at'] = Variable<DateTime>(resolvedAt);
    return map;
  }

  ResolvedItemsCompanion toCompanion(bool nullToAbsent) {
    return ResolvedItemsCompanion(
      category: Value(category),
      subcategory: Value(subcategory),
      item: Value(item),
      resolvedAt: Value(resolvedAt),
    );
  }

  factory ResolvedItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResolvedItem(
      category: serializer.fromJson<String>(json['category']),
      subcategory: serializer.fromJson<String>(json['subcategory']),
      item: serializer.fromJson<String>(json['item']),
      resolvedAt: serializer.fromJson<DateTime>(json['resolvedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'category': serializer.toJson<String>(category),
      'subcategory': serializer.toJson<String>(subcategory),
      'item': serializer.toJson<String>(item),
      'resolvedAt': serializer.toJson<DateTime>(resolvedAt),
    };
  }

  ResolvedItem copyWith({
    String? category,
    String? subcategory,
    String? item,
    DateTime? resolvedAt,
  }) => ResolvedItem(
    category: category ?? this.category,
    subcategory: subcategory ?? this.subcategory,
    item: item ?? this.item,
    resolvedAt: resolvedAt ?? this.resolvedAt,
  );
  ResolvedItem copyWithCompanion(ResolvedItemsCompanion data) {
    return ResolvedItem(
      category: data.category.present ? data.category.value : this.category,
      subcategory: data.subcategory.present
          ? data.subcategory.value
          : this.subcategory,
      item: data.item.present ? data.item.value : this.item,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResolvedItem(')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('item: $item, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(category, subcategory, item, resolvedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResolvedItem &&
          other.category == this.category &&
          other.subcategory == this.subcategory &&
          other.item == this.item &&
          other.resolvedAt == this.resolvedAt);
}

class ResolvedItemsCompanion extends UpdateCompanion<ResolvedItem> {
  final Value<String> category;
  final Value<String> subcategory;
  final Value<String> item;
  final Value<DateTime> resolvedAt;
  final Value<int> rowid;
  const ResolvedItemsCompanion({
    this.category = const Value.absent(),
    this.subcategory = const Value.absent(),
    this.item = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResolvedItemsCompanion.insert({
    required String category,
    required String subcategory,
    required String item,
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : category = Value(category),
       subcategory = Value(subcategory),
       item = Value(item);
  static Insertable<ResolvedItem> custom({
    Expression<String>? category,
    Expression<String>? subcategory,
    Expression<String>? item,
    Expression<DateTime>? resolvedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (category != null) 'category': category,
      if (subcategory != null) 'subcategory': subcategory,
      if (item != null) 'item': item,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResolvedItemsCompanion copyWith({
    Value<String>? category,
    Value<String>? subcategory,
    Value<String>? item,
    Value<DateTime>? resolvedAt,
    Value<int>? rowid,
  }) {
    return ResolvedItemsCompanion(
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      item: item ?? this.item,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (subcategory.present) {
      map['subcategory'] = Variable<String>(subcategory.value);
    }
    if (item.present) {
      map['item'] = Variable<String>(item.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResolvedItemsCompanion(')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('item: $item, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ResolvedItemsTable resolvedItems = $ResolvedItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [resolvedItems];
}

typedef $$ResolvedItemsTableCreateCompanionBuilder =
    ResolvedItemsCompanion Function({
      required String category,
      required String subcategory,
      required String item,
      Value<DateTime> resolvedAt,
      Value<int> rowid,
    });
typedef $$ResolvedItemsTableUpdateCompanionBuilder =
    ResolvedItemsCompanion Function({
      Value<String> category,
      Value<String> subcategory,
      Value<String> item,
      Value<DateTime> resolvedAt,
      Value<int> rowid,
    });

class $$ResolvedItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ResolvedItemsTable> {
  $$ResolvedItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get item => $composableBuilder(
    column: $table.item,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ResolvedItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ResolvedItemsTable> {
  $$ResolvedItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get item => $composableBuilder(
    column: $table.item,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ResolvedItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResolvedItemsTable> {
  $$ResolvedItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get item =>
      $composableBuilder(column: $table.item, builder: (column) => column);

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );
}

class $$ResolvedItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResolvedItemsTable,
          ResolvedItem,
          $$ResolvedItemsTableFilterComposer,
          $$ResolvedItemsTableOrderingComposer,
          $$ResolvedItemsTableAnnotationComposer,
          $$ResolvedItemsTableCreateCompanionBuilder,
          $$ResolvedItemsTableUpdateCompanionBuilder,
          (
            ResolvedItem,
            BaseReferences<_$AppDatabase, $ResolvedItemsTable, ResolvedItem>,
          ),
          ResolvedItem,
          PrefetchHooks Function()
        > {
  $$ResolvedItemsTableTableManager(_$AppDatabase db, $ResolvedItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResolvedItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResolvedItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResolvedItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> category = const Value.absent(),
                Value<String> subcategory = const Value.absent(),
                Value<String> item = const Value.absent(),
                Value<DateTime> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResolvedItemsCompanion(
                category: category,
                subcategory: subcategory,
                item: item,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String category,
                required String subcategory,
                required String item,
                Value<DateTime> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResolvedItemsCompanion.insert(
                category: category,
                subcategory: subcategory,
                item: item,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ResolvedItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResolvedItemsTable,
      ResolvedItem,
      $$ResolvedItemsTableFilterComposer,
      $$ResolvedItemsTableOrderingComposer,
      $$ResolvedItemsTableAnnotationComposer,
      $$ResolvedItemsTableCreateCompanionBuilder,
      $$ResolvedItemsTableUpdateCompanionBuilder,
      (
        ResolvedItem,
        BaseReferences<_$AppDatabase, $ResolvedItemsTable, ResolvedItem>,
      ),
      ResolvedItem,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ResolvedItemsTableTableManager get resolvedItems =>
      $$ResolvedItemsTableTableManager(_db, _db.resolvedItems);
}
