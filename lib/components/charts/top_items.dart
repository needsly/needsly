import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:needsly/dto/dto.dart';

class TopItemsBarChart extends StatelessWidget {
  final List<ItemRepetition> itemRepetitions;

  const TopItemsBarChart({super.key, required this.itemRepetitions});

  @override
  Widget build(BuildContext context) {
    if (itemRepetitions.isEmpty) {
      return Center(child: Text('No data'));
    }
    final barGroups = itemRepetitions.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return BarChartGroupData(
        barsSpace: 5,
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.count.toDouble(),
            color: Colors.blue,
            width: 18,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    }).toList();

    return RotatedBox(
      quarterTurns: 1,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY:
              (itemRepetitions
                  .map((itemRepetition) => itemRepetition.count)
                  .reduce((prev, next) => prev > next ? prev : next) *
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
                    space: 2,
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
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
