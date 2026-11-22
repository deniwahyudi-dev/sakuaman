import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../services/chart_data.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<DailyTotal> data;
  final bool isDark;

  const WeeklyBarChart({
    super.key,
    required this.data,
    required this.isDark,
  });

  String _shortDay(DateTime d) {
    final formatter = DateFormat('E', 'id_ID');
    return formatter.format(d).substring(0, 3);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    final barGroups = data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isToday = item.day.year == today.year &&
          item.day.month == today.month &&
          item.day.day == today.day;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.total,
            color: isToday
                ? const Color(0xFF007AFF)
                : (isDark
                    ? const Color(0xFF3A4C6D)
                    : const Color(0xFFD5DAE5)),
            width: 24,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    final maxY = data.map((e) => e.total).reduce((a, b) => a > b ? a : b);
    final yMax = maxY == 0 ? 1.0 : (maxY * 1.2).ceilToDouble();

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.center,
              maxY: yMax,
              barGroups: barGroups,
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < data.length) {
                        final day = data[value.toInt()].day;
                        return Text(
                          _shortDay(day),
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontSize: 11,
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final amount = rod.toY;
                    final format = NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    );
                    return BarTooltipItem(
                      format.format(amount),
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
