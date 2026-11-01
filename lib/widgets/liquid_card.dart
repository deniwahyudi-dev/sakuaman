import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'bouncy_touch_wrapper.dart';

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
    with TickerProviderStateMixin {
  late AnimationController _waveController;
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
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

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
    _waveController.dispose();
    _springController.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
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
    // Dynamic Luxury Gradients
    final List<Color> bgGradientColors = widget.isDark
        ? const [
            Color(0xFF030A1C),
            Color(0xFF071B3E),
            Color(0xFF0A2E68),
          ]
        : const [
            Color(0xFF0052D4),
            Color(0xFF4364F7),
            Color(0xFF00C4FF),
          ];

    final Color backWaveColor = widget.isDark
        ? const Color(0xFF38BDF8).withValues(alpha: 0.28)
        : const Color(0xFFFFFFFF).withValues(alpha: 0.25);

    final Color frontWaveColor = widget.isDark
        ? const Color(0xFF007AFF).withValues(alpha: 0.70)
        : const Color(0xFFFFFFFF).withValues(alpha: 0.40);

    final Color capsuleBgColor = widget.isDark
        ? const Color(0xFF050B18).withValues(alpha: 0.35)
        : Colors.white.withValues(alpha: 0.22);

    final Color capsuleBorderColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.22)
        : Colors.white.withValues(alpha: 0.40);

    // Dynamic subtle elastic deformation (melar & mantul tipis, volume conserved)
    final double stretchFactorX = (_dragOffset.dx.abs() / 450).clamp(0.0, 0.025);
    final double stretchFactorY = (_dragOffset.dy.abs() / 400).clamp(0.0, 0.025);
    final double scaleX = (1.0 + stretchFactorX - stretchFactorY * 0.5) * (_isHolding ? 1.015 : 1.0);
    final double scaleY = (1.0 + stretchFactorY - stretchFactorX * 0.5) * (_isHolding ? 1.015 : 1.0);

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerUp,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..translate(_dragOffset.dx * 0.8, _dragOffset.dy * 0.8)
          ..scale(scaleX, scaleY),
        child: Container(
          height: 236,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: widget.isDark
                  ? const Color(0xFF007AFF).withValues(alpha: 0.35)
                  : const Color(0xFF0052D4).withValues(alpha: 0.30),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
            if (widget.isDark)
              BoxShadow(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Deep Base Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: bgGradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // Liquid Wave Layer 1 (Glowing Back Wave)
              AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(double.infinity, 236),
                    painter: _LiquidWavePainter(
                      waveProgress: _waveController.value,
                      color: backWaveColor,
                      waveHeight: 14.0,
                      frequency: 1.8,
                      offsetY: 0.52,
                      phaseShift: 0.0,
                    ),
                  );
                },
              ),

              // Liquid Wave Layer 2 (Vibrant Front Wave)
              AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(double.infinity, 236),
                    painter: _LiquidWavePainter(
                      waveProgress: _waveController.value,
                      color: frontWaveColor,
                      waveHeight: 18.0,
                      frequency: 2.2,
                      offsetY: 0.58,
                      phaseShift: math.pi / 2,
                    ),
                  );
                },
              ),

              // Frosted Glass Overlap with Specular Iridescent Highlights
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: widget.isDark
                            ? const Color(0xFF70D6FF).withValues(alpha: 0.35)
                            : Colors.white.withValues(alpha: 0.45),
                        width: 1.2,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: widget.isDark ? 0.22 : 0.30),
                          Colors.white.withValues(alpha: 0.04),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Card
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.22),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.shield_fill,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      "Saldo Kas SakuAman",
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.95),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -0.2,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
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
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: capsuleBgColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: capsuleBorderColor,
                                    width: 0.8,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    _isBalanceVisible
                                        ? CupertinoIcons.eye_fill
                                        : CupertinoIcons.eye_slash_fill,
                                    color: widget.isDark
                                        ? const Color(0xFF38BDF8)
                                        : Colors.white,
                                    size: 14.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Nominal Saldo (Fitted to prevent overflow)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _isBalanceVisible
                                ? _formatCurrency(widget.balance)
                                : "Rp ••••••••",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                              shadows: [
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Bar Pemasukan & Pengeluaran (Capsule Glass)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: capsuleBgColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: capsuleBorderColor,
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
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00E676)
                                            .withValues(alpha: widget.isDark ? 0.35 : 0.85),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        CupertinoIcons.arrow_down_left,
                                        color: Colors.white,
                                        size: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Pemasukan",
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.85),
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              _isBalanceVisible
                                                  ? _formatCurrency(widget.totalIncome)
                                                  : "Rp ••••••",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Divider
                              Container(
                                height: 22,
                                width: 1,
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                color: Colors.white.withValues(alpha: 0.25),
                              ),

                              // Pengeluaran
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF2A55)
                                            .withValues(alpha: widget.isDark ? 0.35 : 0.85),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        CupertinoIcons.arrow_up_right,
                                        color: Colors.white,
                                        size: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Pengeluaran",
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.85),
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              _isBalanceVisible
                                                  ? _formatCurrency(widget.totalExpense)
                                                  : "Rp ••••••",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w700,
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
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

class _LiquidWavePainter extends CustomPainter {
  final double waveProgress;
  final Color color;
  final double waveHeight;
  final double frequency;
  final double offsetY;
  final double phaseShift;

  _LiquidWavePainter({
    required this.waveProgress,
    required this.color,
    required this.waveHeight,
    required this.frequency,
    required this.offsetY,
    required this.phaseShift,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final baseHeight = size.height * offsetY;

    path.moveTo(0, size.height);
    path.lineTo(0, baseHeight);

    for (double i = 0; i <= size.width; i++) {
      final angle = (i / size.width * 2 * math.pi * frequency) +
          (waveProgress * 2 * math.pi) +
          phaseShift;
      final y = baseHeight + math.sin(angle) * waveHeight;
      path.lineTo(i, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LiquidWavePainter oldDelegate) {
    return oldDelegate.waveProgress != waveProgress ||
        oldDelegate.color != color;
  }
}
