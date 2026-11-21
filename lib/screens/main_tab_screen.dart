import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import '../models/transaction.dart';
import '../services/promotion_manager.dart';
import '../services/preferences_service.dart';
import '../services/native_notification_service.dart';
import '../theme/saku_theme.dart';
import '../widgets/ambient_mesh_background.dart';
import '../widgets/add_transaction_sheet.dart';
import '../widgets/receipt_scanner_sheet.dart';
import '../widgets/bouncy_touch_wrapper.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'ai_insights_screen.dart';
import 'profile_screen.dart';
import 'notification_listener_screen.dart';

/// Formula Pegas Fisika Otentik Apple iOS (CASpringAnimation / Damped Harmonic Oscillator)
/// Memberikan akselerasi awal santai, mekar anggun, membal kenyal (+5.5% juicy bounce), lalu mengendap empuk.
class AppleSpringCurve extends Curve {
  final double damping;
  final double stiffness;

  const AppleSpringCurve({
    this.damping = 0.68,
    this.stiffness = 8.5,
  });

  @override
  double transformInternal(double t) {
    final double beta = damping * stiffness;
    final double omega = stiffness * math.sqrt(1.0 - damping * damping);
    return 1.0 -
        math.exp(-beta * t) *
            (math.cos(omega * t) + (beta / omega) * math.sin(omega * t));
  }
}

class MainTabScreen extends StatefulWidget {
  final bool initialIsDark;

  const MainTabScreen({super.key, this.initialIsDark = true});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _previousIndex = 0;
  late bool _isDark;
  bool _isMorphOpen = false;
  bool _isTopPopoverOpen = false;
  final ValueNotifier<int> _dismissTopPopoverSignal = ValueNotifier<int>(0);
  late AnimationController _dockMorphController;
  late Animation<double> _dockMorphAnimation;

  bool get _isAnyPopoverOpen => _isMorphOpen || _isTopPopoverOpen;

  void _dismissAllPopovers() {
    HapticFeedback.selectionClick();
    if (_isMorphOpen) {
      _togglePlusMorph(false);
    }
    if (_isTopPopoverOpen) {
      _dismissTopPopoverSignal.value++;
      setState(() => _isTopPopoverOpen = false);
    }
  }

  void _togglePlusMorph([bool? open]) {
    final target = open ?? !_isMorphOpen;
    if (_isMorphOpen == target) return;
    HapticFeedback.selectionClick();
    setState(() {
      _isMorphOpen = target;
    });
    if (target) {
      _dockMorphController.forward();
    } else {
      _dockMorphController.reverse();
    }
  }

  // Initial Sample Transactions
  final List<TransactionModel> _transactions = [
    TransactionModel(
      id: '1',
      title: 'Gaji Bulanan',
      amount: 8500000,
      type: TransactionType.income,
      category: 'Gaji',
      date: DateTime.now().subtract(const Duration(hours: 4)),
      source: 'BCA',
    ),
    TransactionModel(
      id: '2',
      title: 'Kopi Kenangan',
      amount: 32000,
      type: TransactionType.expense,
      category: 'Makanan',
      date: DateTime.now().subtract(const Duration(hours: 7)),
      source: 'GoPay',
    ),
    TransactionModel(
      id: '3',
      title: 'SPBU Pertamina',
      amount: 150000,
      type: TransactionType.expense,
      category: 'Transportasi',
      date: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      source: 'Mandiri',
    ),
    TransactionModel(
      id: '4',
      title: 'Alfamart Belanja',
      amount: 84000,
      type: TransactionType.expense,
      category: 'Belanja',
      date: DateTime.now().subtract(const Duration(days: 2)),
      source: 'ShopeePay',
    ),
    TransactionModel(
      id: '5',
      title: 'Investasi Reksadana',
      amount: 1000000,
      type: TransactionType.expense,
      category: 'Investasi',
      date: DateTime.now().subtract(const Duration(days: 3)),
      source: 'BCA',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _isDark = widget.initialIsDark;
    _dockMorphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 580), // Santai & anggun ala Apple
      reverseDuration: const Duration(milliseconds: 360), // Rapi & presisi saat menutup
    );
    _dockMorphAnimation = CurvedAnimation(
      parent: _dockMorphController,
      // Pegas Apple iOS otentik: awal santai, membal kenyal elastis, mengendap stabil
      curve: const AppleSpringCurve(),
      reverseCurve: Curves.easeOutCubic,
    );
    ProMotionManager.instance.initialize();
    _initGlobalNotificationListener();
  }

  void _initGlobalNotificationListener() async {
    try {
      final isGranted = await NotificationListenerService.isPermissionGranted();
      if (isGranted) {
        await NativeNotificationService().initialize(
          onTransactionDetected: (tx) {
            if (mounted) {
              _addTransaction(tx);
            }
          },
        );
        NativeNotificationService().startListening();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _dockMorphController.dispose();
    _dismissTopPopoverSignal.dispose();
    ProMotionManager.instance.dispose();
    super.dispose();
  }

  void _addTransaction(TransactionModel tx) {
    setState(() {
      _transactions.insert(0, tx);
    });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tx) => tx.id == id);
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDark = !_isDark;
    });
    PreferencesService.setDarkMode(_isDark);
  }

  void _openAddSheet({TransactionType initialType = TransactionType.expense}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddTransactionSheet(
        onAdd: _addTransaction,
        isDark: _isDark,
        initialType: initialType,
      ),
    );
  }

  void _openReceiptScanner() {
    _dismissAllPopovers();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReceiptScannerSheet(
        isDark: _isDark,
        onReceiptScanned: (result) {
          _addTransaction(result.toTransaction());
        },
      ),
    );
  }

  void _openAutoNotif() {
    _dismissAllPopovers();
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (ctx) => NotificationListenerScreen(
          onTransactionDetected: _addTransaction,
          isDark: _isDark,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        key: const PageStorageKey('dashboard_screen'),
        transactions: _transactions,
        onAddTransaction: _addTransaction,
        onDeleteTransaction: _deleteTransaction,
        isDark: _isDark,
        onToggleTheme: _toggleTheme,
        onOpenAutoNotif: _openAutoNotif,
        onPopoverStateChanged: (isOpen) {
          if (_isTopPopoverOpen != isOpen) {
            setState(() => _isTopPopoverOpen = isOpen);
          }
        },
        dismissSignal: _dismissTopPopoverSignal,
        onNavigateToHistory: () {
          setState(() {
            _previousIndex = _currentIndex;
            _currentIndex = 1;
          });
        },
      ),
      HistoryScreen(
        key: const PageStorageKey('history_screen'),
        transactions: _transactions,
        onDeleteTransaction: _deleteTransaction,
        isDark: _isDark,
      ),
      AIInsightsScreen(
        key: const PageStorageKey('insights_screen'),
        transactions: _transactions,
        isDark: _isDark,
      ),
      ProfileScreen(
        key: const PageStorageKey('profile_screen'),
        isDark: _isDark,
        onToggleTheme: _toggleTheme,
        onOpenAutoNotif: _openAutoNotif,
        onPopoverStateChanged: (isOpen) {
          if (_isTopPopoverOpen != isOpen) {
            setState(() => _isTopPopoverOpen = isOpen);
          }
        },
        dismissSignal: _dismissTopPopoverSignal,
      ),
    ];

    // ── GAYA KACA CAIR KRISTAL APPLE VISIONOS TAB BAR (FROSTED DIFFUSION PLATTER) ──
    // 1. Diffusion blur 18.0 agar teks list yang lewat di bawah tab bar memudar halus tanpa noda
    // 2. Dispersi & refraksi optik lembut (0.2 / 1.08) bebas distorsi kotor / pelangi
    // 3. Opacity kaca frosted seimbang (0.72 - 0.75) dengan specular rim Apple
    final crystalGlassStyle = LiquidGlassStyle(
      shape: const LiquidGlassShape.continuousRoundedRectangle(
        cornerRadius: 33,
      ),
      color: _isDark
          ? const Color(0xFF1C1C1E).withValues(alpha: 0.82)
          : Colors.white.withValues(alpha: 0.72),
      blur: 18.0,
      refractionIndex: 1.08,
      refractionWidth: 8.0,
      magnification: 1.0,
      dispersion: 0.2,
      specular: LiquidGlassLight.specular(
        thickness: 2.5,
        sharpness: 0.70,
        intensity: _isDark ? 1.20 : 1.30,
      ),
      glow: LiquidGlassLight.glow(
        thickness: 4.0,
        intensity: 0.10,
        color: _isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFF007AFF),
      ),
      shadow: LiquidGlassShadow(
        blur: 16.0,
        opacity: _isDark ? 0.45 : 0.10,
        color: _isDark ? Colors.black : const Color(0xFF0F172A),
        offset: const Offset(0, 4),
      ),
      // Dynamic Luminance Adaptivity: otomatis menjaga kontras teks dan icon tab bar
      adaptivity: LiquidGlassAdaptivity(
        glassColorOnDark: const Color(0xFF1C1C1E).withValues(alpha: 0.82),
        contentColorOnDark: Colors.white,
        glassColorOnLight: Colors.white.withValues(alpha: 0.72),
        contentColorOnLight: const Color(0xFF0F172A),
        continuousGlassColor: true,
        duration: const Duration(milliseconds: 220),
      ),
    );

    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    final double bottomOffset = 20.0 + bottomInset;
    const double plusSize = 66.0;
    const double sideMargin = 16.0;
    const double gap = 12.0;
    final double navBarWidth = (screenWidth - (sideMargin * 2) - plusSize - gap)
        .clamp(248.0, 360.0);
    final double dockFullWidth = screenWidth - (sideMargin * 2);
    const double dockHeight = 164.0;
    final textColor = _isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = _isDark
        ? const Color(0xFF8E8E93)
        : const Color(0xFF64748B);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: _isDark ? Brightness.dark : Brightness.light,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: _isDark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Theme(
        data: SakuTheme.getTheme(isDark: _isDark),
        child: Stack(
          children: [
            LiquidGlassScaffold(
              backgroundColor: Colors.transparent,
              // ── FULL APPLE DYNAMIC ADAPTIVITY (LUMINANCE SAMPLING & REAL-TIME CONTRAST) ──
              adaptivity: LiquidGlassScaffoldAdaptivity(
                LiquidGlassAdaptivity(
                  glassColorOnDark: Colors.white.withValues(alpha: 0.045),
                  contentColorOnDark: const Color(0xFF8E8E93),
                  glassColorOnLight: Colors.white.withValues(alpha: 0.12),
                  contentColorOnLight: const Color(0xFF64748B),
                  continuousGlassColor: false,
                  duration: const Duration(milliseconds: 280),
                ),
                systemChrome: LiquidGlassSystemChrome.none,
              ),
              body: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (_) =>
                    ProMotionManager.instance.reportInteraction(),
                onPointerMove: (_) =>
                    ProMotionManager.instance.reportInteraction(),
                child: AmbientMeshBackground(
                  isDark: _isDark,
                  child: IndexedStack(index: _currentIndex, children: screens),
                ),
              ),

              // NAVBAR UTAMA DENGAN DUAL-PIPELINE KACA MEMBESAR & TAHAN GESER OTENTIK
              // Tetap mounted permanen di tree agar bebas crash, namun di-fade transparan saat dock mekar
              bottomNavigationBar: LiquidGlassTabBar(
                width: navBarWidth,
                height: 66,
                alignment: Alignment.bottomLeft,
                margin: const EdgeInsets.only(left: sideMargin, bottom: 20),
                itemPadding: 2,
                selectedIndex: _currentIndex,
                onChanged: (index) {
                  if (_isAnyPopoverOpen) {
                    _dismissAllPopovers();
                    return;
                  }
                  if (_currentIndex != index) {
                    setState(() {
                      _previousIndex = _currentIndex;
                      _currentIndex = index;
                      _isMorphOpen = false;
                      if (_isTopPopoverOpen) {
                        _dismissTopPopoverSignal.value++;
                        _isTopPopoverOpen = false;
                      }
                    });
                  }
                },
                items: const [
                  LiquidGlassTabBarItem(
                    icon: CupertinoIcons.house_fill,
                    label: 'Beranda',
                  ),
                  LiquidGlassTabBarItem(
                    icon: CupertinoIcons.chart_bar_alt_fill,
                    label: 'Riwayat',
                  ),
                  LiquidGlassTabBarItem(
                    icon: CupertinoIcons.sparkles,
                    label: 'Analisa AI',
                  ),
                  LiquidGlassTabBarItem(
                    icon: CupertinoIcons.person_crop_circle_fill,
                    label: 'Akun',
                  ),
                ],
                itemStyle: LiquidGlassTabItemStyle(
                  selectedColor: _isMorphOpen
                      ? Colors.transparent
                      : (_isDark
                          ? const Color(0xFF0A84FF)
                          : const Color(0xFF007AFF)),
                  unselectedColor: _isMorphOpen
                      ? Colors.transparent
                      : const Color(0xFF8E8E93),
                  iconSize: 22,
                  underGlassIconSize: 24,
                  labelFontSize: 11,
                  underGlassLabelFontSize: 11,
                  selectedFontWeight: FontWeight.w700,
                  unselectedFontWeight: FontWeight.w500,
                  iconLabelGap: 2.5,
                ),
                pillStyle: LiquidGlassTabPillStyle(
                  mode: LiquidGlassPillMode.both, // Dual-pipeline morphing glass pill
                  animated: true,
                  growHeight: 9, // Kaca membesar!
                  show: !_isMorphOpen,
                  magnifierPill: const LiquidGlassTabMagnifierPillStyle(
                    enabled: true,
                    magnification: 1.0,
                  ),
                  color: _isMorphOpen
                      ? Colors.transparent
                      : (_isDark
                          ? Colors.white.withValues(alpha: 0.10)
                          : const Color(0xFF007AFF).withValues(alpha: 0.08)),
                  glassStyle: LiquidGlassStyle(
                    shape: const LiquidGlassShape(),
                    // Garis rim specular putih tipis, tajam & bersih
                    specular: LiquidGlassLight.specular(
                      thickness: 2.0,
                      intensity: _isMorphOpen
                          ? 0.0
                          : (_isDark ? 1.10 : 1.0),
                    ),
                    color: _isMorphOpen
                        ? Colors.transparent
                        : (_isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.white.withValues(alpha: 0.35)),
                    blur: 0,
                    refractionIndex: 1.02,
                    refractionWidth: 6,
                    magnification: 1.0,
                    dispersion: 0.1,
                    shadow: LiquidGlassShadow(
                      blur: 8,
                      opacity: _isMorphOpen ? 0.0 : (_isDark ? 0.18 : 0.10),
                      color: Colors.black,
                      offset: const Offset(0, 2),
                    ),
                  ),
                ),
                style: crystalGlassStyle.copyWith(
                  color: _isMorphOpen
                      ? Colors.transparent
                      : (_isDark
                          ? const Color(0xFF1C1C1E).withValues(alpha: 0.82)
                          : Colors.white.withValues(alpha: 0.75)),
                  shadow: LiquidGlassShadow(
                    blur: 16.0,
                    opacity: _isMorphOpen ? 0.0 : (_isDark ? 0.45 : 0.10),
                    color: _isDark ? Colors.black : const Color(0xFF0F172A),
                    offset: const Offset(0, 4),
                  ),
                ),
              ),

              // Spacer agar TabBar tetap sejajar saat plus button berada di stack overlay
              bottomNavigationBarAction: const SizedBox(
                width: plusSize,
                height: plusSize,
              ),
              bottomNavigationBarActionMargin: sideMargin,
            ),

            // ── APPLE IPHONE DYNAMIC CONTRAST AMBIENT SCRIM & TAP-OUTSIDE BARRIER ──
            if (_isMorphOpen)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _togglePlusMorph(false),
                  child: AnimatedBuilder(
                    animation: _dockMorphAnimation,
                    builder: (context, _) {
                      final double t =
                          _dockMorphAnimation.value.clamp(0.0, 1.0);
                      return Container(
                        color: Colors.black.withValues(
                          alpha: t * (_isDark ? 0.38 : 0.20),
                        ),
                      );
                    },
                  ),
                ),
              ),

            // ── POJOK KANAN BAWAH: TOMBOL PLUS HYBRID FLUID MORPH [ ➕ -> DOCK TRANSAKSI ] ──
            AnimatedBuilder(
              animation: _dockMorphAnimation,
              builder: (context, _) {
                final double t = _dockMorphAnimation.value;
                final double tClamped = t.clamp(0.0, 1.0);
                final double overshoot = t > 1.0 ? (t - 1.0) : 0.0;

                // Jelly spring bounce proporsional ala Apple: lebar & tinggi membal elastis
                final double widthT = t > 1.0
                    ? (1.0 + (overshoot * 0.20)).clamp(1.0, 1.025)
                    : (t < 0.0 ? 0.0 : t);

                final double heightT = t > 1.0
                    ? 1.0 + (overshoot * 1.0)
                    : (t < 0.0 ? 0.0 : t);

                final double currentWidth =
                    lerpDouble(plusSize, dockFullWidth, widthT)!
                        .clamp(plusSize, dockFullWidth);
                final double currentHeight =
                    lerpDouble(plusSize, dockHeight, heightT)!;
                final double cornerRadius =
                    lerpDouble(33.0, 26.0, tClamped)!;
                final double blur =
                    lerpDouble(4.0, 22.0, tClamped)!;

                return Positioned(
                  bottom: bottomOffset,
                  right: sideMargin,
                  width: currentWidth,
                  height: currentHeight,
                  child: tClamped <= 0.05
                      ? LiquidGlassLens(
                          style: LiquidGlassStyle(
                            shape: const LiquidGlassShape.roundedRectangle(
                              cornerRadius: 33,
                            ),
                            color: _isDark
                                ? const Color(0xFF1C1C1E).withValues(alpha: 0.82)
                                : Colors.white.withValues(alpha: 0.75),
                            blur: 18.0,
                            refractionIndex: 1.08,
                            refractionWidth: 8.0,
                            magnification: 1.0,
                            dispersion: 0.2,
                            specular: LiquidGlassLight.specular(
                              thickness: 2.5,
                              sharpness: 0.70,
                              intensity: _isDark ? 1.20 : 1.30,
                            ),
                            glow: LiquidGlassLight.glow(
                              thickness: 4.0,
                              intensity: 0.10,
                              color: _isDark
                                  ? Colors.white.withValues(alpha: 0.04)
                                  : const Color(0xFF007AFF),
                            ),
                            shadow: LiquidGlassShadow(
                              blur: 16.0,
                              opacity: _isDark ? 0.45 : 0.10,
                              color: _isDark
                                  ? Colors.black
                                  : const Color(0xFF0F172A),
                              offset: const Offset(0, 4),
                            ),
                          ),
                          touch: const LiquidGlassTouch(
                            flex: LiquidGlassFlex(
                              stretch: 7.0,
                              squeeze: 0.30,
                              lean: 0.20,
                              grip: 0.50,
                              compressInward: true,
                              holdScale: 0.03,
                              tapScale: 0.02,
                            ),
                          ),
                          child: _buildPlusGlyph(),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(cornerRadius),
                            boxShadow: [
                              // Bayangan kontak kedalaman natural ala Apple iOS
                              BoxShadow(
                                color: _isDark
                                    ? Colors.black.withValues(
                                        alpha: lerpDouble(0.25, 0.50, tClamped)!,
                                      )
                                    : const Color(0xFF007AFF).withValues(
                                        alpha: lerpDouble(0.18, 0.16, tClamped)!,
                                      ),
                                blurRadius: lerpDouble(16.0, 26.0, tClamped)!,
                                offset: Offset(0, lerpDouble(4.0, 8.0, tClamped)!),
                              ),
                              // Bayangan kontak kedalaman natural
                              BoxShadow(
                                blurRadius: lerpDouble(10.0, 24.0, tClamped)!,
                                color: _isDark
                                    ? Colors.black.withValues(
                                        alpha: lerpDouble(0.30, 0.40, tClamped)!,
                                      )
                                    : const Color(0xFF0F172A).withValues(
                                        alpha: lerpDouble(0.10, 0.12, tClamped)!,
                                      ),
                                offset: Offset(
                                  0,
                                  lerpDouble(3.0, 7.0, tClamped)!,
                                ),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(cornerRadius),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: blur,
                                sigmaY: blur,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  // Gradien Kaca Cair Apple VisionOS Selaras 100% dengan Tombol '+'
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: _isDark
                                        ? [
                                            Color.lerp(
                                              Colors.white.withValues(alpha: 0.18),
                                              const Color(0xFF2C2C2E).withValues(alpha: 0.92),
                                              tClamped,
                                            )!,
                                            Color.lerp(
                                              Colors.white.withValues(alpha: 0.05),
                                              const Color(0xFF1C1C1E).withValues(alpha: 0.88),
                                              tClamped,
                                            )!,
                                          ]
                                        : [
                                            Color.lerp(
                                              Colors.white.withValues(alpha: 0.85),
                                              Colors.white.withValues(alpha: 0.82),
                                              tClamped,
                                            )!,
                                            Color.lerp(
                                              Colors.white.withValues(alpha: 0.45),
                                              Colors.white.withValues(alpha: 0.52),
                                              tClamped,
                                            )!,
                                          ],
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(cornerRadius),
                                  border: Border.all(
                                    color: Colors.white.withValues(
                                      alpha: lerpDouble(
                                        _isDark ? 0.38 : 0.90,
                                        _isDark ? 0.32 : 0.85,
                                        tClamped,
                                      )!,
                                    ),
                                    width: 1.5,
                                  ),
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Pantulan Lengkung Spekular Atas (Apple Top Specular Arc Glare)
                                    Positioned(
                                      top: 0,
                                      left: 12,
                                      right: 12,
                                      height: 38,
                                      child: IgnorePointer(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(cornerRadius),
                                            ),
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.white.withValues(
                                                  alpha: lerpDouble(
                                                    _isDark ? 0.35 : 0.65,
                                                    _isDark ? 0.28 : 0.55,
                                                    tClamped,
                                                  )!,
                                                ),
                                                Colors.white.withValues(alpha: 0.0),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Konten 1: Icon '+' (Fade out & rotate saat t: 0.0 -> 0.40)
                                    if (tClamped < 0.45)
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        width: plusSize,
                                        height: plusSize,
                                        child: Opacity(
                                          opacity: ((0.40 - tClamped) / 0.40)
                                              .clamp(0.0, 1.0),
                                          child: Transform.rotate(
                                            angle: tClamped * 0.785,
                                            child: Transform.scale(
                                              scale: (1.0 - tClamped * 0.25)
                                                  .clamp(0.0, 1.0),
                                              child: _buildPlusGlyph(),
                                            ),
                                          ),
                                        ),
                                      ),

                                    // Konten 2: Dock Transaksi (Buoyant Apple Spring Pop)
                                    if (tClamped > 0.12)
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        width: dockFullWidth,
                                        height: dockHeight,
                                        child: Opacity(
                                          opacity: ((tClamped - 0.15) / 0.85)
                                              .clamp(0.0, 1.0),
                                          child: Transform.translate(
                                            offset: Offset(
                                              0,
                                              (1.0 - tClamped) * 10.0 - (overshoot * 6.0),
                                            ),
                                            child: Transform.scale(
                                              scale: (0.90 + (tClamped * 0.10) + (overshoot * 0.035))
                                                  .clamp(0.0, 1.05),
                                              alignment: Alignment.bottomCenter,
                                              child: _buildDynamicDockContent(
                                                textColor,
                                                secondaryTextColor,
                                                dockFullWidth,
                                                dockHeight,
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── TOMBOL '+' LINGKARAN KACA CAIR (SAAT DOCK TERTUTUP) ──
  Widget _buildPlusGlyph() {
    return GestureDetector(
      key: const ValueKey<String>('plus_glyph'),
      behavior: HitTestBehavior.opaque,
      onTap: () => _togglePlusMorph(true),
      child: Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Gradien Refraksi Kaca Cembung Apple VisionOS
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isDark
                ? [
                    Colors.white.withValues(alpha: 0.18),
                    Colors.white.withValues(alpha: 0.05),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.85),
                    Colors.white.withValues(alpha: 0.45),
                  ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: _isDark ? 0.38 : 0.90),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _isDark
                  ? Colors.black.withValues(alpha: 0.40)
                  : const Color(0xFF007AFF).withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: _isDark
                  ? Colors.black.withValues(alpha: 0.30)
                  : const Color(0xFF0F172A).withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipOval(
          child: Stack(
            children: [
              // Pantulan Lengkung Spekular Atas (Apple Top Specular Arc Glare)
              Positioned(
                top: 0,
                left: 8,
                right: 8,
                height: 28,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(33),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: _isDark ? 0.35 : 0.65),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Icon(
                  CupertinoIcons.plus,
                  color: _isDark
                      ? Colors.white
                      : const Color(0xFF007AFF),
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── DOCK PANEL KACA CAIR SAAT MEKAR PENUH (MENUTUPI 100% NAVBAR) ──
  Widget _buildDynamicDockContent(
    Color textColor,
    Color secondaryTextColor,
    double fullWidth,
    double fullHeight,
  ) {
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        key: const ValueKey<String>('dock_content'),
        width: fullWidth,
        height: fullHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Apple iOS Clean Title + Minimal Frosted Close Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF007AFF).withValues(alpha: 0.6),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          "Catat Transaksi",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                    BouncyTouchWrapper(
                      scaleFactor: 0.84,
                      onTap: () => _togglePlusMorph(false),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: _isDark
                              ? Colors.white.withValues(alpha: 0.12)
                              : const Color(0xFF0F172A).withValues(alpha: 0.06),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: _isDark ? 0.15 : 0.40),
                            width: 0.8,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            CupertinoIcons.xmark,
                            color: secondaryTextColor,
                            size: 11.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 3 Action Pods: Apple iOS Squircle Tiles (ZERO STROKE, Rich Jewel Squircles, Centered Symmetry)
                Row(
                  children: [
                    // 1. Scan Nota AI
                    Expanded(
                      child: _buildDockActionCard(
                        icon: CupertinoIcons.viewfinder,
                        gradientColors: const [Color(0xFF0A84FF), Color(0xFF0062E3)],
                        glowColor: const Color(0xFF007AFF),
                        title: "Scan Nota",
                        subtitle: "Auto AI",
                        onTap: () {
                          _togglePlusMorph(false);
                          _openReceiptScanner();
                        },
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 2. Pengeluaran
                    Expanded(
                      child: _buildDockActionCard(
                        icon: CupertinoIcons.arrow_up_right,
                        gradientColors: const [Color(0xFFFF375F), Color(0xFFFF2D55)],
                        glowColor: const Color(0xFFFF2D55),
                        title: "Pengeluaran",
                        subtitle: "Catat bayar",
                        onTap: () {
                          _togglePlusMorph(false);
                          _openAddSheet(initialType: TransactionType.expense);
                        },
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 3. Pemasukan
                    Expanded(
                      child: _buildDockActionCard(
                        icon: CupertinoIcons.arrow_down_left,
                        gradientColors: const [Color(0xFF30D158), Color(0xFF28CD41)],
                        glowColor: const Color(0xFF30D158),
                        title: "Pemasukan",
                        subtitle: "Gaji & masuk",
                        onTap: () {
                          _togglePlusMorph(false);
                          _openAddSheet(initialType: TransactionType.income);
                        },
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDockActionCard({
    required IconData icon,
    required List<Color> gradientColors,
    required Color glowColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return _VisionDockActionCard(
      icon: icon,
      gradientColors: gradientColors,
      glowColor: glowColor,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      textColor: textColor,
      secondaryTextColor: secondaryTextColor,
      isDark: _isDark,
    );
  }
}

// ── APPLE VISIONOS LIQUID GLASS ACTION CARD (3D TINTED PLATTER + DYNAMIC PRESS SHEEN) ──
class _VisionDockActionCard extends StatefulWidget {
  final IconData icon;
  final List<Color> gradientColors;
  final Color glowColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color textColor;
  final Color secondaryTextColor;
  final bool isDark;

  const _VisionDockActionCard({
    required this.icon,
    required this.gradientColors,
    required this.glowColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.textColor,
    required this.secondaryTextColor,
    required this.isDark,
  });

  @override
  State<_VisionDockActionCard> createState() => _VisionDockActionCardState();
}

class _VisionDockActionCardState extends State<_VisionDockActionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.91).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    _finishTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  void _finishTap() {
    setState(() => _isPressed = false);
    _pressController.reverse();
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 80), widget.onTap);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDark;
    final Color tintColor = widget.glowColor;

    // Platter background color with active luminance press state
    final Color platterBg = isDark
        ? (_isPressed
            ? tintColor.withValues(alpha: 0.22)
            : const Color(0xFF1E2433).withValues(alpha: 0.70))
        : (_isPressed
            ? tintColor.withValues(alpha: 0.16)
            : tintColor.withValues(alpha: 0.075));

    final Color platterBorder = isDark
        ? (_isPressed
            ? tintColor.withValues(alpha: 0.50)
            : Colors.white.withValues(alpha: 0.14))
        : (_isPressed
            ? tintColor.withValues(alpha: 0.40)
            : Colors.white.withValues(alpha: 0.90));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          height: 106,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            color: platterBg,
            border: Border.all(
              color: platterBorder,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.35)
                    : tintColor.withValues(alpha: _isPressed ? 0.25 : 0.08),
                blurRadius: _isPressed ? 14 : 10,
                offset: const Offset(0, 4),
              ),
              if (!isDark)
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.9),
                  blurRadius: 1,
                  offset: const Offset(0, 0.5),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Stack(
                children: [
                  // Specular Top Rim Glare (Apple VisionOS Crystal Reflection)
                  Positioned(
                    top: 0,
                    left: 6,
                    right: 6,
                    height: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(19),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: isDark ? 0.22 : 0.75),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content (Icon + Title + Subtitle)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Apple Jewel Squircle Icon with Ambient Backlight Glow
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Ambient radial glow behind squircle
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: tintColor.withValues(
                                  alpha: _isPressed ? 0.50 : (isDark ? 0.35 : 0.25),
                                ),
                              ),
                            ),
                            // Saturated Apple Squircle
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: widget.gradientColors,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(
                                    alpha: isDark ? 0.25 : 0.45,
                                  ),
                                  width: 0.8,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: tintColor.withValues(alpha: 0.40),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Icon Top Specular Glare Arc
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    height: 18,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12),
                                        ),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white.withValues(alpha: 0.45),
                                            Colors.white.withValues(alpha: 0.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Icon(
                                      widget.icon,
                                      color: Colors.white,
                                      size: 19,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),

                        // Title
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: widget.textColor,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            decoration: TextDecoration.none,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),

                        // Subtitle
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            color: widget.secondaryTextColor,
                            fontSize: 10.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.1,
                            decoration: TextDecoration.none,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
  }
}
