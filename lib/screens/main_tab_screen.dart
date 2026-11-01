import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import '../models/transaction.dart';
import '../theme/saku_theme.dart';
import '../widgets/ambient_mesh_background.dart';
import '../widgets/add_transaction_sheet.dart';
import '../widgets/bouncy_touch_wrapper.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'ai_insights_screen.dart';
import 'profile_screen.dart';
import 'notification_listener_screen.dart';

class MainTabScreen extends StatefulWidget {
  final bool initialIsDark;

  const MainTabScreen({super.key, this.initialIsDark = true});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;
  int _previousIndex = 0;
  late bool _isDark;
  bool _isMorphOpen = false;

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

  void _openAutoNotif() {
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
      ),
    ];

    // Formula Kaca Kristal Transparan Kembar (Murni tembus wallpaper)
    // Formula Kaca Kristal Transparan Kembar (Ultra-Clear Crystal Glass, Low Opacity & Crisp Blur)
    final crystalGlassStyle = LiquidGlassStyle(
      shape: const LiquidGlassShape.continuousRoundedRectangle(
        cornerRadius: 32,
      ),
      // Opacity diturunkan sangat tipis & jernih (tidak berkabut)
      color: _isDark
          ? Colors.white.withValues(alpha: 0.035)
          : Colors.white.withValues(alpha: 0.09),
      // Blur dikurangi agar konten di baliknya tampak jauh lebih tajam & bening
      blur: 4.0,
      // Refraksi & Magnifikasi optik dinamis tetap dipertahankan
      refractionIndex: 1.24,
      refractionWidth: 12.0,
      magnification: 1.05, // Efek lensa optik membesarkan konten yang lewat di bawahnya!
      dispersion: 1.8,     // Dispersi pelangi dinamis saat melewati kontras terang/gelap
      specular: LiquidGlassLight.specular(
        thickness: 3.0,
        intensity: _isDark ? 1.10 : 1.15,
      ),
      // Pendaran safir sangat tipis & anggun
      glow: LiquidGlassLight.glow(
        thickness: 5.0,
        intensity: _isDark ? 0.15 : 0.20,
        color: const Color(0xFF007AFF),
      ),
      shadow: LiquidGlassShadow(
        blur: 10,
        opacity: _isDark ? 0.16 : 0.12,
        color: _isDark ? Colors.black.withValues(alpha: 0.50) : const Color(0xFF0F172A),
      ),
      // Dynamic Luminance Adaptivity: otomatis mendeteksi kecerahan konten di bawahnya
      adaptivity: LiquidGlassAdaptivity(
        glassColorOnDark: Colors.white.withValues(alpha: 0.035),
        contentColorOnDark: Colors.white,
        glassColorOnLight: Colors.white.withValues(alpha: 0.09),
        contentColorOnLight: const Color(0xFF0F172A),
        continuousGlassColor: true,
        duration: const Duration(milliseconds: 220),
      ),
    );

    final double screenWidth = MediaQuery.sizeOf(context).width;
    const double plusSize = 64.0;
    const double sideMargin = 16.0;
    const double gap = 12.0;
    final double navBarWidth =
        (screenWidth - (sideMargin * 2) - plusSize - gap).clamp(248.0, 360.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: _isDark ? Brightness.dark : Brightness.light,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Theme(
        data: SakuTheme.getTheme(isDark: _isDark),
        child: LiquidGlassScaffold(
          backgroundColor: Colors.transparent,
          // ── FULL APPLE DYNAMIC ADAPTIVITY (LUMINANCE SAMPLING & REAL-TIME CONTRAST) ──
          adaptivity: LiquidGlassScaffoldAdaptivity(
            LiquidGlassAdaptivity(
              glassColorOnDark: Colors.white.withValues(alpha: 0.035),
              contentColorOnDark: const Color(0xFF94A3B8),
              glassColorOnLight: Colors.white.withValues(alpha: 0.09),
              contentColorOnLight: const Color(0xFF64748B),
              continuousGlassColor: true,
              duration: const Duration(milliseconds: 280),
            ),
            systemChrome: LiquidGlassSystemChrome.none,
          ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            AmbientMeshBackground(
              isDark: _isDark,
              // Standar Asli iOS (IndexedStack): Tab switching instan, bebas glitch off-screen shader,
              // dan posisi scroll tiap halaman tetap terjaga sempurna!
              child: IndexedStack(
                index: _currentIndex,
                children: screens,
              ),
            ),

            // Background barrier to dismiss morph menu when open
            if (_isMorphOpen)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _isMorphOpen = false;
                    });
                  },
                ),
              ),

            // Morphed Transaction Menu (Mengembang tepat di atas tombol '+')
            if (_isMorphOpen)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 96,
                right: 18,
                child: _buildMorphedMenu(),
              ),
          ],
        ),

        // NAVBAR UTAMA DENGAN DUAL-PIPELINE KACA MEMBESAR & TAHAN GESER OTENTIK
        bottomNavigationBar: LiquidGlassTabBar(
          width: navBarWidth,
          height: 64,
          alignment: Alignment.bottomLeft,
          margin: const EdgeInsets.only(left: sideMargin, bottom: 20),
          itemPadding: 4,
          selectedIndex: _currentIndex,
          onChanged: (index) {
            if (_currentIndex != index) {
              setState(() {
                _previousIndex = _currentIndex;
                _currentIndex = index;
                _isMorphOpen = false;
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
            // Di Dark Mode icon & label putih kristal otentik seperti Foto 1 ("Daftar Putar")
            selectedColor: _isDark ? Colors.white : const Color(0xFF007AFF),
            unselectedColor: _isDark
                ? const Color(0xFF94A3B8)
                : const Color(0xFF64748B),
            iconSize: 22,
            underGlassIconSize: 28, // Kaca membesar icon!
            labelFontSize: 10.5,
            underGlassLabelFontSize: 10.5,
            selectedFontWeight: FontWeight.w700,
            unselectedFontWeight: FontWeight.w500,
            iconLabelGap: 2,
          ),
          pillStyle: LiquidGlassTabPillStyle(
            mode: LiquidGlassPillMode.both, // Dual-pipeline morphing glass pill
            animated: true,
            growHeight: 9, // Kaca membesar!
            magnifierPill: const LiquidGlassTabMagnifierPillStyle(
              enabled: true,
              magnification: 0.87,
            ),
            color: _isDark
                ? Colors.white.withValues(alpha: 0.04)
                : const Color(0xFF0F172A).withValues(alpha: 0.03),
            glassStyle: LiquidGlassStyle(
              shape: const LiquidGlassShape(),
              // Garis rim specular putih tipis, tajam & bersih
              specular: LiquidGlassLight.specular(
                thickness: _isDark ? 1.8 : 3.5,
                intensity: _isDark ? 1.10 : 1.0,
              ),
              // Pendaran putih kristal sangat tipis & transparan di dalam kaca cembung
              color: _isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.transparent,
              blur: 0,
              refractionIndex: 1.03,
              refractionWidth: 10,
              magnification: 1,
              // Dispersi spektrum pelangi lembut tanpa celah hitam
              dispersion: _isDark ? 1.35 : 1.32,
              // Bayangan kontak natural halus
              shadow: LiquidGlassShadow(
                blur: 6,
                opacity: _isDark ? 0.15 : 0.15,
                color: Colors.black,
                offset: const Offset(0, 2),
              ),
            ),
          ),
          style: crystalGlassStyle,
        ),

        // TOMBOL '+' BERSIH DAN SEJAJAR DENGAN EFEK TAHAN MELAR HALUS & REFINED (SUBTLE JELLY)
        bottomNavigationBarAction: SizedBox(
          width: plusSize,
          height: plusSize,
          child: LiquidGlassLens(
            style: crystalGlassStyle.copyWith(
              shape: const LiquidGlassShape.roundedRectangle(
                cornerRadius: 32,
              ),
            ),
            // Sentuhan melar lembut & terkendali (tidak lebay agar tidak bertabrakan dengan navbar 4 tombol)
            touch: const LiquidGlassTouch(
              flex: LiquidGlassFlex(
                stretch: 6.0,          // Melar lembut & proporsional (maks 6px, aman & elegan)
                squeeze: 0.28,         // Deformasi volume halus tanpa gepeng
                lean: 0.18,            // Mengikuti jari secukupnya
                grip: 0.50,            // Cengkeraman seimbang
                compressInward: true,  // Tetap elastis kenyal jika ditekan ke dalam
                holdScale: 0.025,      // Mengembang halus (+2.5%) saat ditahan
                tapScale: 0.02,        // Haptic micro-pop renyah saat tap
              ),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _isMorphOpen = !_isMorphOpen;
                });
              },
              child: const Center(
                child: Icon(
                  CupertinoIcons.plus,
                  color: Color(0xFF007AFF),
                  size: 29,
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBarActionMargin: sideMargin,
      ),
    ),
  );
  }

  // Panel Kotak Kaca Cair saat mengembang (Liquid Menu)
  Widget _buildMorphedMenu() {
    final textColor = _isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor =
        _isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return LiquidGlassMorph(
      alignment: Alignment.bottomRight,
      motion: LiquidGlassMorphMotion.anchoredPop,
      smoothness: 24,
      style: LiquidGlassStyle(
        shape: const LiquidGlassShape.continuousRoundedRectangle(
          cornerRadius: 24,
        ),
        color: _isDark
            ? const Color(0xFF0F1423).withValues(alpha: 0.90)
            : Colors.white.withValues(alpha: 0.95),
        blur: 16.0,
        refractionIndex: 1.18,
        refractionWidth: 12,
        specular: const LiquidGlassLight.specular(
          thickness: 5,
          sharpness: 0.6,
          intensity: 1.3,
        ),
        glow: const LiquidGlassLight.glow(
          thickness: 10,
          intensity: 0.7,
          color: Color(0xFF007AFF),
        ),
        shadow: const LiquidGlassShadow(
          blur: 16,
          opacity: 0.35,
          color: Color(0xFF007AFF),
        ),
      ),
      child: Container(
        key: const ValueKey('menu'),
        width: 228,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Catat Transaksi",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isMorphOpen = false;
                    });
                  },
                  child: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    color: secondaryTextColor,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(
              height: 1,
              thickness: 0.6,
              color: _isDark ? const Color(0xFF2E3958) : const Color(0xFFE2E8F0),
            ),
            const SizedBox(height: 10),

            // 1. Pengeluaran
            _buildMorphActionTile(
              icon: CupertinoIcons.arrow_up_right_circle_fill,
              iconColor: const Color(0xFFFF2A55),
              title: "Pengeluaran",
              subtitle: "Belanja, makan, transport",
              onTap: () {
                setState(() => _isMorphOpen = false);
                _openAddSheet(initialType: TransactionType.expense);
              },
            ),
            const SizedBox(height: 8),

            // 2. Pemasukan
            _buildMorphActionTile(
              icon: CupertinoIcons.arrow_down_left_circle_fill,
              iconColor: const Color(0xFF00E676),
              title: "Pemasukan",
              subtitle: "Gaji, transfer, bonus",
              onTap: () {
                setState(() => _isMorphOpen = false);
                _openAddSheet(initialType: TransactionType.income);
              },
            ),
            const SizedBox(height: 8),

            // 3. Auto-Detect M-Banking
            _buildMorphActionTile(
              icon: CupertinoIcons.bell_fill,
              iconColor: const Color(0xFF007AFF),
              title: "Scan Notifikasi",
              subtitle: "Deteksi SMS M-Banking",
              onTap: () {
                setState(() => _isMorphOpen = false);
                _openAutoNotif();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMorphActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final textColor = _isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor =
        _isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return BouncyTouchWrapper(
      scaleFactor: 0.96,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 17),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 10.5,
                    ),
                  ),
                ],
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
    );
  }
}
