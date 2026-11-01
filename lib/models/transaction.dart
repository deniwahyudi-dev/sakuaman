import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String source; // e.g. "BCA", "GoPay", "Mandiri", "Manual", "DANA", "ShopeePay"
  final String? note;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.source = "Manual",
    this.note,
  });

  String get formattedAmount {
    try {
      final currencyFormatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      final prefix = type == TransactionType.income ? '+ ' : '- ';
      return '$prefix${currencyFormatter.format(amount)}';
    } catch (_) {
      final prefix = type == TransactionType.income ? '+ Rp ' : '- Rp ';
      return '$prefix${amount.toStringAsFixed(0)}';
    }
  }

  String get formattedDate {
    try {
      return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(date);
    } catch (_) {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  IconData get categoryIcon {
    switch (category.toLowerCase()) {
      case 'makanan & minuman':
      case 'makanan':
        return CupertinoIcons.bag_fill;
      case 'transportasi':
        return CupertinoIcons.car_detailed;
      case 'gaji':
      case 'pendapatan':
        return CupertinoIcons.money_dollar_circle_fill;
      case 'belanja':
        return CupertinoIcons.cart_fill;
      case 'hiburan':
        return CupertinoIcons.tv_fill;
      case 'tagihan':
      case 'utilitas':
        return CupertinoIcons.doc_text_fill;
      case 'kesehatan':
        return CupertinoIcons.heart_fill;
      case 'investasi':
        return CupertinoIcons.chart_pie_fill;
      default:
        return CupertinoIcons.square_list_fill;
    }
  }

  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'makanan & minuman':
      case 'makanan':
        return const Color(0xFFFF9500); // iOS Orange
      case 'transportasi':
        return const Color(0xFF007AFF); // iOS Blue
      case 'gaji':
      case 'pendapatan':
        return const Color(0xFF34C759); // iOS Green
      case 'belanja':
        return const Color(0xFFAF52DE); // iOS Purple
      case 'hiburan':
        return const Color(0xFFFF2D55); // iOS Pink
      case 'tagihan':
      case 'utilitas':
        return const Color(0xFFFF3B30); // iOS Red
      case 'kesehatan':
        return const Color(0xFF5AC8FA); // iOS Teal
      case 'investasi':
        return const Color(0xFF5856D6); // iOS Indigo
      default:
        return const Color(0xFF8E8E93); // iOS Gray
    }
  }
}
