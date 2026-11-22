import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/promotion_manager.dart';
import 'saku_logo.dart';

class LiquidBalanceCard extends StatefulWidget {
  final double balance;
  final double totalIncome;
  final double totalExpense;
  final bool isDark;
  final ValueChanged<bool>? onScrollLockChanged;

  const LiquidBalanceCard({
    super.key,
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
    this.isDark = true,
    this.onScrollLockChanged,
  });

  @override
  State<LiquidBalanceCard> createState() => _LiquidBalanceCardState();
}

class _LiquidBalanceCardState extends State<LiquidBalanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _springController;
  late Animation<Offset> _springAnimation;

  bool _isBalanceVisible = true;
  Timer? _holdTimer;
  Offset? _pointerDownPos;
  bool _isHolding = false;
  Offset _dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();

    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _springAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _springController,
      curve: Curves.easeOutBack,
    ));

    _springController.addListener(() {
      setState(() {
        _dragOffset = _springAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _springController.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    ProMotionManager.instance.reportInteraction();
    _pointerDownPos = event.position;
    _springController.stop();
    _holdTimer?.cancel();

    // Syarat: Tahan sebentar (220ms) untuk memastikan apakah user ingin scroll atau mantul
    _holdTimer = Timer(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      _isHolding = true;
      HapticFeedback.lightImpact();
      widget.onScrollLockChanged?.call(true);
      setState(() {});
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_isHolding && _pointerDownPos != null) {
      // Jika jari bergerak > 10px sebelum 220ms, berarti niat user adalah SCROLL halaman
      if ((event.position - _pointerDownPos!).distance > 10.0) {
        _holdTimer?.cancel();
      }
      return;
    }

    if (_isHolding) {
      // Efek melar/tarik tipis & terkontrol (subtle, tidak berlebihan)
      final rawDelta = event.delta;
      final newDx = (_dragOffset.dx + rawDelta.dx * 0.45).clamp(-16.0, 16.0);
      final newDy = (_dragOffset.dy + rawDelta.dy * 0.40).clamp(-14.0, 14.0);
      setState(() {
        _dragOffset = Offset(newDx, newDy);
      });
    }
  }

  void _onPointerUp(PointerEvent event) {
    _holdTimer?.cancel();
    if (_isHolding) {
      _isHolding = false;
      widget.onScrollLockChanged?.call(false);

      // Efek mantul tipis saat dilepas (soft recoil spring)
      _springAnimation = Tween<Offset>(
        begin: _dragOffset,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _springController,
        curve: Curves.easeOutBack,
      ));
      _springController.forward(from: 0.0);
    }
    _pointerDownPos = null;
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    // ── APPLE WALLET / VISIONOS TITANIUM OBSIDIAN PALETTE ──
    final List<Color> bgGradientColors = widget.isDark
        ? const [
            Color(0xFF1C1C1E), // Apple System Gray 6
            Color(0xFF141416), // Dark Titanium
            Color(0xFF0A0A0C), // Pure Obsidian
          ]
        : const [
            Color(0xFF1C1C1E), // Space Black
            Color(0xFF141416), // Titanium
            Color(0xFF0A0A0C), // Deep Obsidian
          ];

    final Color radialSpecularColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.08) // Apple Card brushed titanium sheen
        : Colors.white.withValues(alpha: 0.12);

    // Dynamic subtle elastic deformation (melar & mantul tipis, volume conserved)
    final double stretchFactorX = (_dragOffset.dx.abs() / 450).clamp(0.0, 0.025);
    final double stretchFactorY = (_dragOffset.dy.abs() / 400).clamp(0.0, 0.025);
    final double scaleX =
        (1.0 + stretchFactorX - stretchFactorY * 0.5) * (_isHolding ? 1.015 : 1.0);
    final double scaleY =
        (1.0 + stretchFactorY - stretchFactorX * 0.5) * (_isHolding ? 1.015 : 1.0);

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerUp,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setTranslationRaw(_dragOffset.dx * 0.8, _dragOffset.dy * 0.8, 0.0)
          ..setEntry(0, 0, scaleX)
          ..setEntry(1, 1, scaleY),
        child: Container(
          height: 232,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: widget.isDark ? 0.60 : 0.22),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
              if (!widget.isDark)
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Stack(
              children: [
                // 1. Deep Base Titanium Obsidian Gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: bgGradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),

                // 2. Specular Radial Glow (Top-Right Sheen ala Apple Card)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0.85, -0.85),
                        radius: 1.15,
                        colors: [
                          radialSpecularColor,
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.70],
                      ),
                    ),
                  ),
                ),

                // 3. Apple Wallet Diagonal Light Sheen (Brushed Titanium Sheen)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: const Alignment(-1.0, -1.0),
                        end: const Alignment(0.8, 0.8),
                        colors: [
                          Colors.white.withValues(alpha: widget.isDark ? 0.08 : 0.12),
                          Colors.white.withValues(alpha: 0.02),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.35, 0.75],
                      ),
                    ),
                  ),
                ),

                // 4. VisionOS Top Edge Specular Glare Arc
                Positioned(
                  top: 0,
                  left: 24,
                  right: 24,
                  height: 1.2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.50),
                          Colors.white.withValues(alpha: 0.85),
                          Colors.white.withValues(alpha: 0.50),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                      ),
                    ),
                  ),
                ),

                // 5. Frosted Specular Border & Surface Card Content
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: widget.isDark
                            ? Colors.white.withValues(alpha: 0.18)
                            : Colors.white.withValues(alpha: 0.28),
                        width: 1.2,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header Card ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left Brand: SakuLogo + SakuAman + Contactless
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SakuLogo(size: 26, isDark: true),
                                const SizedBox(width: 9),
                                const Text(
                                  "SakuAman",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  CupertinoIcons.radiowaves_right,
                                  color: Colors.white.withValues(alpha: 0.45),
                                  size: 14,
                                ),
                              ],
                            ),

                            // Right: Privacy Toggle Button (Liquid Glass Circle)
                            GestureDetector(
                              key: const ValueKey('privacy_toggle_button'),
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _isBalanceVisible = !_isBalanceVisible;
                                });
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.09),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    width: 0.8,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    _isBalanceVisible
                                        ? CupertinoIcons.eye_fill
                                        : CupertinoIcons.eye_slash_fill,
                                    color: Colors.white,
                                    size: 14.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // ── Nominal Saldo (Tabular Figures & Razor-Sharp Clarity) ──
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _isBalanceVisible
                                ? _formatCurrency(widget.balance)
                                : "Rp ••••••••",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.8,
                              fontFeatures: [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 5),

                        // Subtitle Status / Security Chip (Apple Green dot)
                        Row(
                          children: [
                            Container(
                              width: 6.5,
                              height: 6.5,
                              decoration: BoxDecoration(
                                color: const Color(0xFF34C759),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF34C759).withValues(alpha: 0.5),
                                    blurRadius: 6,
                                    spreadRadius: 0.5,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              "Kas Utama • On-Device Encrypted",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.60),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // ── Bar Pemasukan & Pengeluaran (Capsule Glass) ──
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.14),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Pemasukan
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF34C759).withValues(alpha: 0.16),
                                        borderRadius: BorderRadius.circular(9),
                                        border: Border.all(
                                          color: const Color(0xFF34C759).withValues(alpha: 0.28),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          CupertinoIcons.arrow_down_left,
                                          color: Color(0xFF34C759),
                                          size: 13,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 9),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Pemasukan",
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.70),
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 1),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              _isBalanceVisible
                                                  ? _formatCurrency(widget.totalIncome)
                                                  : "Rp ••••••",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.2,
                                                fontFeatures: [
                                                  FontFeature.tabularFigures(),
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

                              // Vertical Divider
                              Container(
                                height: 24,
                                width: 0.6,
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                color: Colors.white.withValues(alpha: 0.16),
                              ),

                              // Pengeluaran
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF3B30).withValues(alpha: 0.16),
                                        borderRadius: BorderRadius.circular(9),
                                        border: Border.all(
                                          color: const Color(0xFFFF3B30).withValues(alpha: 0.28),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          CupertinoIcons.arrow_up_right,
                                          color: Color(0xFFFF453A),
                                          size: 13,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 9),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Pengeluaran",
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.70),
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 1),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              _isBalanceVisible
                                                  ? _formatCurrency(widget.totalExpense)
                                                  : "Rp ••••••",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.2,
                                                fontFeatures: [
                                                  FontFeature.tabularFigures(),
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
        ),
      ),
    );
  }
}
