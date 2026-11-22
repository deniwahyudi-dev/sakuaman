import '../models/transaction.dart';
import '../models/budget.dart';

class FinancialHealthScore {
  final int score; // 0 - 100
  final String grade; // "Sangat Sehat", "Sehat", "Perlu Waspada", "Bahaya"
  final String summary;
  final double savingsRate;
  final double needsPercentage;
  final double wantsPercentage;
  final List<String> insights;
  final bool hasEnoughData;

  FinancialHealthScore({
    required this.score,
    required this.grade,
    required this.summary,
    required this.savingsRate,
    required this.needsPercentage,
    required this.wantsPercentage,
    required this.insights,
    this.hasEnoughData = true,
  });
}

class LocalAIAdvisor {
  /// Menganalisa kesehatan finansial secara lokal tanpa mengirim data keluar HP
  static FinancialHealthScore analyze(
    List<TransactionModel> transactions, [
    DateTime? referenceDate,
    List<Budget>? budgets,
  ]) {
    final now = referenceDate ?? DateTime.now();
    final currentMonthTxs = transactions.where((tx) =>
        tx.date.year == now.year && tx.date.month == now.month).toList();

    if (currentMonthTxs.isEmpty) {
      return FinancialHealthScore(
        score: 100,
        grade: "Belum Ada Data",
        summary: "Mulai catat transaksi pertamamu untuk melihat diagnosa AI lokal.",
        savingsRate: 0,
        needsPercentage: 0,
        wantsPercentage: 0,
        insights: ["Data mutasi masih kosong."],
        hasEnoughData: false,
      );
    }

    double totalIncome = 0;
    double totalExpense = 0;

    double needsExpense = 0; // Kebutuhan
    double wantsExpense = 0; // Keinginan
    double investmentExpense = 0; // Investasi

    Map<String, double> categoryExpense = {};

    for (final tx in currentMonthTxs) {
      if (tx.type == TransactionType.income) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
        categoryExpense[tx.category] =
            (categoryExpense[tx.category] ?? 0) + tx.amount;

        switch (tx.category.toLowerCase()) {
          case 'makanan':
          case 'makanan & minuman':
          case 'transportasi':
          case 'tagihan':
          case 'kesehatan':
            needsExpense += tx.amount;
            break;
          case 'investasi':
            investmentExpense += tx.amount;
            break;
          default:
            wantsExpense += tx.amount;
            break;
        }
      }
    }

    final bool enoughData = currentMonthTxs.length >= 3 && totalIncome > 0;

    // Jika belum ada pemasukan yang dicatat, gunakan total pengeluaran sebagai acuan dasar
    final double baseRevenue = totalIncome > 0 ? totalIncome : totalExpense * 1.2;
    final double netSavings = (totalIncome - totalExpense) + investmentExpense;
    final double savingsRate = baseRevenue > 0 ? (netSavings / baseRevenue) * 100 : 0;

    final double needsPercentage =
        baseRevenue > 0 ? (needsExpense / baseRevenue) * 100 : 0;
    final double wantsPercentage =
        baseRevenue > 0 ? (wantsExpense / baseRevenue) * 100 : 0;

    // Hitung Skor (0 - 100)
    int score = 70; // baseline

    // 1. Rasio Tabungan (+/- score)
    if (savingsRate >= 20) {
      score += 15;
    } else if (savingsRate >= 10) {
      score += 5;
    } else if (savingsRate < 0) {
      score -= 25; // Defisit
    }

    // 2. Kebutuhan Ideal (50%)
    if (needsPercentage <= 50) {
      score += 10;
    } else if (needsPercentage > 65) {
      score -= 10;
    }

    // 3. Keinginan Ideal (30%)
    if (wantsPercentage <= 30) {
      score += 5;
    } else if (wantsPercentage > 40) {
      score -= 15;
    }

    // Clamp score 10 - 100
    score = score.clamp(10, 100);

    // Kategori Grade
    String grade = "Sehat";
    if (score >= 85) {
      grade = "Sangat Sehat";
    } else if (score >= 70) {
      grade = "Sehat & Terkendali";
    } else if (score >= 50) {
      grade = "Perlu Waspada";
    } else {
      grade = "Kritis / Boros";
    }

    // Generate Smart Insights
    final List<String> insights = [];

    if (totalIncome > 0 && totalExpense > totalIncome) {
      insights.add("⚠️ Pengeluaranmu bulan ini sudah melebihi total pemasukan (Defisit). Rem pengeluaran sekunder!");
    } else if (savingsRate >= 25) {
      insights.add("🌟 Mantap! Kamu berhasil menyisihkan >25% pemasukanmu. Arus kas sangat stabil.");
    }

    // Budget Insights
    if (budgets != null && budgets.isNotEmpty) {
      for (final budget in budgets) {
        final cat = budget.category;
        final limit = budget.limit;
        if (limit > 0 && categoryExpense.containsKey(cat)) {
          final spent = categoryExpense[cat]!;
          final ratio = spent / limit;
          if (ratio >= 0.85) {
            insights.add("💡 Anggaran '$cat' sudah terpakai ${(ratio * 100).toStringAsFixed(0)}%. Hati-hati!");
          }
        }
      }
    }

    // Cek pengeluaran terbesar
    if (categoryExpense.isNotEmpty) {
      final sorted = categoryExpense.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topCategory = sorted.first;
      final topPercentage = totalExpense > 0 ? (topCategory.key == '' ? 0 : (topCategory.value / totalExpense) * 100) : 0;

      if (topPercentage > 35) {
        insights.add("💡 Kategori '${topCategory.key}' mendominasi ${topPercentage.toStringAsFixed(0)}% dari seluruh pengeluaranmu.");
      }
    }

    if (wantsPercentage > 35) {
      insights.add("☕ Porsi 'Keinginan' (Lifestyle/Belanja/Kopi) menyentuh ${wantsPercentage.toStringAsFixed(0)}%. Coba pangkas sedikit ke pos tabungan.");
    } else {
      insights.add("🎯 Alokasi gaya hidupmu terkendali dengan baik di bawah ambang 30%.");
    }

    insights.add("🔒 Analisa ini diproses 100% lokal oleh SakuAman Engine tanpa koneksi internet.");

    final String summary = score >= 70
        ? "Kondisi keuanganmu dalam kondisi prima dengan rasio tabungan yang sehat."
        : "Ada beberapa pos pengeluaran impulsif yang perlu dirampingkan agar arus kas tidak defisit.";

    return FinancialHealthScore(
      score: score,
      grade: grade,
      summary: summary,
      savingsRate: savingsRate,
      needsPercentage: needsPercentage,
      wantsPercentage: wantsPercentage,
      insights: insights,
      hasEnoughData: enoughData,
    );
  }
}
