import 'package:flutter_test/flutter_test.dart';
import 'package:finances/models/transaction.dart';
import 'package:finances/services/export_service.dart';

void main() {
  group('ExportService tests', () {
    test('buildCsv format check', () {
      final now = DateTime(2026, 11, 7, 10, 0);
      final txs = [
        TransactionModel(
          id: '1',
          title: 'Makan, Minum',
          amount: 50000,
          type: TransactionType.expense,
          category: 'Makanan',
          date: now,
          note: '=1+1\n"kutip"',
        ),
      ];

      final csv = ExportService.buildCsv(txs);
      
      // BOM
      expect(csv.startsWith('\uFEFF'), isTrue);
      // Header
      expect(csv.contains('Tanggal,Judul,Tipe,Kategori,Sumber,Nominal,Catatan'), isTrue);
      // Escaping and injection prevention
      // Title "Makan, Minum" should be quoted.
      // Note "=1+1\n"kutip"" should be quoted and start with '
      expect(csv.contains('"Makan, Minum"'), isTrue);
      expect(csv.contains("'=1+1"), isTrue);
    });

    test('JSON round-trip', () {
      final txs = [
        TransactionModel(
          id: '1',
          title: 'Gaji',
          amount: 5000000,
          type: TransactionType.income,
          category: 'Gaji',
          date: DateTime(2026, 11, 1),
        ),
      ];

      final json = ExportService.buildBackupJson(txs);
      final result = ExportService.parseBackupJson(json);
      
      expect(result, isNotNull);
      expect(result!.transactions.length, 1);
      expect(result.transactions[0].id, '1');
    });

    test('parseBackupJson invalid', () {
      final result = ExportService.parseBackupJson('{"app":"BukanSakuAman"}');
      expect(result, isNull);
      
      final result2 = ExportService.parseBackupJson('bukan json');
      expect(result2, isNull);
    });
  });
}
