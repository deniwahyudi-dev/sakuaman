import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import '../models/transaction.dart';
import '../services/ai_advisor.dart';
import '../widgets/bouncy_touch_wrapper.dart';

/// Screen Analisa AI Minimalist & Luxe
/// Desain Apple Intelligence (iOS 18 / VisionOS):
/// - Apple Large Title murni tanpa floating pill redundan.
/// - Apple Intelligence Fluid Hero Pod dengan iridescent chromatic glow.
/// - Tombol pemicu magnetik kenyal (fluid tactile recoil) saat ditekan.
/// - Alokasi 50/30/20 minimalis dalam wadah kaca terpadu.
/// - Siri Suggestion Tiles: rekomendasi terstruktur, bukan wall-of-text kaku.
class AIInsightsScreen extends StatefulWidget {
  final List<TransactionModel> transactions;
  final bool isDark;

  const AIInsightsScreen({
    super.key,
    required this.transactions,
    required this.isDark,
  });

  @override
  State<AIInsightsScreen> createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends State<AIInsightsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  void _triggerScan() async {
    if (_isScanning) return;
    HapticFeedback.mediumImpact();
    setState(() => _isScanning = true);
    _scanController.forward(from: 0.0);

    // Haptic rhythm sequence during scanning
    await Future.delayed(const Duration(milliseconds: 350));
    if (mounted && _isScanning) HapticFeedback.selectionClick();

    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted && _isScanning) HapticFeedback.selectionClick();

    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    // Final lock-in haptic
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 90), () {
      if (mounted) HapticFeedback.lightImpact();
    });
    setState(() => _isScanning = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDark;
    final health = LocalAIAdvisor.analyze(widget.transactions);

    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark
        ? const Color(0xFF8E8E93)
        : const Color(0xFF64748B);

    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double topIslandPadding = statusBarHeight > 0 ? statusBarHeight + 6 : 8.0;

    final systemGreen = isDark ? const Color(0xFF30D158) : const Color(0xFF34C759);
    final systemOrange = isDark ? const Color(0xFFFF9F0A) : const Color(0xFFFF9500);
    final gradeColor = health.score >= 70 ? systemGreen : systemOrange;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── KONTEN SCROLLABLE ──
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Spacer top clearance
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
                        "Analisa Finansial",
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
                          // Apple Intelligence Chromatic Glowing Dot
                          Container(
                            width: 7.5,
                            height: 7.5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  Color(0xFF5AC8FA),
                                  Color(0xFFAF52DE),
                                  Color(0xFFFF2D55),
                                  Color(0xFFFF9500),
                                  Color(0xFF5AC8FA),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            "Apple Intelligence • On-Device Engine",
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 6)),

              // ── 2. HERO APPLE INTELLIGENCE FLUID POD ──
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _scanController,
                  builder: (context, _) {
                    final t = _scanController.value;
                    final pulseGlow = _isScanning ? math.sin(t * math.pi) : 0.0;
                    final cardScale = _isScanning ? (1.0 - math.sin(t * math.pi) * 0.02) : 1.0;

                    // Dynamic score counter rolling during scan
                    final int displayScore;
                    if (_isScanning) {
                      final progress = Curves.easeOutCubic.transform(t);
                      final startScore = (health.score > 30 ? health.score - 25 : 55).clamp(10, 95);
                      final jitter = (math.sin(t * 22) * 3).round();
                      displayScore = ((startScore + (health.score - startScore) * progress) + jitter).round().clamp(0, 100);
                    } else {
                      displayScore = health.score;
                    }
                    final String displayGrade = _isScanning ? "MENGKALKULASI..." : health.grade.toUpperCase();

                    return Transform.scale(
                      scale: cardScale,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          // Apple Intelligence Chromatic Glow & Ambient Shadow
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFAF52DE).withValues(
                                alpha: isDark
                                    ? (0.10 + pulseGlow * 0.35)
                                    : (0.08 + pulseGlow * 0.25),
                              ),
                              blurRadius: 24 + (pulseGlow * 18),
                              spreadRadius: pulseGlow * 1.5,
                              offset: const Offset(0, 8),
                            ),
                            if (_isScanning)
                              BoxShadow(
                                color: const Color(0xFF5AC8FA).withValues(
                                  alpha: isDark ? (pulseGlow * 0.22) : (pulseGlow * 0.16),
                                ),
                                blurRadius: 20 + (pulseGlow * 14),
                                offset: const Offset(0, -3),
                              ),
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.45 : 0.06,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          gradient: _isScanning
                              ? SweepGradient(
                                  colors: const [
                                    Color(0xFF5AC8FA),
                                    Color(0xFFAF52DE),
                                    Color(0xFFFF2D55),
                                    Color(0xFFFF9500),
                                    Color(0xFF34C759),
                                    Color(0xFF5AC8FA),
                                  ],
                                  transform: GradientRotation(t * 2 * math.pi),
                                )
                              : null,
                        ),
                        padding: _isScanning ? const EdgeInsets.all(1.8) : EdgeInsets.zero,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(_isScanning ? 24.2 : 26),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1C1C1E).withValues(alpha: 0.90)
                                    : Colors.white.withValues(alpha: 0.90),
                                borderRadius: BorderRadius.circular(_isScanning ? 24.2 : 26),
                                border: _isScanning
                                    ? null
                                    : Border.all(
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.16)
                                            : Colors.white.withValues(alpha: 0.80),
                                        width: 1.2,
                                      ),
                              ),
                              child: Stack(
                                children: [
                                  // Top Specular Glare
                                  Positioned(
                                    top: 0,
                                    left: 20,
                                    right: 20,
                                    height: 1.5,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Colors.white.withValues(alpha: 0.35),
                                            Colors.white.withValues(alpha: 0.80),
                                            Colors.white.withValues(alpha: 0.35),
                                            Colors.transparent,
                                          ],
                                          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Diagonal Shimmer Scan Wave
                                  if (_isScanning)
                                    Positioned.fill(
                                      child: IgnorePointer(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment(-2.5 + t * 5.0, -1.0),
                                              end: Alignment(-1.0 + t * 5.0, 1.0),
                                              colors: [
                                                Colors.transparent,
                                                (isDark ? const Color(0xFFAF52DE) : Colors.white)
                                                    .withValues(alpha: isDark ? 0.15 : 0.35),
                                                Colors.white.withValues(alpha: isDark ? 0.28 : 0.55),
                                                (isDark ? const Color(0xFF5AC8FA) : Colors.white)
                                                    .withValues(alpha: isDark ? 0.15 : 0.35),
                                                Colors.transparent,
                                              ],
                                              stops: const [0.0, 0.35, 0.50, 0.65, 1.0],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // Header Pod: Sparkles & Status Kesiapan
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFAF52DE).withValues(
                                                      alpha: isDark ? 0.20 : 0.12,
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    CupertinoIcons.sparkles,
                                                    color: Color(0xFFAF52DE),
                                                    size: 14,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "KESEHATAN ARUS KAS",
                                                  style: TextStyle(
                                                    color: secondaryTextColor,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 0.8,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 9,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: gradeColor.withValues(
                                                  alpha: isDark ? 0.18 : 0.10,
                                                ),
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: gradeColor.withValues(
                                                    alpha: isDark ? 0.30 : 0.22,
                                                  ),
                                                  width: 0.8,
                                                ),
                                              ),
                                              child: Text(
                                                "$displayScore / 100",
                                                style: TextStyle(
                                                  color: gradeColor,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  fontFeatures: const [
                                                    FontFeature.tabularFigures()
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 16),

                                        // Big Bold 52pt Score Centerpiece
                                        Text(
                                          "$displayScore",
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: 52,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -2.0,
                                            fontFeatures: const [
                                              FontFeature.tabularFigures()
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 2),

                                        Text(
                                          displayGrade,
                                          style: TextStyle(
                                            color: gradeColor,
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.4,
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        // Brief Contextual AI Summary
                                        Text(
                                          health.summary,
                                          style: TextStyle(
                                            color: secondaryTextColor,
                                            fontSize: 13,
                                            height: 1.4,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),

                                        const SizedBox(height: 18),

                                        // ── TRIGGER BUTTON ──
                                        BouncyTouchWrapper(
                                          scaleFactor: 0.94,
                                          onTap: _triggerScan,
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 240),
                                            curve: Curves.easeOutCubic,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 18,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? Colors.white.withValues(
                                                      alpha: _isScanning ? 0.18 : 0.08,
                                                    )
                                                  : const Color(0xFF0F172A).withValues(
                                                      alpha: _isScanning ? 0.10 : 0.05,
                                                    ),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(
                                                color: _isScanning
                                                    ? const Color(0xFFAF52DE).withValues(alpha: 0.45)
                                                    : (isDark
                                                        ? Colors.white.withValues(alpha: 0.12)
                                                        : const Color(0xFF0F172A).withValues(alpha: 0.08)),
                                                width: 1.0,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Transform.rotate(
                                                  angle: _isScanning ? (t * 4 * math.pi) : 0,
                                                  child: const Icon(
                                                    CupertinoIcons.sparkles,
                                                    color: Color(0xFFAF52DE),
                                                    size: 15,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  _isScanning
                                                      ? "Menghitung Alur Kas..."
                                                      : "Pindai Ulang dengan AI",
                                                  style: TextStyle(
                                                    color: textColor,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: -0.2,
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
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── 3. SECTION: ALOKASI KAS (ATURAN 50 / 30 / 20) ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 7),
                  child: Text(
                    "ALOKASI KAS (ATURAN 50 / 30 / 20)",
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1C1C1E).withValues(alpha: 0.85)
                        : Colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.white,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.45)
                            : const Color(0xFF0F172A).withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                      if (!isDark)
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sleek Apple Segmented Capsule Bar (9px height)
                          SizedBox(
                            height: 9,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: (health.needsPercentage.clamp(1, 100)).toInt(),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF007AFF),
                                      borderRadius: BorderRadius.circular(4.5),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 3.5),
                                Expanded(
                                  flex: (health.wantsPercentage.clamp(1, 100)).toInt(),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF9500),
                                      borderRadius: BorderRadius.circular(4.5),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 3.5),
                                Expanded(
                                  flex: (health.savingsRate.clamp(1, 100)).toInt(),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF34C759),
                                      borderRadius: BorderRadius.circular(4.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // 3 Pods Legend (Expanded Symmetrical Alignment)
                          Row(
                            children: [
                              _buildLegendItem(
                                label: "Kebutuhan",
                                percentage: "${health.needsPercentage.toStringAsFixed(0)}%",
                                target: "Maks 50%",
                                color: const Color(0xFF007AFF),
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                alignment: CrossAxisAlignment.start,
                              ),
                              _buildLegendItem(
                                label: "Keinginan",
                                percentage: "${health.wantsPercentage.toStringAsFixed(0)}%",
                                target: "Maks 30%",
                                color: const Color(0xFFFF9500),
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                alignment: CrossAxisAlignment.center,
                              ),
                              _buildLegendItem(
                                label: "Tabungan",
                                percentage: "${health.savingsRate.toStringAsFixed(0)}%",
                                target: "Min 20%",
                                color: const Color(0xFF34C759),
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                alignment: CrossAxisAlignment.end,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── 4. SECTION: REKOMENDASI CERDAS AI (SIRI SUGGESTIONS) ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 7),
                  child: Text(
                    "REKOMENDASI CERDAS AI",
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1C1C1E).withValues(alpha: 0.85)
                        : Colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.white,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.45)
                            : const Color(0xFF0F172A).withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                      if (!isDark)
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
                          for (int i = 0; i < health.insights.length; i++) ...[
                            _buildInsightTile(
                              rawInsight: health.insights[i],
                              textColor: textColor,
                              secondaryTextColor: secondaryTextColor,
                              isDark: isDark,
                            ),
                            if (i < health.insights.length - 1)
                              Padding(
                                padding: const EdgeInsets.only(left: 69, right: 16),
                                child: Divider(
                                  height: 1,
                                  thickness: 0.5,
                                  color: isDark
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

              // ── FOOTER PRIVASI MUTLAK ON-DEVICE ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.checkmark_shield_fill,
                          color: Color(0xFF34C759),
                          size: 13,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            "Kalkulasi lokal di prosesor HP • Privasi mutlak tanpa cloud",
                            style: TextStyle(
                              color: secondaryTextColor.withValues(alpha: 0.75),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Clearance Spacer
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

  /// Apple Siri Suggestion Inset Tile
  Widget _buildInsightTile({
    required String rawInsight,
    required Color textColor,
    required Color secondaryTextColor,
    required bool isDark,
  }) {
    IconData icon = CupertinoIcons.sparkles;
    Color iconColor = const Color(0xFF007AFF);
    String title = "Saran Finansial";
    String body = rawInsight;
    String badge = "INFO";

    if (rawInsight.contains("Defisit") || rawInsight.contains("⚠️")) {
      icon = CupertinoIcons.exclamationmark_triangle_fill;
      iconColor = const Color(0xFFFF3B30);
      title = "Peringatan Arus Kas";
      body = rawInsight.replaceAll("⚠️ ", "");
      badge = "PERINGATAN";
    } else if (rawInsight.contains("Mantap") || rawInsight.contains("🌟") || rawInsight.contains(">25%")) {
      icon = CupertinoIcons.star_fill;
      iconColor = const Color(0xFF34C759);
      title = "Rasio Tabungan Prima";
      body = rawInsight.replaceAll("🌟 ", "");
      badge = "OPTIMAL";
    } else if (rawInsight.contains("mendominasi") || rawInsight.contains("Kategori")) {
      icon = CupertinoIcons.chart_pie_fill;
      iconColor = const Color(0xFF5856D6);
      title = "Dominasi Pengeluaran";
      body = rawInsight.replaceAll("💡 ", "");
      badge = "ANALISA";
    } else if (rawInsight.contains("Keinginan") || rawInsight.contains("Lifestyle") || rawInsight.contains("☕")) {
      icon = CupertinoIcons.bag_fill;
      iconColor = const Color(0xFFFF9500);
      title = "Porsi Gaya Hidup";
      body = rawInsight.replaceAll("☕ ", "").replaceAll("🎯 ", "");
      badge = "KONTROL";
    } else if (rawInsight.contains("lokal") || rawInsight.contains("internet") || rawInsight.contains("🔒")) {
      icon = CupertinoIcons.lock_shield_fill;
      iconColor = const Color(0xFF5AC8FA);
      title = "Privasi On-Device Mutlak";
      body = rawInsight.replaceAll("🔒 ", "");
      badge = "AMAN";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Apple Squircle Icon dengan Soft Tinted Jewel Glass
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.18 : 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: iconColor.withValues(alpha: isDark ? 0.28 : 0.16),
                width: 0.8,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 19),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: isDark ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: iconColor.withValues(alpha: isDark ? 0.25 : 0.14),
                          width: 0.6,
                        ),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: iconColor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12.5,
                    height: 1.38,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required String label,
    required String percentage,
    required String target,
    required Color color,
    required Color textColor,
    required Color secondaryTextColor,
    CrossAxisAlignment alignment = CrossAxisAlignment.start,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Text(
                percentage,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1.5),
          Text(
            target,
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
