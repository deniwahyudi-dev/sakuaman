import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/saku_theme.dart';
import '../services/preferences_service.dart';
import '../widgets/bouncy_touch_wrapper.dart';
import '../widgets/saku_logo.dart';
import 'main_tab_screen.dart';

/// Screen Sambutan Otentik Apple iOS dengan Real Fluid Aurora & Bare SF Symbols
/// 100% BEBAS DARI KOTAK/STROKE TEMPLATE AI:
/// - Icon murni (Bare SF Symbols) langsung di samping teks tanpa kotak tumpul abu-abu.
/// - Background Aurora fluida aktif yang nyata bergerak dan berpendar (VisionOS Aurora Mesh).
class OnboardingScreen extends StatefulWidget {
  final bool isDark;

  const OnboardingScreen({super.key, this.isDark = true});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _auroraController;
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark;

    // Animasi masuk berirama (Staggered Entry)
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Animasi Aurora berputar dan mengalir nyata (Continuous Fluid Aurora)
    _auroraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _auroraController.dispose();
    super.dispose();
  }

  void _finish(BuildContext context) {
    HapticFeedback.mediumImpact();
    PreferencesService.setOnboardingSeen(true);
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (_, __, ___) => MainTabScreen(initialIsDark: _isDark),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  Animation<double> _createIntervalAnimation(double start, double end) {
    return CurvedAnimation(
      parent: _entryController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = _isDark ? Colors.white : SakuTheme.lightTextPrimary;
    final secondaryTextColor = _isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    final double topPadding = MediaQuery.paddingOf(context).top;
    final double bottomPadding = MediaQuery.paddingOf(context).bottom;

    final headerAnim = _createIntervalAnimation(0.0, 0.45);
    final feat1Anim = _createIntervalAnimation(0.20, 0.65);
    final feat2Anim = _createIntervalAnimation(0.35, 0.80);
    final feat3Anim = _createIntervalAnimation(0.50, 0.95);
    final buttonAnim = _createIntervalAnimation(0.65, 1.0);

    return Scaffold(
      backgroundColor: _isDark ? const Color(0xFF060912) : const Color(0xFFF6F8FC),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. REAL VISIONOS FLUID AURORA (NYATA BERGERAK & BERPENDAR HIDUP) ──
          AnimatedBuilder(
            animation: _auroraController,
            builder: (context, _) {
              final t = _auroraController.value * 2 * math.pi;

              return CustomPaint(
                size: Size.infinite,
                painter: _VisionOSAuroraPainter(
                  time: t,
                  isDark: _isDark,
                ),
              );
            },
          ),

          // Lapisan Frosted Diffusion Halus (Mencairkan Warna Jadi Aurora Sutra)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
              child: const SizedBox.expand(),
            ),
          ),

          // ── 2. KONTEN SAMBUTAN VERTIKAL RESMI APPLE (TANPA KOTAK TEMPLATE AI) ──
          SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  28, topPadding + 36, 28, bottomPadding + 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── APPLE HEADER: LOGO SAKU BERSIH + DISPLAY TITLE ──
                  _buildAnimatedSection(
                    animation: headerAnim,
                    child: Column(
                      children: [
                        SakuLogo(size: 64, isDark: _isDark),
                        const SizedBox(height: 18),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              color: textColor,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.0,
                              height: 1.15,
                              fontFamily: '.SF Pro Text',
                            ),
                            children: [
                              const TextSpan(text: "Selamat Datang\ndi "),
                              TextSpan(
                                text: "Saku",
                                style: TextStyle(
                                  foreground: Paint()
                                    ..shader = const LinearGradient(
                                      colors: [
                                        Color(0xFF007AFF),
                                        Color(0xFF00F5D4),
                                      ],
                                    ).createShader(
                                      const Rect.fromLTWH(0, 0, 100, 40),
                                    ),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ── 3 FITUR UTAMA: BARE SF SYMBOLS (MURNI IKON, NO BOX, NO STROKE) ──
                  _buildAnimatedSection(
                    animation: feat1Anim,
                    child: _buildAppleFeatureRow(
                      icon: CupertinoIcons.bolt_horizontal_fill,
                      iconColor: const Color(0xFF007AFF),
                      title: "Deteksi Otomatis",
                      subtitle:
                          "Membaca notifikasi SMS bank & e-wallet seketika tanpa perlu input manual.",
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildAnimatedSection(
                    animation: feat2Anim,
                    child: _buildAppleFeatureRow(
                      icon: CupertinoIcons.circle_grid_hex_fill,
                      iconColor: const Color(0xFF5AC8FA),
                      title: "Desain Liquid Glass",
                      subtitle:
                          "Antarmuka jernih dan kontrol gestur elastis berstandar Apple VisionOS.",
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildAnimatedSection(
                    animation: feat3Anim,
                    child: _buildAppleFeatureRow(
                      icon: CupertinoIcons.lock_shield_fill,
                      iconColor: const Color(0xFF34C759),
                      title: "Privasi di Perangkat",
                      subtitle:
                          "Seluruh catatan finansial tersimpan aman di ponsel Anda tanpa pelacak pihak ketiga.",
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // ── FOOTER RESMI APPLE ──
                  _buildAnimatedSection(
                    animation: buttonAnim,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.lock_fill,
                              color: secondaryTextColor,
                              size: 11.5,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                "Saku dirancang untuk melindungi data finansial pribadi Anda.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Tombol Kapsul Apple Ramping
                        BouncyTouchWrapper(
                          scaleFactor: 0.97,
                          onTap: () => _finish(context),
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFF007AFF),
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF007AFF).withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                "Lanjutkan",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                              ),
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
        ],
      ),
    );
  }

  Widget _buildAnimatedSection({
    required Animation<double> animation,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final slideY = (1.0 - animation.value) * 24.0;
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, slideY),
            child: child,
          ),
        );
      },
    );
  }

  /// FORMAT RESMI APPLE: BARE SF SYMBOLS TANPA KOTAK TUMPUL & TANPA STROKE AI
  Widget _buildAppleFeatureRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ikon Murni Bersih (Bare Icon)
        SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: Icon(
              icon,
              color: iconColor,
              size: 30,
            ),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3.5),
              Text(
                subtitle,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Painter Khusus VisionOS Fluid Aurora Mesh
/// Menggambar 3 kolam cahaya dinamis (Safir, Cyan, Indigo) yang bergerak nyata
class _VisionOSAuroraPainter extends CustomPainter {
  final double time;
  final bool isDark;

  const _VisionOSAuroraPainter({required this.time, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Kolam Cahaya Biru Safir (Mengalir di bagian atas & tengah)
    final orb1Center = Offset(
      w * 0.50 + math.cos(time * 0.7) * (w * 0.28),
      h * 0.22 + math.sin(time * 0.5) * (h * 0.08),
    );
    final paint1 = Paint()
      ..color = (isDark ? const Color(0xFF007AFF) : const Color(0xFF0052D4))
          .withValues(alpha: isDark ? 0.42 : 0.24)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(orb1Center, w * 0.55, paint1);

    // 2. Kolam Cahaya Cyber Cyan (Mengalir di kanan atas & bawah judul)
    final orb2Center = Offset(
      w * 0.65 + math.sin(time * 0.8) * (w * 0.25),
      h * 0.35 + math.cos(time * 0.6) * (h * 0.10),
    );
    final paint2 = Paint()
      ..color = (isDark ? const Color(0xFF00F5D4) : const Color(0xFF00C4FF))
          .withValues(alpha: isDark ? 0.32 : 0.20)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(orb2Center, w * 0.45, paint2);

    // 3. Kolam Cahaya Royal Indigo / Ungu VisionOS (Mengalir di kiri bawah)
    final orb3Center = Offset(
      w * 0.30 - math.cos(time * 0.6) * (w * 0.22),
      h * 0.60 + math.sin(time * 0.7) * (h * 0.12),
    );
    final paint3 = Paint()
      ..color = (isDark ? const Color(0xFF5856D6) : const Color(0xFF7209B7))
          .withValues(alpha: isDark ? 0.35 : 0.18)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(orb3Center, w * 0.50, paint3);
  }

  @override
  bool shouldRepaint(covariant _VisionOSAuroraPainter oldDelegate) {
    return oldDelegate.time != time || oldDelegate.isDark != isDark;
  }
}
