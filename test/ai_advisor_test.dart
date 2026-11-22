import 'package:flutter_test/flutter_test.dart';
import 'package:finances/models/transaction.dart';
import 'package:finances/models/budget.dart';
import 'package:finances/services/ai_advisor.dart';

void main() {
  group('LocalAIAdvisor', () {
    test('daftar kosong menghasilkan hasEnoughData false', () {
      final health = LocalAIAdvisor.analyze([]);
      expect(health.hasEnoughData, false);
    });

    test('1 pemasukan + 3 pengeluaran menghasilkan hasEnoughData true', () {
      final now = DateTime(2026, 11, 7);
      final transactions = [
        TransactionModel(
          id: '1',
          title: 'Gaji',
          amount: 5000000,
          type: TransactionType.income,
          category: 'Gaji',
          date: DateTime(2026, 11, 5),
        ),
        TransactionModel(
          id: '2',
          title: 'Makan',
          amount: 50000,
          type: TransactionType.expense,
          category: 'Makanan',
          date: DateTime(2026, 11, 5),
        ),
        TransactionModel(
          id: '3',
          title: 'Transportasi',
          amount: 30000,
          type: TransactionType.expense,
          category: 'Transportasi',
          date: DateTime(2026, 11, 6),
        ),
        TransactionModel(
          id: '4',
          title: 'Belanja',
          amount: 200000,
          type: TransactionType.expense,
          category: 'Belanja',
          date: DateTime(2026, 11, 7),
        ),
      ];
      final health = LocalAIAdvisor.analyze(transactions, now);
      expect(health.hasEnoughData, true);
    });

    test('transaksi bulan lalu tidak ikut dihitung', () {
      final now = DateTime(2026, 11, 7);
      final transactions = [
        TransactionModel(
          id: '1',
          title: 'Gaji Oktober',
          amount: 5000000,
          type: TransactionType.income,
          category: 'Gaji',
          date: DateTime(2026, 10, 31),
        ),
        TransactionModel(
          id: '2',
          title: 'Gaji November',
          amount: 5000000,
          type: TransactionType.income,
          category: 'Gaji',
          date: DateTime(2026, 11, 5),
        ),
        TransactionModel(
          id: '3',
          title: 'Makan',
          amount: 50000,
          type: TransactionType.expense,
          category: 'Makanan',
          date: DateTime(2026, 11, 5),
        ),
        TransactionModel(
          id: '4',
          title: 'Transportasi',
          amount: 30000,
          type: TransactionType.expense,
          category: 'Transportasi',
          date: DateTime(2026, 11, 6),
        ),
        TransactionModel(
          id: '5',
          title: 'Belanja',
          amount: 200000,
          type: TransactionType.expense,
          category: 'Belanja',
          date: DateTime(2026, 11, 7),
        ),
      ];
      final health = LocalAIAdvisor.analyze(transactions, now);
      expect(health.hasEnoughData, true);
    });

    test('kategori "Makanan & Minuman" terhitung sebagai kebutuhan', () {
      final now = DateTime(2026, 11, 7);
      final transactions = [
        TransactionModel(
          id: '1',
          title: 'Gaji',
          amount: 10000000,
          type: TransactionType.income,
          category: 'Gaji',
          date: DateTime(2026, 11, 5),
        ),
        TransactionModel(
          id: '2',
          title: 'Makan & Minum',
          amount: 5000000,
          type: TransactionType.expense,
          category: 'Makanan & Minuman',
          date: DateTime(2026, 11, 5),
        ),
        TransactionModel(
          id: '3',
          title: 'Transport',
          amount: 500000,
          type: TransactionType.expense,
          category: 'Transportasi',
          date: DateTime(2026, 11, 6),
        ),
        TransactionModel(
          id: '4',
          title: 'Belanja',
          amount: 1000000,
          type: TransactionType.expense,
          category: 'Belanja',
          date: DateTime(2026, 11, 7),
        ),
      ];
      final health = LocalAIAdvisor.analyze(transactions, now);
      expect(health.hasEnoughData, true);
      expect(health.needsPercentage, greaterThan(50));
    });

    test('wantsPercentage 32% tidak menghasilkan pesan "di bawah 30%"', () {
      final now = DateTime(2026, 11, 7);
      final transactions = [
        TransactionModel(
          id: '1',
          title: 'Gaji',
          amount: 10000000,
          type: TransactionType.income,
          category: 'Gaji',
          date: DateTime(2026, 11, 5),
        ),
        TransactionModel(
          id: '2',
          title: 'Makan',
          amount: 3200000,
          type: TransactionType.expense,
          category: 'Makanan',
          date: DateTime(2026, 11, 5),
        ),
        TransactionModel(
          id: '3',
          title: 'Belanja',
          amount: 3200000,
          type: TransactionType.expense,
          category: 'Belanja',
          date: DateTime(2026, 11, 6),
        ),
        TransactionModel(
          id: '4',
          title: 'Hiburan',
          amount: 1000000,
          type: TransactionType.expense,
          category: 'Hiburan',
          date: DateTime(2026, 11, 7),
        ),
      ];
      final health = LocalAIAdvisor.analyze(transactions, now);
      expect(health.hasEnoughData, true);

      final wantsInsight = health.insights.firstWhere(
        (insight) => insight.contains('Keinginan'),
        orElse: () => '',
      );
      expect(wantsInsight.isEmpty || !wantsInsight.contains('di bawah 30%'), true);
    });

    test('insight anggaran muncul saat 85% terpakai', () {
      final now = DateTime(2026, 11, 7);
      final transactions = [
        TransactionModel(
          id: '1',
          title: 'Gaji',
          amount: 10000000,
          type: TransactionType.income,
          category: 'Gaji',
          date: DateTime(2026, 11, 5),
        ),
        TransactionModel(
          id: '2',
          title: 'Makan',
          amount: 8500000,
          type: TransactionType.expense,
          category: 'Makanan',
          date: DateTime(2026, 11, 5),
        ),
        TransactionModel(
          id: '3',
          title: 'Transportasi',
          amount: 500000,
          type: TransactionType.expense,
          category: 'Transportasi',
          date: DateTime(2026, 11, 6),
        ),
        TransactionModel(
          id: '4',
          title: 'Belanja',
          amount: 1000000,
          type: TransactionType.expense,
          category: 'Belanja',
          date: DateTime(2026, 11, 7),
        ),
      ];
      final budgets = [
        Budget(category: 'Makanan', limit: 10000000),
      ];
      final health = LocalAIAdvisor.analyze(transactions, now, budgets);
      expect(health.hasEnoughData, true);
      expect(health.insights.length, greaterThan(1));
      final budgetInsight = health.insights.firstWhere(
        (i) => i.contains('Anggaran') && i.contains('Makanan'),
        orElse: () => '',
      );
      expect(budgetInsight.contains('85%'), true);
    });

    test('tidak muncul insight anggaran bila budgets kosong', () {
      final now = DateTime(2026, 11, 7);
      final transactions = [
        TransactionModel(
          id: '1',
          title: 'Gaji',
          amount: 10000000,
          type: TransactionType.income,
          category: 'Gaji',
          date: DateTime(2026, 11, 5),
        ),
        TransactionModel(
          id: '2',
          title: 'Makan',
          amount: 8500000,
          type: TransactionType.expense,
          category: 'Makanan',
          date: DateTime(2026, 11, 5),
        ),
        TransactionModel(
          id: '3',
          title: 'Transportasi',
          amount: 500000,
          type: TransactionType.expense,
          category: 'Transportasi',
          date: DateTime(2026, 11, 6),
        ),
        TransactionModel(
          id: '4',
          title: 'Belanja',
          amount: 1000000,
          type: TransactionType.expense,
          category: 'Belanja',
          date: DateTime(2026, 11, 7),
        ),
      ];
      final budgets = <Budget>[];
      final health = LocalAIAdvisor.analyze(transactions, now, budgets);
      expect(health.hasEnoughData, true);
      final budgetInsight = health.insights.where((i) => i.contains('Anggaran')).toList();
      expect(budgetInsight.isEmpty, true);
    });
  });
}
