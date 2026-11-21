import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import '../models/transaction.dart';
import '../services/notification_parser.dart';
import '../widgets/liquid_card.dart';
import '../widgets/glass_card.dart';
import '../widgets/add_transaction_sheet.dart';
import '../widgets/saku_logo.dart';
import '../widgets/bouncy_touch_wrapper.dart';

class DashboardScreen extends StatelessWidget {
  final List<TransactionModel> transactions;
  final Function(TransactionModel) onAddTransaction;
  final Function(String) onDeleteTransaction;
  final bool isDark;
  final VoidCallback onToggleTheme;
  final VoidCallback? onOpenAutoNotif;
  final VoidCallback? onNavigateToHistory;
  final ValueChanged<bool>? onPopoverStateChanged;
  final ValueListenable<int>? dismissSignal;

  const DashboardScreen({
    super.key,
    required this.transactions,
    required this.onAddTransaction,
    required this.onDeleteTransaction,
    required this.isDark,
    required this.onToggleTheme,
    this.onOpenAutoNotif,
    this.onNavigateToHistory,
    this.onPopoverStateChanged,
    this.dismissSignal,
  });

  @override
  Widget build(BuildContext context) {
    return _DashboardView(
      transactions: transactions,
      onAddTransaction: onAddTransaction,
      onDeleteTransaction: onDeleteTransaction,
      isDark: isDark,
      onToggleTheme: onToggleTheme,
      onOpenAutoNotif: onOpenAutoNotif,
      onNavigateToHistory: onNavigateToHistory,
      onPopoverStateChanged: onPopoverStateChanged,
      dismissSignal: dismissSignal,
    );
  }
}

class _DashboardView extends StatefulWidget {
  final List<TransactionModel> transactions;
  final Function(TransactionModel) onAddTransaction;
  final Function(String) onDeleteTransaction;
  final bool isDark;
  final VoidCallback onToggleTheme;
  final VoidCallback? onOpenAutoNotif;
  final VoidCallback? onNavigateToHistory;
  final ValueChanged<bool>? onPopoverStateChanged;
  final ValueListenable<int>? dismissSignal;

  const _DashboardView({
    required this.transactions,
    required this.onAddTransaction,
    required this.onDeleteTransaction,
    required this.isDark,
    required this.onToggleTheme,
    this.onOpenAutoNotif,
    this.onNavigateToHistory,
    this.onPopoverStateChanged,
    this.dismissSignal,
  });

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  bool _isInteractingBalanceCard = false;
  bool _isNotifMenuOpen = false;
  bool _wideNotif = false;
  bool _isLoading = false;
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    widget.dismissSignal?.addListener(_handleDismissSignal);
  }

  @override
  void didUpdateWidget(_DashboardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dismissSignal != widget.dismissSignal) {
      oldWidget.dismissSignal?.removeListener(_handleDismissSignal);
      widget.dismissSignal?.addListener(_handleDismissSignal);
    }
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    widget.dismissSignal?.removeListener(_handleDismissSignal);
    super.dispose();
  }

  void _handleDismissSignal() {
    if (_isNotifMenuOpen) {
      _toggleNotifMorph(false);
    }
  }

  void _toggleNotifMorph([bool? open]) {
    final target = open ?? !_isNotifMenuOpen;
    if (_isNotifMenuOpen == target) return;
    HapticFeedback.selectionClick();
    setState(() {
      _isNotifMenuOpen = target;
      if (target) {
        _wideNotif = true;
      }
    });
    widget.onPopoverStateChanged?.call(target);
  }

  double get _totalIncome {
    return widget.transactions
        .where((tx) => tx.type == TransactionType.income)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get _totalExpense {
    return widget.transactions
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get _balance => _totalIncome - _totalExpense;

  String get _fullDateFormatted {
    try {
      return DateFormat('EEEE, d MMMM', 'id_ID').format(DateTime.now());
    } catch (_) {
      return DateFormat('EEEE, d MMMM').format(DateTime.now());
    }
  }

  String get _todayFormatted {
    try {
      return DateFormat('EEE, d MMM', 'id_ID').format(DateTime.now());
    } catch (_) {
      return 'Hari Ini';
    }
  }

  String _formatRelTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inHours < 12 && now.day == dt.day) {
      return DateFormat('HH:mm').format(dt);
    } else if (diff.inDays == 1 || (diff.inHours < 48 && now.day - dt.day == 1)) {
      return 'Kemarin';
    } else {
      try {
        return DateFormat('d MMM', 'id_ID').format(dt);
      } catch (_) {
        return '${dt.day}/${dt.month}';
      }
    }
  }

  List<TransactionModel> get _recentTransactions =>
      widget.transactions.take(5).toList();

  int get _savingsRatio {
    if (_totalIncome <= 0) return 0;
    final ratio = ((_totalIncome - _totalExpense) / _totalIncome * 100).round();
    return ratio.clamp(0, 100);
  }

  MapEntry<String, double> get _topExpenseCategory {
    final expenses = widget.transactions
        .where((tx) => tx.type == TransactionType.expense);
    if (expenses.isEmpty) return const MapEntry('Belanja', 0.0);

    final map = <String, double>{};
    for (var tx in expenses) {
      map[tx.category] = (map[tx.category] ?? 0.0) + tx.amount;
    }
    var topCat = map.entries.first;
    for (var entry in map.entries) {
      if (entry.value > topCat.value) {
        topCat = entry;
      }
    }
    return topCat;
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddTransactionSheet(
        onAdd: widget.onAddTransaction,
        isDark: widget.isDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = widget.isDark
        ? const Color(0xFF8E8E93)
        : const Color(0xFF64748B);

    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double topIslandPadding = statusBarHeight > 0 ? statusBarHeight + 6 : 8.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── KONTEN SCROLLABLE DENGAN LIQUID SHIMMER SKELETON (ZERO JANK UNTUK HP KENTANG) ──
          Positioned.fill(
            child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 380),
              firstCurve: Curves.easeOut,
              secondCurve: Curves.easeIn,
              crossFadeState: _isLoading
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: _buildDashboardSkeleton(context, topIslandPadding),
              secondChild: SizedBox(
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height,
                child: CustomScrollView(
                  physics: (_isInteractingBalanceCard || _isNotifMenuOpen)
                      ? const NeverScrollableScrollPhysics()
                      : const BouncingScrollPhysics(),
                  slivers: [
                    // Top clearance agar konten mulai tepat di bawah status bar & notif bell
                    SliverToBoxAdapter(
                      child: SizedBox(height: topIslandPadding + 6),
                    ),

                    // ── APPLE LARGE TITLE "Beranda" & TANGGAL OTENTIK IOS ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Halo, Deni • $_fullDateFormatted",
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "Beranda",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

            // Liquid Balance Card
            SliverToBoxAdapter(
              child: LiquidBalanceCard(
                balance: _balance,
                totalIncome: _totalIncome,
                totalExpense: _totalExpense,
                isDark: widget.isDark,
                onScrollLockChanged: (locked) {
                  if (_isInteractingBalanceCard != locked) {
                    setState(() => _isInteractingBalanceCard = locked);
                  }
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 18)),

            // ── BENTO GRID MODULAR STATS (ALA QCLAY & DELIBIX NURA) ──
            SliverToBoxAdapter(
              child: _buildBentoGrid(textColor, secondaryTextColor),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── TITLE SECTION: AKTIVITAS TERKINI & LIHAT SEMUA ALA APPLE WALLET ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Aktivitas Terkini",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.onNavigateToHistory != null) ...[
                      const SizedBox(width: 8),
                      BouncyTouchWrapper(
                        scaleFactor: 0.94,
                        onTap: widget.onNavigateToHistory,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              "Lihat Semua",
                              style: TextStyle(
                                color: Color(0xFF007AFF),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              CupertinoIcons.chevron_right,
                              color: Color(0xFF007AFF),
                              size: 13,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            // ── GROUPED INSET GLASS CONTAINER (SATU KONTEN KACA BERSAMA ALA APPLE WALLET) ──
            SliverToBoxAdapter(
              child: _recentTransactions.isEmpty
                  ? Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
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
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                          child: Column(
                            children: [
                              Icon(
                                CupertinoIcons.tray_fill,
                                size: 40,
                                color: secondaryTextColor.withValues(alpha: 0.35),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Belum ada transaksi",
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                              for (int i = 0; i < _recentTransactions.length; i++) ...[
                                _buildTransactionRow(
                                  _recentTransactions[i],
                                  textColor: textColor,
                                  secondaryTextColor: secondaryTextColor,
                                ),
                                if (i < _recentTransactions.length - 1)
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

            const SliverToBoxAdapter(
              child: SizedBox(height: 170),
            ),
          ],
        ),
      ),
    ),
  ),

        // ── DYNAMIC NOTCH / TOP STATUS VIGNETTE (PROGRESSIVE GRADASI BLUR & WARNA ALA APPLE IOS) ──
        // Mengalir lembut dari puncak layar: menggabungkan gradasi warna menipis ke bawah DENGAN
        // gradasi blur progresif (LiquidGlassScrollEdgeStyle.soft).
        // Konten yang lewat di bawah notch/status bar otomatis ter-blur halus (sigma 16 -> 0)
        // dan memudar secara seamless tanpa batas atau sekat kaku!
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: statusBarHeight > 0 ? statusBarHeight : 44,
          child: LiquidGlassScrollEdge(
            edge: LiquidGlassEdge.top,
            style: LiquidGlassScrollEdgeStyle.soft, // Feathered progressive blur via GPU dstIn ramp
            blur: 11, // Blur lembut & airy (tidak berkabut tebal)
            blurCurve: Curves.easeInQuart, // Apple curve: menahan blur halus di area status bar
            curve: Curves.easeOutCubic, // Gradasi warna menipis sangat cepat & jernih
            color: widget.isDark
                ? Colors.black.withValues(alpha: 0.50)
                : Colors.white.withValues(alpha: 0.42),
          ),
        ),

        // ── INVISIBLE TAP-TO-DISMISS BARRIER (TANPA BLUR / DEFOKUS, KACA TETAP JERNIH) ──
        if (_isNotifMenuOpen)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _toggleNotifMorph(false),
            ),
          ),

        // ── POJOK KANAN ATAS: LONCENG NOTIFIKASI FLUID MORPH [ 🔔 -> POPOVER NOTIFIKASI ] ──
        if (widget.onOpenAutoNotif != null)
          Builder(
            builder: (context) {
              final double screenWidth = MediaQuery.sizeOf(context).width;
              final double menuWidth = screenWidth - 40.0;

              const double notifMenuHeight = 182.0;

              return Positioned(
                top: topIslandPadding,
                right: 20,
                width: _wideNotif ? menuWidth : 38.0,
                height: _wideNotif ? notifMenuHeight : 38.0,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    LiquidGlassMorph(
                      alignment: Alignment.topRight,
                      motion: LiquidGlassMorphMotion.fluid,
                      smoothness: 28,
                      style: LiquidGlassStyle(
                        shape: LiquidGlassShape.continuousRoundedRectangle(
                          cornerRadius: _isNotifMenuOpen ? 24 : 19,
                          clipQuality: LiquidGlassClipQuality.exact,
                        ),
                        // Golden Ratio Apple Frosted Liquid Glass (iOS 26 Style):
                        // Menahan tubrukan teks di belakang, tapi tetap memancarkan refraksi warna cairan
                        color: widget.isDark
                            ? (_isNotifMenuOpen
                                ? const Color(0xFF1C1C1E).withValues(alpha: 0.88)
                                : Colors.white.withValues(alpha: 0.045))
                            : (_isNotifMenuOpen
                                ? Colors.white.withValues(alpha: 0.75)
                                : Colors.white.withValues(alpha: 0.12)),
                        blur: _isNotifMenuOpen ? 25.0 : 3.5,
                        refractionIndex: 1.25,
                        refractionWidth: 14.0,
                        magnification: 1.05,
                        dispersion: 1.8,
                        specular: LiquidGlassLight.specular(
                          thickness: _isNotifMenuOpen ? 4.5 : 3.2,
                          sharpness: 0.65,
                          intensity: widget.isDark ? 1.45 : 1.55,
                        ),
                        glow: LiquidGlassLight.glow(
                          thickness: _isNotifMenuOpen ? 8.0 : 5.0,
                          intensity: _isNotifMenuOpen
                              ? (widget.isDark ? 0.08 : 0.18)
                              : (widget.isDark ? 0.06 : 0.15),
                          color: widget.isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : const Color(0xFF007AFF),
                        ),
                        shadow: LiquidGlassShadow(
                          blur: _isNotifMenuOpen ? 24 : 6,
                          opacity: widget.isDark ? 0.45 : 0.14,
                          color: widget.isDark ? Colors.black : const Color(0xFF0F172A),
                          offset: _isNotifMenuOpen
                              ? const Offset(0, 8)
                              : const Offset(0, 2),
                        ),
                      ),
                      onEnd: () {
                        if (_wideNotif != _isNotifMenuOpen) {
                          setState(() => _wideNotif = _isNotifMenuOpen);
                        }
                      },
                      child: _isNotifMenuOpen
                          ? _buildMorphedNotifMenu(
                              textColor,
                              secondaryTextColor,
                              widget.isDark,
                              menuWidth,
                            )
                          : _buildNotifGlyph(widget.isDark),
                    ),
                    if (!_isNotifMenuOpen)
                      Positioned(
                        top: 0,
                        right: 0,
                        width: 38,
                        height: 38,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _toggleNotifMorph(true),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
      ],
    ),
  );
}

  Widget _buildNotifGlyph(bool isDark) {
    return GestureDetector(
      key: const ValueKey<String>('notif_glyph'),
      behavior: HitTestBehavior.opaque,
      onTap: () => _toggleNotifMorph(true),
      child: SizedBox(
        width: 38,
        height: 38,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(
                  CupertinoIcons.bell_fill,
                  color: isDark ? Colors.white : const Color(0xFF007AFF),
                  size: 17,
                ),
                Positioned(
                  top: 0,
                  right: 1,
                  child: Container(
                    width: 6.5,
                    height: 6.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF34C759),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.black : Colors.white,
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildMorphedNotifMenu(
    Color textColor,
    Color secondaryTextColor,
    bool isDark,
    double menuWidth,
  ) {
    final latestTx =
        widget.transactions.isNotEmpty ? widget.transactions.first : null;

    return SizedBox(
      key: const ValueKey<String>('notif_menu'),
      width: menuWidth,
      height: 182,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            // Header: Judul & Tombol Tutup (X)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF007AFF).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.bell_fill,
                        color: Color(0xFF007AFF),
                        size: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Notifikasi Terbaru",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                BouncyTouchWrapper(
                  scaleFactor: 0.82,
                  onTap: () => _toggleNotifMorph(false),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: secondaryTextColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.xmark,
                      color: secondaryTextColor,
                      size: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Card Preview: Notifikasi Transaksi Terakhir / Status Auto-Detect
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.50),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : const Color(0xFF0F172A).withValues(alpha: 0.08),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: (latestTx != null &&
                              latestTx.type == TransactionType.income)
                          ? const Color(0xFF34C759).withValues(alpha: 0.15)
                          : const Color(0xFF007AFF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      (latestTx != null &&
                              latestTx.type == TransactionType.income)
                          ? CupertinoIcons.arrow_down_circle_fill
                          : CupertinoIcons.tray_arrow_down_fill,
                      color: (latestTx != null &&
                              latestTx.type == TransactionType.income)
                          ? const Color(0xFF34C759)
                          : const Color(0xFF007AFF),
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          latestTx != null
                              ? "${latestTx.type == TransactionType.income ? '+' : '-'} Rp ${NumberFormat('#,##0', 'id_ID').format(latestTx.amount)}"
                              : "Auto-Catat Notif Siap",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          latestTx != null
                              ? "${(latestTx.note != null && latestTx.note!.isNotEmpty) ? latestTx.note : latestTx.category} • Auto-catat aktif"
                              : "Membaca SMS Bank & Notifikasi E-Wallet",
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 10.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34C759).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "Aktif",
                      style: TextStyle(
                        color: Color(0xFF34C759),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Hairline Divider
            Divider(
              height: 1,
              thickness: 0.5,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.08),
            ),
            const SizedBox(height: 8),

            // Footer Button: Buka Notifikasi Lainnya & Scanner
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                _toggleNotifMorph(false);
                widget.onOpenAutoNotif?.call();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: const Color(0xFF007AFF).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Icon(
                        CupertinoIcons.list_bullet_below_rectangle,
                        color: Color(0xFF007AFF),
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Lihat Notifikasi Lainnya",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    Icon(
                      CupertinoIcons.chevron_forward,
                      color: secondaryTextColor.withValues(alpha: 0.6),
                      size: 13,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
  }

  Widget _buildBentoGrid(Color textColor, Color secondaryTextColor) {
    final topExpense = _topExpenseCategory;
    final ratio = _savingsRatio;
    final isSurplus = ratio >= 50;

    final systemGreen = widget.isDark
        ? const Color(0xFF30D158)
        : const Color(0xFF34C759);
    final systemOrange = widget.isDark
        ? const Color(0xFFFF9F0A)
        : const Color(0xFFFF9500);
    final systemBlue = widget.isDark
        ? const Color(0xFF0A84FF)
        : const Color(0xFF007AFF);

    final healthColor = isSurplus ? systemGreen : systemOrange;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── BENTO CARD KIRI (PROMINENT CASHFLOW HEALTH) ──
          Expanded(
            flex: 5,
            child: GlassCard(
              isDark: widget.isDark,
              borderRadius: 22,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Jewel Squircle Badge Icon
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              healthColor.withValues(alpha: widget.isDark ? 0.24 : 0.16),
                              healthColor.withValues(alpha: widget.isDark ? 0.12 : 0.06),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: healthColor.withValues(alpha: widget.isDark ? 0.32 : 0.22),
                            width: 0.8,
                          ),
                        ),
                        child: Icon(
                          CupertinoIcons.arrow_up_right_circle_fill,
                          color: healthColor,
                          size: 16,
                        ),
                      ),
                      // Surplus / Defisit Pill Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: healthColor.withValues(alpha: widget.isDark ? 0.16 : 0.10),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: healthColor.withValues(alpha: widget.isDark ? 0.26 : 0.18),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          isSurplus ? "Surplus" : "Defisit",
                          style: TextStyle(
                            color: healthColor,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "$ratio%",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Tabungan Terjaga",
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio / 100.0,
                      minHeight: 4.5,
                      backgroundColor: widget.isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFF0F172A).withValues(alpha: 0.06),
                      valueColor: AlwaysStoppedAnimation<Color>(healthColor),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // ── BENTO CARD KANAN (2 KARTU VERTIKAL MODULAR ALA APPLE) ──
          Expanded(
            flex: 5,
            child: Column(
              children: [
                // Kartu Pengeluaran Terbanyak
                GlassCard(
                  isDark: widget.isDark,
                  borderRadius: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              systemOrange.withValues(alpha: widget.isDark ? 0.24 : 0.16),
                              systemOrange.withValues(alpha: widget.isDark ? 0.12 : 0.06),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: systemOrange.withValues(alpha: widget.isDark ? 0.32 : 0.22),
                            width: 0.8,
                          ),
                        ),
                        child: Icon(
                          CupertinoIcons.flame_fill,
                          color: systemOrange,
                          size: 15,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pengeluaran Top",
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 1.5),
                            Text(
                              topExpense.value > 0 ? topExpense.key : "Belum ada",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Kartu Status Auto-Notif E-Wallet / Bank
                BouncyTouchWrapper(
                  scaleFactor: 0.96,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onOpenAutoNotif?.call();
                  },
                  child: GlassCard(
                    isDark: widget.isDark,
                    borderRadius: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                systemBlue.withValues(alpha: widget.isDark ? 0.24 : 0.16),
                                systemBlue.withValues(alpha: widget.isDark ? 0.12 : 0.06),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: systemBlue.withValues(alpha: widget.isDark ? 0.32 : 0.22),
                              width: 0.8,
                            ),
                          ),
                          child: Icon(
                            CupertinoIcons.device_phone_portrait,
                            color: systemBlue,
                            size: 15,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Auto-Catat Notif",
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 1.5),
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: systemGreen,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: systemGreen.withValues(alpha: 0.5),
                                          blurRadius: 4,
                                          spreadRadius: 0.5,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      "Siap Deteksi",
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(
    TransactionModel tx, {
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    final isIncome = tx.type == TransactionType.income;
    final incomeColor = widget.isDark
        ? const Color(0xFF30D158)
        : const Color(0xFF34C759);

    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        widget.onDeleteTransaction(tx.id);
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
      child: BouncyTouchWrapper(
        scaleFactor: 0.98,
        onTap: widget.onNavigateToHistory,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Category Icon (Apple Wallet Neutral Frosted Squircle + Tinted Glyph)
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

              // Title & Subtitle Ringkas (Tidak Kepotong ...)
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
                      "${tx.category} • ${_formatRelTime(tx.date)}",
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

              // Amount (Apple Wallet Tabular Figures)
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
      ),
    );
  }

  // ── SKELETON LOADER TIER 1 FINTECH (WARM-UP UNTUK HP KENTANG & PERFORMA HALUS) ──
  Widget _buildDashboardSkeleton(BuildContext context, double topIslandPadding) {
    final isDark = widget.isDark;

    return _LiquidShimmer(
      isDark: isDark,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: topIslandPadding + 6),

          // 1. Title Placeholder
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBone(width: 190, height: 14, isDark: isDark),
                const SizedBox(height: 6),
                _ShimmerBone(width: 140, height: 34, isDark: isDark),
              ],
            ),
          ),

          // 2. Hero Balance Card Placeholder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _ShimmerBone(
              width: double.infinity,
              height: 236,
              borderRadius: 28,
              isDark: isDark,
            ),
          ),

          const SizedBox(height: 18),

          // 3. Bento Grid Placeholder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: _ShimmerBone(
                    width: double.infinity,
                    height: 140,
                    borderRadius: 24,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      _ShimmerBone(
                        width: double.infinity,
                        height: 65,
                        borderRadius: 20,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      _ShimmerBone(
                        width: double.infinity,
                        height: 65,
                        borderRadius: 20,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 4. Section Title Placeholder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ShimmerBone(width: 130, height: 18, isDark: isDark),
                _ShimmerBone(width: 70, height: 14, isDark: isDark),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 5. Inset Transaction List Skeleton
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.03),
              ),
            ),
            child: Column(
              children: List.generate(3, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      _ShimmerBone(
                        width: 42,
                        height: 42,
                        borderRadius: 13,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ShimmerBone(width: 120, height: 14, isDark: isDark),
                            const SizedBox(height: 6),
                            _ShimmerBone(width: 80, height: 10, isDark: isDark),
                          ],
                        ),
                      ),
                      _ShimmerBone(width: 70, height: 16, isDark: isDark),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 160),
        ],
      ),
    ),
  );
  }
}

/// Shimmer Shader Mask Ringan (Zero CPU Overhead, Cocok untuk HP Low-End)
class _LiquidShimmer extends StatefulWidget {
  final Widget child;
  final bool isDark;

  const _LiquidShimmer({required this.child, required this.isDark});

  @override
  State<_LiquidShimmer> createState() => _LiquidShimmerState();
}

class _LiquidShimmerState extends State<_LiquidShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: const Alignment(-1.5, -0.3),
              end: const Alignment(1.5, 0.3),
              stops: [
                (_shimmerController.value - 0.3).clamp(0.0, 1.0),
                _shimmerController.value,
                (_shimmerController.value + 0.3).clamp(0.0, 1.0),
              ],
              colors: [
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: widget.isDark ? 0.22 : 0.40),
                Colors.white.withValues(alpha: 0.0),
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Placeholder Bone Komponen
class _ShimmerBone extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool isDark;

  const _ShimmerBone({
    required this.width,
    required this.height,
    this.borderRadius = 12,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.04),
          width: 0.8,
        ),
      ),
    );
  }
}



