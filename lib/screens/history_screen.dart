import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import '../models/transaction.dart';
import '../widgets/bouncy_touch_wrapper.dart';

/// Screen Riwayat Transaksi Minimalist & Clean
/// Desain Apple iOS 18 / Apple Wallet Inset Timeline:
/// - Apple Large Title murni tanpa floating brand pill yang berisik.
/// - Inset Frosted Apple Search Bar tanpa drop shadow kasar.
/// - Apple Sliding Segmented Control (satu wadah kaca terpadu).
/// - Timeline Grouping per Tanggal (HARI INI, KEMARIN, 15 NOVEMBER).
/// - Zero Text Clipping pada subtitle (Kategori • Sumber • Jam).
class HistoryScreen extends StatefulWidget {
  final List<TransactionModel> transactions;
  final Function(String) onDeleteTransaction;
  final bool isDark;

  const HistoryScreen({
    super.key,
    required this.transactions,
    required this.onDeleteTransaction,
    required this.isDark,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = '';
  String _selectedPeriod = 'Semua';

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  List<TransactionModel> get _filteredList {
    final now = DateTime.now();
    return widget.transactions.where((tx) {
      // Filter Periode
      if (_selectedPeriod == '7 Hari Terakhir') {
        if (now.difference(tx.date).inDays > 7) return false;
      } else if (_selectedPeriod == 'Bulan Ini') {
        if (tx.date.month != now.month || tx.date.year != now.year) return false;
      }

      // Filter Pencarian
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = tx.title.toLowerCase().contains(q);
        final matchCategory = tx.category.toLowerCase().contains(q);
        final matchSource = tx.source.toLowerCase().contains(q);
        return matchTitle || matchCategory || matchSource;
      }

      return true;
    }).toList();
  }

  double get _totalFilteredExpense {
    return _filteredList
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  /// Mengelompokkan transaksi berdasarkan tanggal (Apple Wallet Style)
  Map<String, List<TransactionModel>> get _groupedTransactions {
    final Map<String, List<TransactionModel>> groups = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final tx in _filteredList) {
      final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
      String header;
      if (txDate == today) {
        header = "HARI INI";
      } else if (txDate == yesterday) {
        header = "KEMARIN";
      } else if (tx.date.year == now.year) {
        header = DateFormat('d MMMM', 'id_ID').format(tx.date).toUpperCase();
      } else {
        header = DateFormat('d MMMM yyyy', 'id_ID').format(tx.date).toUpperCase();
      }

      groups.putIfAbsent(header, () => []).add(tx);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = widget.isDark
        ? const Color(0xFF8E8E93)
        : const Color(0xFF64748B);

    final totalExpense = _totalFilteredExpense;
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double topIslandPadding = statusBarHeight > 0 ? statusBarHeight + 6 : 8.0;

    final grouped = _groupedTransactions;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── KONTEN SCROLLABLE ──
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Spacer top clearance agar judul mulai pas di bawah status bar
              SliverToBoxAdapter(
                child: SizedBox(height: topIslandPadding + 10),
              ),

              // ── 1. APPLE LARGE TITLE HEADER ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Riwayat Transaksi",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            "${_filteredList.length} transaksi tercatat",
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.1,
                            ),
                          ),
                          if (totalExpense > 0) ...[
                            Text(
                              " • ",
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 13.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: widget.isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : const Color(0xFF007AFF).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Keluar ${_formatCurrency(totalExpense)}",
                                style: TextStyle(
                                  color: widget.isDark
                                      ? Colors.white
                                      : const Color(0xFF007AFF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── 2. NATIVE APPLE INSET SEARCH BAR (BEBAS SHADOW KASAR) ──
              SliverToBoxAdapter(
                child: _buildAppleSearchBar(textColor, secondaryTextColor),
              ),

              // ── 3. APPLE SLIDING SEGMENTED CONTROL ──
              SliverToBoxAdapter(
                child: _buildSegmentedFilter(textColor, secondaryTextColor),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 6)),

              // ── 4. DAFTAR TRANSAKSI DENGAN TIMELINE GROUPING ──
              if (_filteredList.isEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? const Color(0xFF1C1C1E).withValues(alpha: 0.85)
                          : Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: widget.isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.white,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.isDark
                              ? Colors.black.withValues(alpha: 0.45)
                              : const Color(0xFF0F172A).withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          CupertinoIcons.search,
                          size: 38,
                          color: secondaryTextColor.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Tidak ada transaksi yang cocok",
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                for (final entry in grouped.entries) ...[
                  // Date Section Header (Apple Uppercase Gray + Subtotal Harian ala Apple Card)
                  SliverToBoxAdapter(
                    child: Builder(
                      builder: (context) {
                        double dailyNet = 0.0;
                        for (final tx in entry.value) {
                          if (tx.type == TransactionType.income) {
                            dailyNet += tx.amount;
                          } else {
                            dailyNet -= tx.amount;
                          }
                        }

                        final systemGreen = widget.isDark
                            ? const Color(0xFF30D158)
                            : const Color(0xFF34C759);

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 22, 20, 7),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                dailyNet > 0
                                    ? "+${_formatCurrency(dailyNet)}"
                                    : (dailyNet < 0
                                        ? "-${_formatCurrency(dailyNet.abs())}"
                                        : "Rp 0"),
                                style: TextStyle(
                                  color: dailyNet > 0
                                      ? systemGreen
                                      : secondaryTextColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // Inset Grouped Glass Platter untuk grup tanggal tersebut
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? const Color(0xFF1C1C1E).withValues(alpha: 0.85)
                            : Colors.white.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: widget.isDark
                              ? Colors.white.withValues(alpha: 0.12)
                              : Colors.white,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.isDark
                                ? Colors.black.withValues(alpha: 0.45)
                                : const Color(0xFF0F172A).withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                          if (!widget.isDark)
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.8),
                              blurRadius: 1,
                              offset: const Offset(0, 0.5),
                            ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                          child: Column(
                            children: [
                              for (int i = 0; i < entry.value.length; i++) ...[
                                Dismissible(
                                  key: Key('hist_${entry.value[i].id}'),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (_) {
                                    HapticFeedback.mediumImpact();
                                    widget.onDeleteTransaction(entry.value[i].id);
                                  },
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 22),
                                    color: const Color(0xFFFF3B30),
                                    child: const Icon(
                                      CupertinoIcons.trash_fill,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  child: _buildHistoryRow(
                                    entry.value[i],
                                    textColor: textColor,
                                    secondaryTextColor: secondaryTextColor,
                                  ),
                                ),
                                if (i < entry.value.length - 1)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 73, right: 16),
                                    child: Divider(
                                      height: 1,
                                      thickness: 0.5,
                                      color: widget.isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : const Color(0xFF3C3C43).withValues(alpha: 0.12),
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

              // Spacer bagian bawah agar tidak tertutup dock / tab bar
              const SliverToBoxAdapter(child: SizedBox(height: 130)),
            ],
          ),

          // ── STATUS BAR FEATHERED BLUR (HANYA AREA STATUS BAR SISTEM) ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: statusBarHeight > 0 ? statusBarHeight : 44,
            child: LiquidGlassScrollEdge(
              edge: LiquidGlassEdge.top,
              style: LiquidGlassScrollEdgeStyle.soft,
              blur: 11,
              blurCurve: Curves.easeInQuart,
              curve: Curves.easeOutCubic,
              color: widget.isDark
                  ? Colors.black.withValues(alpha: 0.50)
                  : Colors.white.withValues(alpha: 0.42),
            ),
          ),
        ],
      ),
    );
  }

  /// Apple Inset Search Bar (Tanpa drop shadow kasar)
  Widget _buildAppleSearchBar(Color textColor, Color secondaryTextColor) {
    final isDark = widget.isDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1C1C1E).withValues(alpha: 0.85)
              : const Color(0xFF767680).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.transparent,
            width: 0.8,
          ),
        ),
        child: CupertinoSearchTextField(
          placeholder: "Cari transaksi...",
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          placeholderStyle: TextStyle(
            color: secondaryTextColor.withValues(alpha: 0.65),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          itemColor: secondaryTextColor,
          itemSize: 18,
          prefixInsets: const EdgeInsetsDirectional.fromSTEB(10, 0, 6, 0),
          suffixInsets: const EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
          backgroundColor: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          onChanged: (val) {
            setState(() {
              _searchQuery = val.trim();
            });
          },
        ),
      ),
    );
  }

  /// Apple Sliding Segmented Control (Wadah Kaca Terpadu)
  Widget _buildSegmentedFilter(Color textColor, Color secondaryTextColor) {
    const periods = ['Semua', 'Bulan Ini', '7 Hari Terakhir'];
    final isDark = widget.isDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        height: 38,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1C1C1E).withValues(alpha: 0.85)
              : const Color(0xFF767680).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.03),
            width: 0.8,
          ),
        ),
        child: Row(
          children: periods.map((period) {
            final isSelected = _selectedPeriod == period;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedPeriod = period;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                            ? const Color(0xFF2C2C2E)
                            : Colors.white)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.35 : 0.08,
                              ),
                              blurRadius: 4,
                              offset: const Offset(0, 1.5),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    period,
                    style: TextStyle(
                      color: isSelected ? textColor : secondaryTextColor,
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Baris Transaksi Rapi & Mewah (Apple VisionOS Jewel Squircle & Zero Text Clipping)
  Widget _buildHistoryRow(
    TransactionModel tx, {
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    final isIncome = tx.type == TransactionType.income;
    final incomeColor = widget.isDark
        ? const Color(0xFF30D158)
        : const Color(0xFF34C759);
    final timeStr = DateFormat('HH:mm').format(tx.date);

    return BouncyTouchWrapper(
      scaleFactor: 0.98,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Ikon Bersih dalam Squircle Frosted Glass Netral (Apple Wallet Style)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: widget.isDark
                    ? Colors.white.withValues(alpha: 0.065)
                    : const Color(0xFF0F172A).withValues(alpha: 0.045),
                borderRadius: BorderRadius.circular(13.5),
                border: Border.all(
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.04),
                  width: 0.8,
                ),
              ),
              child: Icon(
                tx.categoryIcon,
                color: tx.categoryColor,
                size: 21,
              ),
            ),
            const SizedBox(width: 13),

            // Judul dan Metadata Ringkas 2-Baris (Kategori • Sumber • Jam - BEBAS POTONG TEKS)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tx.title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2.5),
                  Text(
                    "${tx.category} • ${tx.source} • $timeStr",
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Nilai Transaksi Bersih (Tabular Figures)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 130),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  tx.formattedAmount,
                  style: TextStyle(
                    color: isIncome ? incomeColor : textColor,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
