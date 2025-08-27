import 'package:flutter/material.dart';
import 'package:needsly/components/charts/top_subcategories.dart';
import 'package:needsly/components/datetime/date_range.dart';
import 'package:needsly/db/db.dart';
import 'package:provider/provider.dart';

class TopSubcategories extends StatefulWidget {
  final String category;

  const TopSubcategories({super.key, required this.category});

  @override
  State<StatefulWidget> createState() =>
      TopSubcategoriesState(category: category);
}

class TopSubcategoriesState extends State<TopSubcategories> {
  final String category;
  final DateTime now = DateTime.now();
  DateTime get defaultFrom => DateTime(now.year, now.month, 1);
  DateTime get defaultTo => now;
  late DateTime from;
  late DateTime to;

  TopSubcategoriesState({required this.category}) {
    from = DateTime(now.year, now.month, 1);
    to = now;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Top subcategories: $category')),
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
          topSubcategoriesChart(),
        ],
      ),
    );
  }

  Widget topSubcategoriesChart() {
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
        ],
      ),
    );
  }

  Widget buildTopSubcategoriesChart() {
    final dbRepo = Provider.of<DatabaseRepository>(context, listen: false);
    return FutureBuilder(
      future: dbRepo.getTopSubcategories(
        limit: 100,
        from: from,
        to: to,
        category: category,
      ),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final subcategoryRepetitions = snapshot.data!;
        if (subcategoryRepetitions.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.all(5),
            child: TopSubcategoriesPieChart(
              subcategoryRepetitions: subcategoryRepetitions,
            ),
          );
        }
        return Text('No data for the specified time range!');
      },
    );
  }
}
