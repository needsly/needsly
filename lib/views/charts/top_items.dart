import 'package:flutter/material.dart';
import 'package:needsly/components/charts/top_items.dart';
import 'package:needsly/components/datetime/date_range.dart';
import 'package:needsly/repository/db.dart';

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

  final dbRepo = DatabaseRepository();

  TopItemsState({required this.category, this.subcategory}) {
    from = DateTime(now.year, now.month, 1);
    to = now;
  }

  @override
  Widget build(BuildContext context) {
    // selectedRange = DateTimeRange(start: now, end: now);
    return Scaffold(
      appBar: AppBar(title: Text(getAppBarTitle())),
      body: ListView(
        padding: const EdgeInsets.all(5),
        children: [
          // calendar chooser
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
          SizedBox(height: 250, child: buildTopItemsChart()),
        ],
      ),
    );
  }

  // TODO: clean up (duplication)
  Widget buildTopItemsChart() {
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
        } else {
          return Text('No data for the specified time range!');
        }
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
