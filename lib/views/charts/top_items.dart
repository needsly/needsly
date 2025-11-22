import 'package:flutter/material.dart';
import 'package:needsly/components/charts/top_items.dart';
import 'package:needsly/components/datetime/date_range.dart';
import 'package:needsly/db/db.dart';
import 'package:provider/provider.dart';

class TopItems extends StatefulWidget {
  final String category;
  final String? subcategory;

  const TopItems({super.key, required this.category, this.subcategory});

  @override
  State<StatefulWidget> createState() =>
      TopItemsState(category: category, subcategory: subcategory);
}

class TopItemsState extends State<TopItems> {
  final String category;
  final String? subcategory;
  final DateTime now = DateTime.now();
  DateTime get defaultFrom => DateTime(now.year, now.month, 1);
  DateTime get defaultTo => now;
  late DateTime from;
  late DateTime to;

  TopItemsState({required this.category, this.subcategory}) {
    from = DateTime(now.year, now.month, 1);
    to = now;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(getAppBarTitle())),
      body: ListView(
        padding: const EdgeInsets.all(5),
        children: [
          Container(
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DateRangePickerFormField(
              onChanged: (range) {
                if (range != null) {
                  setState(() {
                    from = range.start;
                    to = range.end;
                  });
                }
              },
              initialValue: DateTimeRange(start: defaultFrom, end: defaultTo),
            ),
          ),
          topItemsChart(),
        ],
      ),
    );
  }

  // TODO: clean up (duplication)
  Widget topItemsChart() {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        border: Border.all(color: Colors.grey, width: 2),
        borderRadius: BorderRadius.circular(12),
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
          buildTopItemsChart(),
        ],
      ),
    );
  }

  // TODO: clean up (duplication)
  Widget buildTopItemsChart() {
    final dbRepo = Provider.of<DatabaseRepository>(context, listen: false);
    return FutureBuilder(
      future: dbRepo.getTopItems(
        limit: 100,
        from: from,
        to: to,
        category: category,
        subcategory: subcategory,
      ),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final itemRepetitions = snapshot.data;
        if (snapshot.data!.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.all(5),
            child: TopItemsBarChart(itemRepetitions: itemRepetitions!),
          );
        }
        return Text('No data for the specified time range!');
      },
    );
  }

  String getAppBarTitle() {
    if (subcategory != null) {
      return 'Top items: $category :: $subcategory';
    } else {
      return 'Top items: $category';
    }
  }
}
