import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:needsly/dto/dto.dart';

class TopSubcategoriesPieChart extends StatelessWidget {
  final List<SubcategoryRepetition> subcategoryRepetitions;

  const TopSubcategoriesPieChart({super.key, required this.subcategoryRepetitions});

  @override
  Widget build(BuildContext context) {
    if (subcategoryRepetitions.isEmpty) { 
      return Center(child: Text('No data'),);
    }
    final total = subcategoryRepetitions.fold<int>(0, (sum, e) => sum + e.count);

    return PieChart(
      PieChartData(
        sections: subcategoryRepetitions.asMap().entries.map((entry) {
          final index = entry.key;
          final subcategory = entry.value;
          final value = (subcategory.count / total) * 100;

          final colors = [
            Colors.blue,
            Colors.red,
            Colors.green,
            Colors.orange,
            Colors.purple,
            Colors.cyan,
          ];

          return PieChartSectionData(
            value: subcategory.count.toDouble(),
            color: colors[index % colors.length],
            title: '${subcategory.subcategory} (${value.toStringAsFixed(1)}%)',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        centerSpaceRadius: 30,
        sectionsSpace: 2,
      ),
    );
  }
}
