import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> data;
  final bool isDark;

  const CategoryPieChart({
    super.key,
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final total = data.values.fold(0.0, (sum, val) => sum + val);
    final entries = data.entries.toList();

    List<MapEntry<String, double>> displayEntries = [];
    if (entries.length <= 5) {
      displayEntries = entries;
    } else {
      displayEntries = entries.sublist(0, 5);
      final othersTotal = entries.sublist(5).fold(0.0, (sum, e) => sum + e.value);
      displayEntries.add(MapEntry('Lainnya (gabungan)', othersTotal));
    }

    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: displayEntries.map((e) {
                final percentage = (e.value / total) * 100;
                return PieChartSectionData(
                  color: TransactionModel.getCategoryColor(e.key),
                  value: e.value,
                  title: '${percentage.toStringAsFixed(0)}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: displayEntries.map((e) {
            final percentage = (e.value / total) * 100;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: TransactionModel.getCategoryColor(e.key),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${e.key} (${percentage.toStringAsFixed(0)}%)',
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
