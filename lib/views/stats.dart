import 'package:flutter/material.dart';
import 'package:needsly/components/charts/top_items.dart';
import 'package:needsly/repository/db.dart';

class StatsPage extends StatefulWidget {
  final String category;
  final String? subcategory;

  const StatsPage({super.key, required this.category, this.subcategory});

  @override
  State<StatefulWidget> createState() =>
      StatsPageState(category: category, subcategory: subcategory);
}

class StatsPageState extends State<StatsPage> {
  final dbRepo = DatabaseRepository();

  final String category;
  final String? subcategory;

  StatsPageState({required this.category, this.subcategory});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: dbRepo.getTopItemsPerPeriod(
        limit: 10,
        from: DateTime.now().subtract(Duration(days: 30)),
        to: DateTime.now(),
        category: category,
        subcategory: subcategory,
      ),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final itemRepetitions = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: TopItemsPieChart(itemRepetitions: itemRepetitions),
        );
      },
    );
  }
}
