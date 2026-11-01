import '../models/transaction.dart';

class ParsedNotificationResult {
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final String source;
  final String rawBody;

  ParsedNotificationResult({
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.source,
    required this.rawBody,
  });

  TransactionModel toTransaction() {
    return TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      type: type,
      category: category,
      date: DateTime.now(),
      source: source,
      note: "Auto-catat via Notif $source",
    );
  }
}

class NotificationParserEngine {
  /// Membaca teks notifikasi masuk dan mengekstrak transaksi keuangan secara lokal di HP
  static ParsedNotificationResult? parseNotification({
    required String appOrSender,
    required String title,
    required String body,
  }) {
    final combined = "$title $body".toLowerCase();

    // 1. Filter awal: Apakah ini notifikasi transaksi finansial?
    final bool isFinancial = _containsAny(combined, [
      'rp', 'idr', 'berhasil', 'sukses', 'transaksi', 'transfer',
      'pembayaran', 'qris', 'top up', 'diterima', 'debit', 'kredit',
      'kamu telah membayar', 'kamu menerima', 'payment of',
    ]);

    if (!isFinancial) return null;

    // 2. Ekstrak Nominal Rupiah
    final double? amount = _extractAmount(combined);
    if (amount == null || amount <= 0) return null;

    // 3. Tentukan Provider / Sumber Transaksi
    final String source = _detectSource(appOrSender, combined);

    // 4. Tentukan Jenis: Pemasukan atau Pengeluaran
    final bool isIncome = _detectIsIncome(combined);
    final TransactionType type =
        isIncome ? TransactionType.income : TransactionType.expense;

    // 5. Ekstrak Nama Merchant / Penerima / Pengirim
    final String cleanTitle = _extractMerchantOrTitle(combined, source, isIncome);

    // 6. Prediksi Kategori Otomatis berdasarkan nama merchant & kata kunci
    final String category = _predictCategory(cleanTitle, combined, isIncome);

    return ParsedNotificationResult(
      title: cleanTitle,
      amount: amount,
      type: type,
      category: category,
      source: source,
      rawBody: body,
    );
  }

  /// Ekstraksi nominal uang dengan regex fleksibel (e.g. Rp 50.000, Rp50000, IDR 120.500)
  static double? _extractAmount(String text) {
    // Pola umum nominal di Indonesia
    final patterns = [
      RegExp(r'(?:rp|idr)\.?\s*([0-9]{1,3}(?:\.[0-9]{3})*(?:,[0-9]{1,2})?)'),
      RegExp(r'sebesar\s*(?:rp|idr)?\.?\s*([0-9]{1,3}(?:\.[0-9]{3})*)'),
      RegExp(r'(?:rp|idr)\s*([0-9]+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        String numStr = match.group(1)!;
        // Bersihkan tanda titik pemisah ribuan dan koma desimal
        numStr = numStr.replaceAll('.', '').replaceAll(',', '.');
        final val = double.tryParse(numStr);
        if (val != null && val > 0) return val;
      }
    }
    return null;
  }

  /// Deteksi sumber Bank atau E-Wallet
  static String _detectSource(String appName, String text) {
    final lowerApp = appName.toLowerCase();
    if (lowerApp.contains('bca') || text.contains('bca') || text.contains('mybca')) {
      return 'BCA';
    } else if (lowerApp.contains('mandiri') || text.contains('livin')) {
      return 'Mandiri';
    } else if (lowerApp.contains('bri') || text.contains('brimo')) {
      return 'BRI';
    } else if (lowerApp.contains('bni') || text.contains('wondr')) {
      return 'BNI';
    } else if (lowerApp.contains('gopay') || text.contains('gojek') || text.contains('gopay')) {
      return 'GoPay';
    } else if (lowerApp.contains('ovo') || text.contains('ovo')) {
      return 'OVO';
    } else if (lowerApp.contains('dana') || text.contains('dana')) {
      return 'DANA';
    } else if (lowerApp.contains('shopee') || text.contains('spay') || text.contains('shopeepay')) {
      return 'ShopeePay';
    }
    return 'Bank / E-Wallet';
  }

  /// Deteksi apakah transaksi adalah Pemasukan
  static bool _detectIsIncome(String text) {
    return _containsAny(text, [
      'diterima', 'kamu menerima', 'uang masuk', 'transfer masuk',
      'kredit', 'top up berhasil', 'berhasil diisi', 'menerima dana',
      'saldo bertambah', 'terima transfer',
    ]);
  }

  /// Ekstrak nama tempat belanja / pengirim
  static String _extractMerchantOrTitle(String text, String source, bool isIncome) {
    if (isIncome) {
      if (text.contains('dari ')) {
        final match = RegExp(r'dari\s+([a-zA-Z0-9\s]+?)(?:sebesar|ke|pada|\.|$)').firstMatch(text);
        if (match != null && match.group(1)!.trim().isNotEmpty) {
          return "Transfer dari ${_capitalize(match.group(1)!.trim())}";
        }
      }
      return "Pemasukan $source";
    }

    // Pola Pengeluaran: Pembayaran ke ... / QRIS di ... / Belanja di ...
    final merchantPatterns = [
      RegExp(r'(?:ke|di|merchant|bayar)\s+([a-zA-Z0-9\s\.\-_]+?)(?:sebesar|pada|berhasil|menggunakan|\.|$)'),
      RegExp(r'qris\s+([a-zA-Z0-9\s\.\-_]+?)(?:sebesar|berhasil|\.|$)'),
    ];

    for (final pattern in merchantPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1)!.trim().isNotEmpty) {
        String name = match.group(1)!.trim();
        // Bersihkan kata sambung yang mungkin terbawa
        name = name.replaceAll(RegExp(r'^(merchant|pt|cv)\s+', caseSensitive: false), '');
        if (name.length > 2 && name.length < 35) {
          return _capitalize(name);
        }
      }
    }

    return "Pengeluaran $source";
  }

  /// Prediksi kategori pintar berbasis kata kunci lokal
  static String _predictCategory(String merchant, String fullText, bool isIncome) {
    if (isIncome) return 'Gaji';

    final text = "$merchant $fullText".toLowerCase();

    if (_containsAny(text, [
      'kopi', 'coffee', 'makan', 'resto', 'cafe', 'food', 'bakso', 'mie',
      'burger', 'pizza', 'ayam', 'teh', 'boba', 'kenangan', 'gofood', 'shopeefood', 'grabfood'
    ])) {
      return 'Makanan';
    }

    if (_containsAny(text, [
      'goride', 'gocar', 'grab', 'gojek', 'maxim', 'krl', 'mrt', 'kereta',
      'kai', 'pertamina', 'spbu', 'shell', 'bensin', 'tol', 'parkir'
    ])) {
      return 'Transportasi';
    }

    if (_containsAny(text, [
      'indomaret', 'alfamart', 'superindo', 'hypermart', 'tokopedia',
      'shopee', 'lazada', 'blibli', 'belanja', 'uniqlo', 'zara', 'h&m'
    ])) {
      return 'Belanja';
    }

    if (_containsAny(text, [
      'pln', 'listrik', 'pdam', 'air', 'indihome', 'biznet', 'wifi',
      'pulsa', 'telkomsel', 'xl', 'indosat', 'bpjs', 'tagihan', 'pbb'
    ])) {
      return 'Tagihan';
    }

    if (_containsAny(text, [
      'cinema', 'xxi', 'cgv', 'bioskop', 'netflix', 'spotify', 'youtube',
      'steam', 'playstation', 'game', 'tiket', 'konser'
    ])) {
      return 'Hiburan';
    }

    if (_containsAny(text, [
      'apotek', 'kimia farma', 'k24', 'dokter', 'rumah sakit', 'klinik', 'obat'
    ])) {
      return 'Kesehatan';
    }

    if (_containsAny(text, [
      'bibit', 'bareksa', 'ajaib', 'stockbit', 'pluang', 'reksadana', 'saham'
    ])) {
      return 'Investasi';
    }

    return 'Lainnya';
  }

  static bool _containsAny(String source, List<String> keywords) {
    for (final k in keywords) {
      if (source.contains(k)) return true;
    }
    return false;
  }

  static String _capitalize(String input) {
    if (input.isEmpty) return input;
    return input.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
