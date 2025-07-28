import 'package:flutter/material.dart';
import 'package:needsly/components/charts/top_items.dart';
import 'package:needsly/components/charts/top_subcategories.dart';
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
    return Scaffold(
      appBar: AppBar(title: Text(getAppBarTitle())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: getCharts(),
      ),
    );
  }

  List<Widget> getCharts() {
    if (subcategory != null) {
      return [topItemsPieChart()];
    } else {
      return [topItemsPieChart(), topSubcategoriessPieChart()]; 
    }
  }

  String getAppBarTitle() {
    if (subcategory != null) {
      return 'Stats: $category :: $subcategory';
    } else {
      return 'Stats: $category';
    }
  }

  Widget topItemsPieChart() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        border: Border.all(color: Colors.grey, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Top items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 250, child: buildTopItemsPieChart()),
        ],
      ),
    );
  }

  Widget buildTopItemsPieChart() {
    return FutureBuilder(
      future: dbRepo.getTopItems(
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

  Widget topSubcategoriessPieChart() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        border: Border.all(color: Colors.grey, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Top Lists',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 250, child: buildTopSubcategoriesPieChart()),
        ],
      ),
    );
  }

  Widget buildTopSubcategoriesPieChart() {
    return FutureBuilder(
      future: dbRepo.getTopSubcategories(
        limit: 10,
        from: DateTime.now().subtract(Duration(days: 30)),
        to: DateTime.now(),
        category: category,
      ),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final subcategoryRepetitions = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: TopSubcategoriesPieChart(
            subcategoryRepetitions: subcategoryRepetitions,
          ),
        );
      },
    );
  }
}
