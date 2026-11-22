import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class BackupParseResult {
  final List<TransactionModel> transactions;
  final int skipped;
  BackupParseResult(this.transactions, this.skipped);
}

class ExportService {
  static String buildCsv(List<TransactionModel> txs) {
    final buffer = StringBuffer();
    // BOM
    buffer.write('\uFEFF');
    // Header
    buffer.write('Tanggal,Judul,Tipe,Kategori,Sumber,Nominal,Catatan\r\n');

    final sortedTxs = List<TransactionModel>.from(txs)
      ..sort((a, b) => a.date.compareTo(b.date));

    for (final tx in sortedTxs) {
      final date = DateFormat('yyyy-MM-dd HH:mm').format(tx.date);
      final title = _escapeCsv(tx.title);
      final type = tx.type == TransactionType.income ? 'Pemasukan' : 'Pengeluaran';
      final category = _escapeCsv(tx.category);
      final source = _escapeCsv(tx.source);
      final nominal = tx.amount.toStringAsFixed(0);
      final note = _escapeCsv(tx.note ?? '');

      buffer.write('$date,$title,$type,$category,$source,$nominal,$note\r\n');
    }

    return buffer.toString();
  }

  static String _escapeCsv(String text) {
    final shouldQuote = text.contains(',') ||
        text.contains('"') ||
        text.contains('\n') ||
        text.contains('\r');
    
    // Prevent Excel formula injection
    String cleanText = text;
    if (cleanText.startsWith('=') ||
        cleanText.startsWith('+') ||
        cleanText.startsWith('-') ||
        cleanText.startsWith('@')) {
      cleanText = "'$cleanText";
    }

    if (shouldQuote) {
      cleanText = '"${cleanText.replaceAll('"', '""')}"';
    }
    return cleanText;
  }

  static String buildBackupJson(List<TransactionModel> txs) {
    final data = {
      "app": "SakuAman",
      "version": 1,
      "exportedAt": DateTime.now().toIso8601String(),
      "transactions": txs.map((tx) => tx.toJson()).toList(),
    };
    return json.encode(data);
  }

  static BackupParseResult? parseBackupJson(String text) {
    try {
      final jsonMap = json.decode(text) as Map<String, dynamic>;
      if (jsonMap['app'] != 'SakuAman') return null;

      final List<dynamic> txsJson = jsonMap['transactions'] as List<dynamic>;
      final List<TransactionModel> validTxs = [];
      int skipped = 0;

      for (final txJson in txsJson) {
        try {
          validTxs.add(TransactionModel.fromJson(txJson as Map<String, dynamic>));
        } catch (_) {
          skipped++;
        }
      }
      return BackupParseResult(validTxs, skipped);
    } catch (_) {
      return null;
    }
  }
}
