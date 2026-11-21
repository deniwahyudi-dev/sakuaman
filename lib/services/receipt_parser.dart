import 'dart:math' as math;
import '../models/transaction.dart';

class ParsedReceiptResult {
  final String merchant;
  final double amount;
  final String category;
  final String source;
  final DateTime date;
  final List<String> detectedItems;
  final String rawText;
  final double confidence;

  ParsedReceiptResult({
    required this.merchant,
    required this.amount,
    required this.category,
    required this.source,
    required this.date,
    required this.detectedItems,
    required this.rawText,
    this.confidence = 0.95,
  });

  TransactionModel toTransaction() {
    return TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: merchant,
      amount: amount,
      type: TransactionType.expense,
      category: category,
      date: date,
      source: source,
      note: "Auto-scan foto nota: $merchant",
    );
  }
}

class ReceiptParserEngine {
  /// Ekstraksi cerdas teks nota fisik / digital (Alfamart, Indomaret, Shopee, SPBU, Restoran)
  static ParsedReceiptResult? parseReceiptText(String rawText) {
    if (rawText.trim().isEmpty) return null;

    final lower = rawText.toLowerCase();

    // 1. Deteksi Merchant & Kategori
    String detectedMerchant = "Belanja Toko";
    String detectedCategory = "Belanja";
    String detectedSource = "Manual";

    if (lower.contains("alfamart") || lower.contains("alfa midi") || lower.contains("sumber alfaria")) {
      detectedMerchant = "Alfamart";
      detectedCategory = "Belanja";
      detectedSource = "Tunai / QRIS";
    } else if (lower.contains("indomaret") || lower.contains("indomarco")) {
      detectedMerchant = "Indomaret";
      detectedCategory = "Belanja";
      detectedSource = "Tunai / QRIS";
    } else if (lower.contains("shopee") || lower.contains("shopeepay") || lower.contains("spx express")) {
      detectedMerchant = "Shopee Online";
      detectedCategory = "Belanja";
      detectedSource = "ShopeePay";
    } else if (lower.contains("tokopedia") || lower.contains("tokped") || lower.contains("goto")) {
      detectedMerchant = "Tokopedia";
      detectedCategory = "Belanja";
      detectedSource = "GoPay";
    } else if (lower.contains("pertamina") || lower.contains("spbu") || lower.contains("shell") || lower.contains("pertalite") || lower.contains("pertamax")) {
      detectedMerchant = "SPBU Pertamina";
      detectedCategory = "Transportasi";
      detectedSource = "MyPertamina / Mandiri";
    } else if (lower.contains("superindo") || lower.contains("hypermart") || lower.contains("transmart")) {
      detectedMerchant = "Superindo Supermarket";
      detectedCategory = "Belanja";
      detectedSource = "BCA";
    } else if (lower.contains("kopi kenangan") || lower.contains("starbucks") || lower.contains("janji jiwa") || lower.contains("mixue") || lower.contains("fore")) {
      detectedMerchant = "Kopi & Minuman";
      detectedCategory = "Makanan";
      detectedSource = "QRIS";
    } else if (lower.contains("kfc") || lower.contains("mcdonald") || lower.contains("mcd") || lower.contains("hokben") || lower.contains("restoran") || lower.contains("warung")) {
      detectedMerchant = "Restoran / Makan";
      detectedCategory = "Makanan";
      detectedSource = "QRIS";
    } else if (lower.contains("pln") || lower.contains("token listrik") || lower.contains("pdam") || lower.contains("indihome") || lower.contains("wifi")) {
      detectedMerchant = "Tagihan Utilitas";
      detectedCategory = "Tagihan";
      detectedSource = "BCA";
    }

    // 2. Deteksi Total Nominal Belanja
    double detectedAmount = 0.0;

    // Prioritas 1: Baris yang mengandung kata kunci TOTAL, TOTAL BELANJA, TOTAL PEMBAYARAN, HARGA TOTAL, SUBTOTAL
    final totalPatterns = [
      RegExp(r'(?:total\s*belanja|total\s*pembayaran|total\s*harga|total\s*bayar|grand\s*total|total|subtotal|jumlah|tagihan)\s*[:=]?\s*(?:rp\.?|idr)?\s*([\d\.,]+)', caseSensitive: false),
      RegExp(r'(?:tunai|cash|bayar)\s*[:=]?\s*(?:rp\.?|idr)?\s*([\d\.,]+)', caseSensitive: false),
      RegExp(r'(?:rp\.?|idr)\s*([\d\.,]{4,})', caseSensitive: false),
    ];

    for (final pattern in totalPatterns) {
      final matches = pattern.allMatches(rawText);
      for (final match in matches) {
        if (match.groupCount >= 1) {
          final rawVal = match.group(1) ?? "";
          final cleanVal = _cleanNumber(rawVal);
          if (cleanVal > 500 && cleanVal > detectedAmount) {
            detectedAmount = cleanVal;
          }
        }
      }
      if (detectedAmount > 0) break;
    }

    // Fallback: Jika tidak ketemu kata kunci total, cari angka terbesar yang masuk akal sebagai total belanja
    if (detectedAmount <= 0) {
      final numbers = RegExp(r'(?:rp\.?|idr)?\s*([0-9]{1,3}(?:\.[0-9]{3})+(?:,[0-9]{2})?)', caseSensitive: false)
          .allMatches(rawText)
          .map((m) => _cleanNumber(m.group(1) ?? ""))
          .where((num) => num >= 1000 && num <= 100000000)
          .toList();
      if (numbers.isNotEmpty) {
        detectedAmount = numbers.reduce(math.max);
      }
    }

    // Default jika masih nol
    if (detectedAmount <= 0) {
      detectedAmount = 25000;
    }

    // 3. Deteksi Tanggal (Opsional)
    DateTime detectedDate = DateTime.now();
    final dateMatch = RegExp(r'(\d{1,2})[\/\-\.](\d{1,2})[\/\-\.](\d{2,4})').firstMatch(rawText);
    if (dateMatch != null) {
      try {
        final day = int.parse(dateMatch.group(1)!);
        final month = int.parse(dateMatch.group(2)!);
        var year = int.parse(dateMatch.group(3)!);
        if (year < 100) year += 2000;
        if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
          detectedDate = DateTime(year, month, day);
        }
      } catch (_) {}
    }

    // 4. Deteksi Daftar Barang Ringkas (Baris dengan nama item)
    final items = <String>[];
    final lines = rawText.split('\n');
    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.length > 3 &&
          !trimmed.toLowerCase().contains("total") &&
          !trimmed.toLowerCase().contains("tunai") &&
          !trimmed.toLowerCase().contains("kembali") &&
          !trimmed.toLowerCase().contains("terima kasih") &&
          !trimmed.toLowerCase().contains("tgl") &&
          items.length < 5) {
        items.add(trimmed);
      }
    }

    return ParsedReceiptResult(
      merchant: detectedMerchant,
      amount: detectedAmount,
      category: detectedCategory,
      source: detectedSource,
      date: detectedDate,
      detectedItems: items,
      rawText: rawText,
    );
  }

  static double _cleanNumber(String text) {
    var s = text.trim();
    // Hapus tanda titik ribuan jika diikuti titik koma
    if (s.contains('.') && s.contains(',')) {
      s = s.replaceAll('.', '').replaceAll(',', '.');
    } else if (s.contains('.')) {
      // Periksa apakah titik adalah ribuan (misal: 48.500)
      final parts = s.split('.');
      if (parts.length > 1 && parts.last.length == 3) {
        s = s.replaceAll('.', '');
      }
    } else if (s.contains(',')) {
      s = s.replaceAll(',', '');
    }
    s = s.replaceAll(RegExp(r'[^0-9\.]'), '');
    return double.tryParse(s) ?? 0.0;
  }
}

