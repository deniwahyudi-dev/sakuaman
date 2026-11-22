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
  final String? userId;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.source = "Manual",
    this.note,
    this.userId,
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

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'makanan & minuman':
      case 'makanan':
        return const Color(0xFFFF9500);
      case 'transportasi':
        return const Color(0xFF007AFF);
      case 'gaji':
      case 'pendapatan':
        return const Color(0xFF34C759);
      case 'belanja':
        return const Color(0xFFAF52DE);
      case 'hiburan':
        return const Color(0xFFFF2D55);
      case 'tagihan':
      case 'utilitas':
        return const Color(0xFFFF3B30);
      case 'kesehatan':
        return const Color(0xFF5AC8FA);
      case 'investasi':
        return const Color(0xFF5856D6);
      default:
        return const Color(0xFF8E8E93);
    }
  }

  Color get categoryColor => getCategoryColor(category);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.index,
      'category': category,
      'date': date.toIso8601String(),
      'source': source,
      'note': note,
      'user_id': userId,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      title: json['title'],
      amount: json['amount'],
      type: TransactionType.values[json['type']],
      category: json['category'],
      date: DateTime.parse(json['date']),
      source: json['source'] ?? "Manual",
      note: json['note'],
      userId: json['user_id'],
    );
  }
}

const List<String> kExpenseCategories = [
  'Makanan & Minuman',
  'Transportasi',
  'Belanja',
  'Hiburan',
  'Tagihan',
  'Kesehatan',
  'Investasi',
  'Lainnya',
];

const List<String> kIncomeCategories = [
  'Gaji',
  'Bonus',
  'Investasi',
  'Hadiah',
  'Lainnya',
];
