class ItemRepetition {
  final String category;
  final String? subcategory;
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

class SubcategoryRepetition {
  final String category;
  final String subcategory;
  final DateTime from;
  final DateTime to;
  final int count;

  SubcategoryRepetition({
    required this.category,
    required this.subcategory,
    required this.from,
    required this.to,
    required this.count,
  });
}
