import 'dart:ui';
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

  const DashboardScreen({
    super.key,
    required this.transactions,
    required this.onAddTransaction,
    required this.onDeleteTransaction,
    required this.isDark,
    required this.onToggleTheme,
    this.onOpenAutoNotif,
    this.onNavigateToHistory,
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

  const _DashboardView({
    required this.transactions,
    required this.onAddTransaction,
    required this.onDeleteTransaction,
    required this.isDark,
    required this.onToggleTheme,
    this.onOpenAutoNotif,
    this.onNavigateToHistory,
  });

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  bool _isInteractingTopBar = false;
  bool _isInteractingBalanceCard = false;

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

  String get _todayFormatted {
    try {
      return DateFormat('EEE, d MMM', 'id_ID').format(DateTime.now());
    } catch (_) {
      return 'Hari Ini';
    }
  }

  List<TransactionModel> get _recentTransactions =>
      widget.transactions.take(5).toList();

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
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    // Formula Kaca Kristal Cair Murni (Ultra-Clear Liquid Glass, Low Opacity & Crisp Blur)
    final pillGlassStyle = LiquidGlassStyle(
      shape: const LiquidGlassShape.continuousRoundedRectangle(
        cornerRadius: 18,
      ),
      // Opacity diturunkan sangat jernih (translucent putih bening murni, bebas kabut gelap)
      color: widget.isDark
          ? Colors.white.withValues(alpha: 0.045)
          : Colors.white.withValues(alpha: 0.12),
      // Blur dipangkas agar efek lensa cair dan konten di baliknya tampak super jernih & tajam
      blur: 3.5,
      // Refraksi & magnifikasi optik khas fluida air (Apple Liquid iOS)
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

    final circleGlassStyle = LiquidGlassStyle(
      shape: const LiquidGlassShape.roundedRectangle(
        cornerRadius: 19,
      ),
      // Opacity diturunkan sangat jernih
      color: widget.isDark
          ? Colors.white.withValues(alpha: 0.045)
          : Colors.white.withValues(alpha: 0.12),
      // Blur dipangkas agar fluida jernih
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

    // Dynamic jelly-elastic touch physics for floating top bar elements (subtle & refined)
    const jellyTouch = LiquidGlassTouch(
      flex: LiquidGlassFlex(
        stretch: 11,           // Melar lembut & proporsional (tidak lebay)
        squeeze: 0.40,         // Penipisan volume halus
        lean: 0.28,            // Mengikuti jari secara wajar
        grip: 0.60,            // Cengkeraman seimbang
        compressInward: true,  // Tetap elastis jika ditekan ke dalam
        holdScale: 0.02,       // Sedikit mengembang halus (+2%) saat disentuh
        tapScale: 0.018,       // Haptic pop renyah saat klik cepat
        maxPull: 26,           // Batas tarikan aman agar tidak melar berlebihan
        advanced: LiquidGlassFlexAdvanced(
          childFollow: 0.45,     // Konten icon & text tetap proporsional (tidak distorsi)
          refractionBoost: 0.12, // Kilau optik lembut dan mewah
          stiffness: 320,        // Pegas kencang & responsif
          damping: 22,           // Stabil saat ditahan/ditarik
          releaseDamping: 18,    // Langsung membal bersih tanpa getaran/wobble berlebihan
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
            physics: (_isInteractingTopBar || _isInteractingBalanceCard)
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            slivers: [
              // Top clearance so initial content sits right below the pinned floating top islands
              SliverToBoxAdapter(
                child: SizedBox(height: topIslandPadding + 44),
              ),

                // ── LARGE TITLE "Beranda" & Sapaan Lega (Ikut Scroll Natural) ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                      "Beranda",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          "Halo, Deni",
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
                            _todayFormatted,
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
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
                                fontSize: 13,
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
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
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
                    )
                  : Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              for (int i = 0; i < _recentTransactions.length; i++) ...[
                                _buildTransactionRow(
                                  _recentTransactions[i],
                                  textColor: textColor,
                                  secondaryTextColor: secondaryTextColor,
                                ),
                                if (i < _recentTransactions.length - 1)
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

            const SliverToBoxAdapter(
              child: SizedBox(height: 170),
            ),
          ],
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
          height: (statusBarHeight > 0 ? statusBarHeight : 44) + 84,
          child: LiquidGlassScrollEdge(
            edge: LiquidGlassEdge.top,
            style: LiquidGlassScrollEdgeStyle.soft, // Feathered progressive blur via GPU dstIn ramp
            blur: 11, // Blur lembut & airy (tidak berkabut tebal)
            blurCurve: Curves.easeInQuart, // Apple curve: menahan blur halus di area status bar
            curve: Curves.easeOutCubic, // Gradasi warna menipis sangat cepat & jernih
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
                    // Pojok Kiri Atas: Floating Liquid Pill [ 💳 SakuAman ]
                    Positioned(
                      left: 0,
                      top: 0,
                      width: 142,
                      height: 38,
                      child: LiquidGlassLens(
                        style: pillGlassStyle,
                        touch: jellyTouch,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SakuLogo(size: 20, isDark: widget.isDark),
                              const SizedBox(width: 8),
                              Text(
                                "SakuAman",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Pojok Kanan Atas 1: Quick Theme Switcher (Di ujung paling kanan)
                    Positioned(
                      right: 0,
                      top: 0,
                      width: 38,
                      height: 38,
                      child: LiquidGlassLens(
                        style: circleGlassStyle,
                        touch: jellyTouch,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: widget.onToggleTheme,
                          child: Center(
                            child: Icon(
                              widget.isDark
                                  ? CupertinoIcons.sun_max_fill
                                  : CupertinoIcons.moon_stars_fill,
                              color: widget.isDark
                                  ? const Color(0xFFFF9E00)
                                  : const Color(0xFF5856D6),
                              size: 17,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Pojok Kanan Atas 2: Auto-Detect SMS & Notifikasi (Pindah Halaman ke Scanner & Log)
                    if (widget.onOpenAutoNotif != null)
                      Positioned(
                        right: 48, // 38px theme width + 10px gap
                        top: 0,
                        width: 38,
                        height: 38,
                        child: LiquidGlassLens(
                          style: circleGlassStyle,
                          touch: jellyTouch,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: widget.onOpenAutoNotif,
                            child: Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: [
                                    const Icon(
                                      CupertinoIcons.bell_fill,
                                      color: Color(0xFF007AFF),
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
                                            color: widget.isDark
                                                ? const Color(0xFF0F1523)
                                                : Colors.white,
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

  Widget _buildTransactionRow(
    TransactionModel tx, {
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    final isIncome = tx.type == TransactionType.income;

    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => widget.onDeleteTransaction(tx.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: const Color(0xFFFF2A55),
        child: const Icon(
          CupertinoIcons.trash_fill,
          color: Colors.white,
          size: 20,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Category Icon (Pastel Soft Background)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tx.categoryColor.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                tx.categoryIcon,
                color: tx.categoryColor,
                size: 19,
              ),
            ),
            const SizedBox(width: 12),

            // Title & Subtitle Terintegrasi Bersih (Tanpa Kotak Badge Berlapis)
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
                      letterSpacing: -0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2.5),
                  Text(
                    "${tx.source} • ${tx.category} • ${tx.formattedDate}",
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Amount
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 115),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  tx.formattedAmount,
                  style: TextStyle(
                    color: isIncome
                        ? const Color(0xFF00E676)
                        : textColor,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
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
