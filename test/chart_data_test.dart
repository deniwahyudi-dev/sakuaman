import 'package:flutter_test/flutter_test.dart';
import 'package:finances/models/transaction.dart';
import 'package:finances/services/chart_data.dart';

void main() {
  final now = DateTime(2026, 11, 7);

  group('ChartData tests', () {
    test('expenseByCategory mengabaikan pemasukan, bulan lain, dan terurut terbesar', () {
      final txs = [
        TransactionModel(
          id: '1',
          title: 'Gaji',
          amount: 5000000,
          type: TransactionType.income,
          category: 'Gaji',
          date: DateTime(2026, 11, 1),
        ),
        TransactionModel(
          id: '2',
          title: 'Makan 1',
          amount: 50000,
          type: TransactionType.expense,
          category: 'Makanan',
          date: DateTime(2026, 11, 2),
        ),
        TransactionModel(
          id: '3',
          title: 'Makan 2',
          amount: 150000,
          type: TransactionType.expense,
          category: 'Makanan',
          date: DateTime(2026, 11, 3),
        ),
        TransactionModel(
          id: '4',
          title: 'Bensin',
          amount: 100000,
          type: TransactionType.expense,
          category: 'Transportasi',
          date: DateTime(2026, 11, 4),
        ),
        TransactionModel(
          id: '5',
          title: 'Bulan Lalu',
          amount: 500000,
          type: TransactionType.expense,
          category: 'Belanja',
          date: DateTime(2026, 10, 31),
        ),
      ];

      final result = expenseByCategory(txs, now);

      // Harusnya hanya Makanan (200.000) dan Transportasi (100.000)
      expect(result.length, 2);
      expect(result.keys.first, 'Makanan');
      expect(result['Makanan'], 200000);
      expect(result.keys.last, 'Transportasi');
      expect(result['Transportasi'], 100000);
    });

    test('expenseLast7Days tepat panjang 7 dan nilainya benar', () {
      final txs = [
        // 6 hari lalu (1 Nov)
        TransactionModel(
          id: '1',
          title: 'T1',
          amount: 10000,
          type: TransactionType.expense,
          category: 'Makanan',
          date: DateTime(2026, 11, 1),
        ),
        // Hari ini (7 Nov)
        TransactionModel(
          id: '2',
          title: 'T2',
          amount: 25000,
          type: TransactionType.expense,
          category: 'Makanan',
          date: DateTime(2026, 11, 7),
        ),
        // Hari ini (7 Nov) lagi
        TransactionModel(
          id: '3',
          title: 'T3',
          amount: 15000,
          type: TransactionType.expense,
          category: 'Transportasi',
          date: DateTime(2026, 11, 7),
        ),
        // Pemasukan hari ini (diabaikan)
        TransactionModel(
          id: '4',
          title: 'Inc',
          amount: 50000,
          type: TransactionType.income,
          category: 'Gaji',
          date: DateTime(2026, 11, 7),
        ),
        // 8 hari lalu (30 Okt - diabaikan)
        TransactionModel(
          id: '5',
          title: 'Old',
          amount: 90000,
          type: TransactionType.expense,
          category: 'Makanan',
          date: DateTime(2026, 10, 30),
        ),
      ];

      final result = expenseLast7Days(txs, now);

      expect(result.length, 7);
      // Tanggal awal = 1 Nov, Tanggal akhir = 7 Nov
      expect(result.first.day, DateTime(2026, 11, 1));
      expect(result.first.total, 10000);

      expect(result.last.day, DateTime(2026, 11, 7));
      expect(result.last.total, 40000); // 25000 + 15000

      // Hari ke-2 sampai ke-6 harusnya 0
      for (int i = 1; i < 6; i++) {
        expect(result[i].total, 0);
      }
    });
  });
}
