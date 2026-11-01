import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import '../models/transaction.dart';
import '../widgets/bouncy_touch_wrapper.dart';

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
  bool _isInteractingTopBar = false;

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
      // Period filter
      if (_selectedPeriod == '7 Hari Terakhir') {
        if (now.difference(tx.date).inDays > 7) return false;
      } else if (_selectedPeriod == 'Bulan Ini') {
        if (tx.date.month != now.month || tx.date.year != now.year) return false;
      }

      // Search query
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

  Map<String, double> get _categorySpending {
    final map = <String, double>{};
    for (var tx in _filteredList) {
      if (tx.type == TransactionType.expense) {
        map[tx.category] = (map[tx.category] ?? 0.0) + tx.amount;
      }
    }
    return map;
  }

  double get _totalFilteredExpense {
    return _filteredList
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = widget.isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    final categoryMap = _categorySpending;
    final totalExpense = _totalFilteredExpense;

    // Formula Kaca Kristal Cair Murni (Ultra-Clear Liquid Glass, Low Opacity & Crisp Blur)
    final pillGlassStyle = LiquidGlassStyle(
      shape: const LiquidGlassShape.continuousRoundedRectangle(
        cornerRadius: 18,
      ),
      color: widget.isDark
          ? Colors.white.withValues(alpha: 0.045)
          : Colors.white.withValues(alpha: 0.12),
      blur: 3.5,
      refractionIndex: 1.24,
      refractionWidth: 12.0,
      magnification: 1.05,
      dispersion: 1.8,
      specular: LiquidGlassLight.specular(
        thickness: 3.2,
        intensity: widget.isDark ? 1.20 : 1.30,
      ),
      glow: LiquidGlassLight.glow(
        thickness: 5.0,
        intensity: widget.isDark ? 0.20 : 0.15,
        color: const Color(0xFF007AFF),
      ),
      shadow: LiquidGlassShadow(
        blur: 6,
        opacity: widget.isDark ? 0.08 : 0.05,
        color: Colors.black,
        offset: const Offset(0, 2),
      ),
    );

    // Dynamic jelly-elastic touch physics (refraction boost + spring bounce)
    const jellyTouch = LiquidGlassTouch(
      flex: LiquidGlassFlex(
        stretch: 11,
        squeeze: 0.40,
        lean: 0.28,
        grip: 0.60,
        compressInward: true,
        holdScale: 0.02,
        tapScale: 0.018,
        maxPull: 26,
        advanced: LiquidGlassFlexAdvanced(
          childFollow: 0.45,
          refractionBoost: 0.12,
          stiffness: 320,
          damping: 22,
          releaseDamping: 18,
        ),
      ),
    );

    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double topIslandPadding = statusBarHeight > 0 ? statusBarHeight + 6 : 8.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── KONTEN SCROLLABLE DI BAWAH KACA (FLOWS UNDERNEATH PINNED TOP BAR) ──
          CustomScrollView(
            physics: _isInteractingTopBar
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            slivers: [
              // Spacer agar konten awal mulai di bawah floating islands
              SliverToBoxAdapter(
                child: SizedBox(height: topIslandPadding + 44),
              ),

              // ── LARGE TITLE "Riwayat Transaksi" & Subtitle Ringkas Lega ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Riwayat Transaksi",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            "Arsip & Mutasi Kas",
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (totalExpense > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: widget.isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "Total: ${_formatCurrency(totalExpense)}",
                                style: TextStyle(
                                  color: secondaryTextColor,
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

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: CupertinoSearchTextField(
                    placeholder: "Cari merchant, kategori, atau bank...",
                    style: TextStyle(color: textColor, fontSize: 14),
                    placeholderStyle: TextStyle(
                      color: secondaryTextColor.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                    backgroundColor: widget.isDark
                        ? const Color(0xFF1C1C1E)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim();
                      });
                    },
                  ),
                ),
              ),

              // Period Selector Pills (Clean & Minimalist)
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: ['Semua', 'Bulan Ini', '7 Hari Terakhir'].map((period) {
                      final isSelected = _selectedPeriod == period;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: BouncyTouchWrapper(
                          scaleFactor: 0.94,
                          onTap: () {
                            setState(() {
                              _selectedPeriod = period;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (widget.isDark ? Colors.white : Colors.black)
                                  : (widget.isDark
                                      ? Colors.white.withValues(alpha: 0.07)
                                      : const Color(0xFFE5E5EA)),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : (widget.isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : const Color(0xFFD1D1D6)),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              period,
                              style: TextStyle(
                                color: isSelected
                                    ? (widget.isDark ? Colors.black : Colors.white)
                                    : secondaryTextColor,
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ── GROUPED INSET GLASS CONTAINER (SEMUA TRANSAKSI DALAM SATU LEMPENG KACA BERSIH) ──
              SliverToBoxAdapter(
                child: _filteredList.isEmpty
                    ? Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? const Color(0xFF101626).withValues(alpha: 0.70)
                              : Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: widget.isDark
                                ? Colors.white.withValues(alpha: 0.09)
                                : const Color(0xFF0F172A).withValues(alpha: 0.08),
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              CupertinoIcons.search,
                              size: 38,
                              color: secondaryTextColor.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Tidak ada transaksi yang cocok",
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? const Color(0xFF101626).withValues(alpha: 0.75)
                              : Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: widget.isDark
                                ? Colors.white.withValues(alpha: 0.10)
                                : const Color(0xFF0F172A).withValues(alpha: 0.08),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.isDark
                                  ? Colors.black.withValues(alpha: 0.35)
                                  : const Color(0xFF0F172A).withValues(alpha: 0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                            child: Column(
                              children: [
                                for (int i = 0; i < _filteredList.length; i++) ...[
                                  Dismissible(
                                    key: Key('hist_${_filteredList[i].id}'),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (_) => widget.onDeleteTransaction(_filteredList[i].id),
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 24),
                                      color: const Color(0xFFFF3B30),
                                      child: const Icon(
                                        CupertinoIcons.trash_fill,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    child: _buildHistoryRow(
                                      _filteredList[i],
                                      textColor: textColor,
                                      secondaryTextColor: secondaryTextColor,
                                    ),
                                  ),
                                  if (i < _filteredList.length - 1)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 68, right: 16),
                                      child: Divider(
                                        height: 1,
                                        thickness: 0.6,
                                        color: widget.isDark
                                            ? Colors.white.withValues(alpha: 0.08)
                                            : const Color(0xFF0F172A).withValues(alpha: 0.08),
                                      ),
                                    ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 170)),
            ],
          ),

        // ── DYNAMIC NOTCH / TOP STATUS VIGNETTE (PROGRESSIVE GRADASI BLUR & WARNA ALA APPLE IOS) ──
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: (statusBarHeight > 0 ? statusBarHeight : 44) + 84,
          child: LiquidGlassScrollEdge(
            edge: LiquidGlassEdge.top,
            style: LiquidGlassScrollEdgeStyle.soft,
            blur: 11,
            blurCurve: Curves.easeInQuart,
            curve: Curves.easeOutCubic,
            color: widget.isDark
                ? const Color(0xFF090C15).withValues(alpha: 0.38)
                : Colors.white.withValues(alpha: 0.42),
          ),
        ),

        // ── PINNED FLOATING LIQUID ISLANDS (ALA QURANIFY IOS 26) ──
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) {
              if (!_isInteractingTopBar) {
                setState(() => _isInteractingTopBar = true);
              }
            },
            onPointerUp: (_) {
              if (_isInteractingTopBar) {
                setState(() => _isInteractingTopBar = false);
              }
            },
            onPointerCancel: (_) {
              if (_isInteractingTopBar) {
                setState(() => _isInteractingTopBar = false);
              }
            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, topIslandPadding, 20, 6),
              child: SizedBox(
                height: 38,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Pojok Kiri Atas: Floating Liquid Pill [ 📄 Riwayat Kas ]
                    Positioned(
                      left: 0,
                      top: 0,
                      width: 142,
                      height: 38,
                      child: LiquidGlassLens(
                        style: pillGlassStyle,
                        touch: jellyTouch,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF007AFF).withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.doc_text_fill,
                                      color: Color(0xFF007AFF),
                                      size: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    "Riwayat Kas",
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Pojok Kanan Atas: Floating Liquid Badge [ ${_filteredList.length} Transaksi ]
                    Positioned(
                      right: 0,
                      top: 0,
                      width: 118,
                      height: 38,
                      child: LiquidGlassLens(
                        style: pillGlassStyle,
                        touch: jellyTouch,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF007AFF),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${_filteredList.length} Transaksi",
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildHistoryRow(
    TransactionModel tx, {
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    final isIncome = tx.type == TransactionType.income;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tx.categoryColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: tx.categoryColor.withValues(alpha: 0.30),
                width: 0.8,
              ),
            ),
            child: Icon(
              tx.categoryIcon,
              color: tx.categoryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tx.title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : const Color(0xFFE5E5EA),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tx.source,
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "${tx.category} • ${tx.formattedDate}",
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                tx.formattedAmount,
                style: TextStyle(
                  color: isIncome ? const Color(0xFF00E676) : textColor,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Makanan':
        return const Color(0xFFFF9500);
      case 'Transportasi':
        return const Color(0xFF007AFF);
      case 'Belanja':
        return const Color(0xFFAF52DE);
      case 'Tagihan':
        return const Color(0xFFFF2D55);
      case 'Hiburan':
        return const Color(0xFF5856D6);
      case 'Kesehatan':
        return const Color(0xFF34C759);
      default:
        return const Color(0xFF5AC8FA);
    }
  }
}
