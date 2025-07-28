import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:needsly/dto/dto.dart';

class TopItemsPieChart extends StatelessWidget {
  final List<ItemRepetition> itemRepetitions;

  const TopItemsPieChart({super.key, required this.itemRepetitions});

  @override
  Widget build(BuildContext context) {
    final total = itemRepetitions.fold<int>(0, (sum, e) => sum + e.count);

    return PieChart(
      PieChartData(
        sections: itemRepetitions.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final value = (item.count / total) * 100;

          final colors = [
            Colors.blue,
            Colors.red,
            Colors.green,
            Colors.orange,
            Colors.purple,
            Colors.cyan,
          ];

          return PieChartSectionData(
            value: item.count.toDouble(),
            color: colors[index % colors.length],
            title: '${item.item} (${value.toStringAsFixed(1)}%)',
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
