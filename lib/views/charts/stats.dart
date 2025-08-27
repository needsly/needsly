import 'package:flutter/material.dart';
import 'package:needsly/components/charts/top_items.dart';
import 'package:needsly/components/charts/top_subcategories.dart';
import 'package:needsly/db/db.dart';
import 'package:needsly/views/charts/top_items.dart';
import 'package:needsly/views/charts/top_subcategories.dart';
import 'package:provider/provider.dart';

class StatsPage extends StatefulWidget {
  final String category;
  final String? subcategory;

  const StatsPage({super.key, required this.category, this.subcategory});

  @override
  State<StatefulWidget> createState() =>
      StatsPageState(category: category, subcategory: subcategory);
}

class StatsPageState extends State<StatsPage> {
  final String category;
  final String? subcategory;

  StatsPageState({required this.category, this.subcategory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(getAppBarTitle())),
      body: ListView(
        padding: const EdgeInsets.all(5),
        children: [
          Padding(padding: EdgeInsets.only(left: 5), child: Text('This month')),
          ...getCharts(),
        ],
      ),
    );
  }

  List<Widget> getCharts() {
    if (subcategory != null) {
      return [topItemsChart()];
    } else {
      return [topItemsChart(), topSubcategoriessChart()];
    }
  }

  String getAppBarTitle() {
    if (subcategory != null) {
      return 'Stats: $category :: $subcategory';
    } else {
      return 'Stats: $category';
    }
  }

  Widget topItemsChart() {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(5),
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
          SizedBox(height: 250, child: buildTopItemsChart()),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      TopItems(category: category, subcategory: subcategory),
                ),
              );
            },
            child: const Text(
              'Show more..',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTopItemsChart() {
    final now = DateTime.now();
    final dbRepo = Provider.of<DatabaseRepository>(context, listen: false);
    return FutureBuilder(
      future: dbRepo.getTopItems(
        limit: 10,
        from: DateTime(now.year, now.month, 1),
        to: now,
        category: category,
        subcategory: subcategory,
      ),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final itemRepetitions = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(5),
          child: TopItemsBarChart(itemRepetitions: itemRepetitions),
        );
      },
    );
  }

  Widget topSubcategoriessChart() {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(5),
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
            'Top Subcategories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 250, child: buildTopSubcategoriesChart()),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TopSubcategories(category: category),
                ),
              );
            },
            child: const Text(
              'Show more..',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTopSubcategoriesChart() {
    final now = DateTime.now();
    final dbRepo = Provider.of<DatabaseRepository>(context, listen: false);
    return FutureBuilder(
      future: dbRepo.getTopSubcategories(
        limit: 10,
        from: DateTime(now.year, now.month, 1),
        to: now,
        category: category,
      ),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final subcategoryRepetitions = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(5),
          child: TopSubcategoriesPieChart(
            subcategoryRepetitions: subcategoryRepetitions,
          ),
        );
      },
    );
  }
}
