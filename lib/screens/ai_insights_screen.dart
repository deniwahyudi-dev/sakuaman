import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import '../models/transaction.dart';
import '../services/ai_advisor.dart';
import '../widgets/bouncy_touch_wrapper.dart';

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

class _AIInsightsScreenState extends State<AIInsightsScreen> {
  bool _isInteractingTopBar = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDark;
    final health = LocalAIAdvisor.analyze(widget.transactions);

    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

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
        color: const Color(0xFF34C759),
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

              // ── LARGE TITLE "Kecerdasan AI" & Subtitle Lega ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Kecerdasan AI",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Financial Health & Local Advisor",
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

              // ── HERO GLASS CARD (KESEHATAN FINANSIAL & ALOKASI BERSATU RAPI) ──
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF101626).withValues(alpha: 0.75)
                        : Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.10)
                          : const Color(0xFF0F172A).withValues(alpha: 0.08),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
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
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header: Status & Score Badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "KONDISI FINANSIAL",
                                        style: TextStyle(
                                          color: secondaryTextColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        health.grade,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: (health.score >= 70
                                            ? const Color(0xFF34C759)
                                            : const Color(0xFFFF9500))
                                        .withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: (health.score >= 70
                                              ? const Color(0xFF34C759)
                                              : const Color(0xFFFF9500))
                                          .withValues(alpha: 0.30),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    "${health.score} / 100",
                                    style: TextStyle(
                                      color: health.score >= 70
                                          ? const Color(0xFF34C759)
                                          : const Color(0xFFFF9500),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Summary Text
                            Text(
                              health.summary,
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Divider(
                                height: 1,
                                thickness: 0.6,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : const Color(0xFF0F172A).withValues(alpha: 0.08),
                              ),
                            ),

                            // Alokasi 50 / 30 / 20 Minimalis
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Alokasi Kas (Aturan 50 / 30 / 20)",
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  "Ideal",
                                  style: TextStyle(
                                    color: secondaryTextColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Segmented Progress Bar (Sleek 8px)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: SizedBox(
                                height: 8,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: (health.needsPercentage.clamp(1, 100)).toInt(),
                                      child: Container(color: const Color(0xFF007AFF)),
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      flex: (health.wantsPercentage.clamp(1, 100)).toInt(),
                                      child: Container(color: const Color(0xFFFF9500)),
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      flex: (health.savingsRate.clamp(1, 100)).toInt(),
                                      child: Container(color: const Color(0xFF34C759)),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Legend Alokasi
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildLegendItem(
                                  label: "Kebutuhan",
                                  percentage: "${health.needsPercentage.toStringAsFixed(0)}%",
                                  color: const Color(0xFF007AFF),
                                  isDark: isDark,
                                ),
                                _buildLegendItem(
                                  label: "Keinginan",
                                  percentage: "${health.wantsPercentage.toStringAsFixed(0)}%",
                                  color: const Color(0xFFFF9500),
                                  isDark: isDark,
                                ),
                                _buildLegendItem(
                                  label: "Tabungan",
                                  percentage: "${health.savingsRate.toStringAsFixed(0)}%",
                                  color: const Color(0xFF34C759),
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // ── SECTION TITLE: TEMUAN & SARAN CERDAS AI ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Temuan & Saran Cerdas AI",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 10)),

              // ── GROUPED INSET GLASS CONTAINER (SEMUA SARAN AI DALAM SATU WADAH KACA) ──
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF101626).withValues(alpha: 0.75)
                        : Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.10)
                          : const Color(0xFF0F172A).withValues(alpha: 0.08),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
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
                          for (int i = 0; i < health.insights.length; i++) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF007AFF).withValues(alpha: 0.14),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.sparkles,
                                      color: Color(0xFF007AFF),
                                      size: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      health.insights[i],
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 13.5,
                                        height: 1.4,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (i < health.insights.length - 1)
                              Padding(
                                padding: const EdgeInsets.only(left: 56, right: 16),
                                child: Divider(
                                  height: 1,
                                  thickness: 0.6,
                                  color: isDark
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

              // ── FOOTER PRIVASI MINIMALIS (TENANG & TIDAK MAKAN TEMPAT) ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
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
                    // Pojok Kiri Atas: Floating Liquid Pill [ ✨ SakuAI ]
                    Positioned(
                      left: 0,
                      top: 0,
                      width: 136,
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
                                      color: const Color(0xFF34C759).withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.sparkles,
                                      color: Color(0xFF34C759),
                                      size: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    "SakuAI",
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

                    // Pojok Kanan Atas: Floating Liquid Badge [ 🛡️ 100% Offline ]
                    Positioned(
                      right: 0,
                      top: 0,
                      width: 126,
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
                                  const Icon(
                                    CupertinoIcons.checkmark_shield_fill,
                                    color: Color(0xFF34C759),
                                    size: 13,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "100% Offline",
                                    style: TextStyle(
                                      color: const Color(0xFF34C759),
                                      fontSize: 11.5,
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

  static Widget _buildLegendItem({
    required String label,
    required String percentage,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              percentage,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.black45,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
