import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:needsly/dto/dto.dart';

class TopItemsBarChart extends StatelessWidget {
  final List<ItemRepetition> itemRepetitions;

  const TopItemsBarChart({super.key, required this.itemRepetitions});

  @override
  Widget build(BuildContext context) {
    final barGroups = itemRepetitions.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.count.toDouble(),
            color: Colors.blue,
            width: 18,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    final total = itemRepetitions.fold<int>(0, (sum, e) => sum + e.count);

    return RotatedBox(
      quarterTurns: 1,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY:
              (itemRepetitions
                  .map((e) => e.count)
                  .reduce((a, b) => a > b ? a : b) *
              1.2),
          barGroups: barGroups,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= itemRepetitions.length) {
                    return const SizedBox();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    // axisSide: meta.axisSide,
                    space: 6,
                    child: RotatedBox(
                      quarterTurns: -1,
                      child: Text(
                        itemRepetitions[index].item,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value % 1 == 0) {
                    return SideTitleWidget(
                      meta: meta,
                      space: 5,
                      child: RotatedBox(
                        quarterTurns: -1,
                        child: Text(value.toInt().toString()),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
