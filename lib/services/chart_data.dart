import '../models/transaction.dart';

class DailyTotal {
  final DateTime day;
  final double total;

  DailyTotal(this.day, this.total);
}

Map<String, double> expenseByCategory(List<TransactionModel> txs, DateTime now) {
  final expenses = txs.where((tx) =>
      tx.type == TransactionType.expense &&
      tx.date.year == now.year &&
      tx.date.month == now.month);

  final Map<String, double> grouped = {};
  for (var tx in expenses) {
    grouped[tx.category] = (grouped[tx.category] ?? 0) + tx.amount;
  }

  final sortedEntries = grouped.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return Map.fromEntries(sortedEntries);
}

List<DailyTotal> expenseLast7Days(List<TransactionModel> txs, DateTime now) {
  final List<DailyTotal> results = [];
  final today = DateTime(now.year, now.month, now.day);

  for (int i = 6; i >= 0; i--) {
    final day = today.subtract(Duration(days: i));
    double total = 0;

    for (var tx in txs) {
      if (tx.type == TransactionType.expense &&
          tx.date.year == day.year &&
          tx.date.month == day.month &&
          tx.date.day == day.day) {
        total += tx.amount;
      }
    }
    results.add(DailyTotal(day, total));
  }

  return results;
}
