import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import '../services/promotion_manager.dart';
import '../widgets/glass_card.dart';
import '../widgets/bouncy_touch_wrapper.dart';

class ProfileScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  final VoidCallback? onOpenAutoNotif;
  final ValueChanged<bool>? onPopoverStateChanged;
  final ValueListenable<int>? dismissSignal;

  const ProfileScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
    this.onOpenAutoNotif,
    this.onPopoverStateChanged,
    this.dismissSignal,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isSettingsMenuOpen = false;
  bool _wide = false;

  @override
  void initState() {
    super.initState();
    widget.dismissSignal?.addListener(_handleDismissSignal);
  }

  @override
  void didUpdateWidget(ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dismissSignal != widget.dismissSignal) {
      oldWidget.dismissSignal?.removeListener(_handleDismissSignal);
      widget.dismissSignal?.addListener(_handleDismissSignal);
    }
  }

  @override
  void dispose() {
    widget.dismissSignal?.removeListener(_handleDismissSignal);
    super.dispose();
  }

  void _handleDismissSignal() {
    if (_isSettingsMenuOpen) {
      _toggleSettingsMorph(false);
    }
  }

  void _toggleSettingsMorph([bool? open]) {
    final target = open ?? !_isSettingsMenuOpen;
    if (_isSettingsMenuOpen == target) return;
    HapticFeedback.selectionClick();
    setState(() {
      _isSettingsMenuOpen = target;
      if (target) {
        _wide = true;
      }
    });
    widget.onPopoverStateChanged?.call(target);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    // Formula Kaca Kristal Cair Murni (Ultra-Clear Liquid Glass, Low Opacity & Crisp Blur)
    final pillGlassStyle = LiquidGlassStyle(
      shape: const LiquidGlassShape.continuousRoundedRectangle(
        cornerRadius: 18,
      ),
      color: isDark
          ? Colors.white.withValues(alpha: 0.045)
          : Colors.white.withValues(alpha: 0.12),
      blur: 3.5,
      refractionIndex: 1.24,
      refractionWidth: 12.0,
      magnification: 1.05,
      dispersion: 1.8,
      specular: LiquidGlassLight.specular(
        thickness: 3.2,
        intensity: isDark ? 1.20 : 1.30,
      ),
      glow: LiquidGlassLight.glow(
        thickness: 5.0,
        intensity: isDark ? 0.20 : 0.15,
        color: const Color(0xFF5856D6),
      ),
      shadow: LiquidGlassShadow(
        blur: 6,
        opacity: isDark ? 0.08 : 0.05,
        color: Colors.black,
        offset: const Offset(0, 2),
      ),
    );

    final circleGlassStyle = LiquidGlassStyle(
      shape: const LiquidGlassShape.roundedRectangle(
        cornerRadius: 19,
      ),
      color: isDark
          ? Colors.white.withValues(alpha: 0.045)
          : Colors.white.withValues(alpha: 0.12),
      blur: 3.5,
      refractionIndex: 1.24,
      refractionWidth: 12.0,
      magnification: 1.05,
      dispersion: 1.8,
      specular: LiquidGlassLight.specular(
        thickness: 3.2,
        intensity: isDark ? 1.20 : 1.30,
      ),
      glow: LiquidGlassLight.glow(
        thickness: 5.0,
        intensity: isDark ? 0.20 : 0.15,
        color: const Color(0xFF007AFF),
      ),
      shadow: LiquidGlassShadow(
        blur: 6,
        opacity: isDark ? 0.08 : 0.05,
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
            physics: _isSettingsMenuOpen
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            slivers: [
              // Spacer agar konten awal mulai di bawah floating islands
              SliverToBoxAdapter(
                child: SizedBox(height: topIslandPadding + 44),
              ),

              // ── LARGE TITLE "Akun & Pengaturan" & Subtitle Lega ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Akun & Pengaturan",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Kelola & Preferensi Aplikasi",
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

            // Profile Card (Deni Wahyudi)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassCard(
                  isDark: isDark,
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      // Avatar with Electric Blue Ring
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "D",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Deni Wahyudi",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF34C759)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF34C759)
                                          .withValues(alpha: 0.35),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        CupertinoIcons.checkmark_shield_fill,
                                        color: Color(0xFF34C759),
                                        size: 11,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "SakuAman Vault Aktif",
                                        style: TextStyle(
                                          color: Color(0xFF34C759),
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
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
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Section: Dompet & Rekening Terhubung
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "REKENING & E-WALLET",
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassCard(
                  isDark: isDark,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      _buildWalletItem(
                        icon: CupertinoIcons.building_2_fill,
                        iconColor: const Color(0xFF007AFF),
                        name: "Bank Central Asia (BCA)",
                        detail: "Prioritas • Saldo Utama",
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                      _buildDivider(isDark),
                      _buildWalletItem(
                        icon: CupertinoIcons.creditcard_fill,
                        iconColor: const Color(0xFFFF9E00),
                        name: "Bank Mandiri",
                        detail: "Tabungan Payroll",
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                      _buildDivider(isDark),
                      _buildWalletItem(
                        icon: CupertinoIcons.money_dollar_circle_fill,
                        iconColor: const Color(0xFF00F5D4),
                        name: "GoPay & ShopeePay",
                        detail: "E-Wallet Transaksi Harian",
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Section: Fitur & Keamanan
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "KEAMANAN & OTOMASI",
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassCard(
                  isDark: isDark,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      _buildSettingTile(
                        icon: CupertinoIcons.speedometer,
                        iconColor: const Color(0xFFFF9500),
                        title: "Layar & ProMotion 144Hz",
                        subtitle: "Dynamic Frame Pacer & Penanda FPS",
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _toggleSettingsMorph(true);
                        },
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                      _buildDivider(isDark),
                      _buildSettingTile(
                        icon: isDark
                            ? CupertinoIcons.moon_stars_fill
                            : CupertinoIcons.sun_max_fill,
                        iconColor: isDark
                            ? const Color(0xFF5856D6)
                            : const Color(0xFFFF9E00),
                        title: "Tema Tampilan",
                        subtitle: isDark
                            ? "Mode Gelap (Obsidian Kristal)"
                            : "Mode Terang (Clean Studio)",
                        onTap: () {
                          HapticFeedback.selectionClick();
                          widget.onToggleTheme();
                        },
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                      _buildDivider(isDark),
                      if (widget.onOpenAutoNotif != null) ...[
                        _buildSettingTile(
                          icon: CupertinoIcons.bell_fill,
                          iconColor: const Color(0xFF007AFF),
                          title: "Auto-Detect SMS / Notifikasi",
                          subtitle: "Catat otomatis dari BCA, GoPay, Mandiri",
                          onTap: widget.onOpenAutoNotif,
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                        ),
                        _buildDivider(isDark),
                      ],
                      _buildSettingTile(
                        icon: CupertinoIcons.lock_shield_fill,
                        iconColor: const Color(0xFF34C759),
                        title: "Kunci Biometrik / PIN",
                        subtitle: "Proteksi sidik jari saat membuka aplikasi",
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                      _buildDivider(isDark),
                      _buildSettingTile(
                        icon: CupertinoIcons.cloud_download_fill,
                        iconColor: const Color(0xFF5856D6),
                        title: "Ekspor & Cadangkan Data",
                        subtitle: "Unduh file CSV / PDF pembukuan",
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // App Footer Info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        "SakuAman v2.0 Liquid Glass Edition",
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Flagship GPU Accelerated • Ultra High Performance",
                        style: TextStyle(
                          color: secondaryTextColor.withValues(alpha: 0.7),
                          fontSize: 10.5,
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
            color: isDark
                ? const Color(0xFF090C15).withValues(alpha: 0.38)
                : Colors.white.withValues(alpha: 0.42),
          ),
        ),

        // ── POJOK KIRI ATAS: FLOATING LIQUID PILL [ 👤 Profil Deni ] ──
        // Diposisikan sebelum backdrop barrier agar ikut ter-defokus halus saat popover terbuka
        Positioned(
          top: topIslandPadding,
          left: 20,
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
                          color: const Color(0xFF5856D6).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.person_crop_circle_fill,
                          color: Color(0xFF5856D6),
                          size: 13,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        "Profil Deni",
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

        // ── INVISIBLE TAP-TO-DISMISS BARRIER (TANPA BLUR / DEFOKUS, KACA TETAP JERNIH) ──
        if (_isSettingsMenuOpen)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _toggleSettingsMorph(false),
            ),
          ),

        // ── POJOK KANAN ATAS: TOMBOL PENGATURAN ELASTIS MORPH [ ⚙️ -> POPOVER MENU ] ──
        Builder(
          builder: (context) {
            final double screenWidth = MediaQuery.sizeOf(context).width;
            final double menuWidth = screenWidth - 40.0; // Lebar membentang sejajar kiri dengan Profil Deni (left: 20)

            const double menuHeight = 274.0;

            return Positioned(
              top: topIslandPadding,
              right: 20,
              width: _wide ? menuWidth : 38.0,
              height: _wide ? menuHeight : 38.0,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                    LiquidGlassMorph(
                      alignment: Alignment.topRight,
                      motion: LiquidGlassMorphMotion.fluid,
                      smoothness: 28,
                      style: LiquidGlassStyle(
                        shape: LiquidGlassShape.continuousRoundedRectangle(
                          cornerRadius: _isSettingsMenuOpen ? 24 : 19,
                          clipQuality: LiquidGlassClipQuality.exact,
                        ),
                        // Golden Ratio Apple Frosted Liquid Glass (iOS 26 Style):
                        // Menahan tubrukan teks di belakang, tapi tetap memancarkan refraksi warna cairan
                        color: isDark
                            ? (_isSettingsMenuOpen
                                ? const Color(0xFF141927).withValues(alpha: 0.72)
                                : Colors.white.withValues(alpha: 0.045))
                            : (_isSettingsMenuOpen
                                ? Colors.white.withValues(alpha: 0.75)
                                : Colors.white.withValues(alpha: 0.12)),
                        blur: _isSettingsMenuOpen ? 25.0 : 3.5,
                        refractionIndex: 1.25,
                        refractionWidth: 14.0,
                        magnification: 1.05,
                        dispersion: 1.8,
                        specular: LiquidGlassLight.specular(
                          thickness: _isSettingsMenuOpen ? 4.5 : 3.2,
                          sharpness: 0.65,
                          intensity: isDark ? 1.45 : 1.55,
                        ),
                        glow: LiquidGlassLight.glow(
                          thickness: _isSettingsMenuOpen ? 8.0 : 5.0,
                          intensity: _isSettingsMenuOpen
                              ? (isDark ? 0.25 : 0.18)
                              : (isDark ? 0.20 : 0.15),
                          color: const Color(0xFF007AFF),
                        ),
                        shadow: LiquidGlassShadow(
                          blur: _isSettingsMenuOpen ? 24 : 6,
                          opacity: isDark ? 0.35 : 0.14,
                          color: isDark ? Colors.black : const Color(0xFF0F172A),
                          offset: _isSettingsMenuOpen
                              ? const Offset(0, 8)
                              : const Offset(0, 2),
                        ),
                      ),
                    onEnd: () {
                      if (_wide != _isSettingsMenuOpen) {
                        setState(() => _wide = _isSettingsMenuOpen);
                      }
                    },
                    child: _isSettingsMenuOpen
                        ? _buildMorphedSettingsMenu(
                            textColor,
                            secondaryTextColor,
                            isDark,
                            menuWidth,
                          )
                        : _buildSettingsGlyph(isDark),
                  ),
                  if (!_isSettingsMenuOpen)
                    Positioned(
                      top: 0,
                      right: 0,
                      width: 38,
                      height: 38,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _toggleSettingsMorph(true),
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

  Widget _buildSettingsGlyph(bool isDark) {
    return GestureDetector(
      key: const ValueKey<String>('glyph'),
      behavior: HitTestBehavior.opaque,
      onTap: () => _toggleSettingsMorph(true),
      child: SizedBox(
        width: 38,
        height: 38,
        child: Center(
          child: Icon(
            CupertinoIcons.gear_alt_fill,
            color: isDark ? Colors.white : const Color(0xFF007AFF),
            size: 19,
          ),
        ),
      ),
    );
  }

  Widget _buildMorphedSettingsMenu(
    Color textColor,
    Color secondaryTextColor,
    bool isDark,
    double menuWidth,
  ) {
    return SizedBox(
      key: const ValueKey<String>('menu'),
      width: menuWidth,
      height: 274,
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
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF007AFF).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.gear_alt_fill,
                            color: Color(0xFF007AFF),
                            size: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Pengaturan Tampilan",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  BouncyTouchWrapper(
                    scaleFactor: 0.82,
                    onTap: () => _toggleSettingsMorph(false),
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

              // Row 1: Penanda FPS HUD
              _buildMorphSwitchRow(
                icon: CupertinoIcons.speedometer,
                iconColor: const Color(0xFF007AFF),
                title: "Penanda FPS HUD",
                subtitle: "Kapsul FPS ProMotion real-time",
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
                valueListenable: ProMotionManager.instance.showFpsBadge,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  ProMotionManager.instance.toggleBadge(val);
                },
              ),
              const SizedBox(height: 8),

              // Row 2: Smart 1 FPS Idle
              _buildMorphSwitchRow(
                icon: CupertinoIcons.leaf_arrow_circlepath,
                iconColor: const Color(0xFF34C759),
                title: "Smart 1 FPS Idle",
                subtitle: "Hemat daya saat layar diam",
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
                valueListenable: ProMotionManager.instance.isEngineEnabled,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  ProMotionManager.instance.toggleEngine(val);
                },
              ),
              const SizedBox(height: 8),

              // Row 3: Mode Gelap (Dark Mode)
              _buildMorphThemeRow(
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
                isDark: isDark,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  widget.onToggleTheme();
                },
              ),

              const SizedBox(height: 8),
              // Hairline Divider
              Divider(
                height: 1,
                thickness: 0.5,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.08),
              ),
              const SizedBox(height: 8),

              // Row 4: Pengaturan Lanjutan (#)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  // # Pengaturan lanjutan nantinya (placeholder sesuai request user)
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5856D6).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.slider_horizontal_3,
                          color: Color(0xFF5856D6),
                          size: 15,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Pengaturan Lanjutan",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      Icon(
                        CupertinoIcons.chevron_forward,
                        color: secondaryTextColor.withValues(alpha: 0.6),
                        size: 14,
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

  Widget _buildMorphSwitchRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color textColor,
    required Color secondaryTextColor,
    required ValueNotifier<bool> valueListenable,
    required ValueChanged<bool> onChanged,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: valueListenable,
      builder: (context, value, _) {
        return Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(icon, color: iconColor, size: 14),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 9.5,
                    ),
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 0.70,
              child: CupertinoSwitch(
                value: value,
                activeTrackColor: iconColor,
                onChanged: onChanged,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMorphThemeRow({
    required Color textColor,
    required Color secondaryTextColor,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    final iconColor =
        isDark ? const Color(0xFF5856D6) : const Color(0xFFFF9E00);
    final icon =
        isDark ? CupertinoIcons.moon_stars_fill : CupertinoIcons.sun_max_fill;

    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, color: iconColor, size: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Mode Gelap",
                style: TextStyle(
                  color: textColor,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                isDark ? "Tema Gelap aktif" : "Tema Terang aktif",
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
        ),
        Transform.scale(
          scale: 0.70,
          child: CupertinoSwitch(
            value: isDark,
            activeTrackColor: const Color(0xFF5856D6),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void _openSettingsSheet() {
    final bool isDark = widget.isDark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F1626).withValues(alpha: 0.90)
                    : Colors.white.withValues(alpha: 0.94),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.white,
                    width: 1.0,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle Bar
                  Center(
                    child: Container(
                      width: 36,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: secondaryTextColor.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF007AFF)
                                  .withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              CupertinoIcons.gear_alt_fill,
                              color: Color(0xFF007AFF),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Pengaturan & Preferensi",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: secondaryTextColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.xmark,
                            color: secondaryTextColor,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Section 1: Layar & ProMotion Adaptive
                  Text(
                    "LAYAR & ADAPTIVE PROMOTION",
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.04),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Toggle Penanda FPS
                        ValueListenableBuilder<bool>(
                          valueListenable: ProMotionManager.instance.showFpsBadge,
                          builder: (context, showBadge, _) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Penanda FPS ProMotion",
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Kapsul HUD real-time (1 FPS / 60 FPS / 144 FPS)",
                                        style: TextStyle(
                                          color: secondaryTextColor,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  CupertinoSwitch(
                                    value: showBadge,
                                    activeTrackColor: const Color(0xFF007AFF),
                                    onChanged: (val) {
                                      HapticFeedback.selectionClick();
                                      ProMotionManager.instance.toggleBadge(val);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        Divider(
                          height: 0.5,
                          thickness: 0.5,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.06),
                        ),
                        // Toggle Smart ProMotion 1 FPS Idle
                        ValueListenableBuilder<bool>(
                          valueListenable:
                              ProMotionManager.instance.isEngineEnabled,
                          builder: (context, engineEnabled, _) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Smart ProMotion 1 FPS",
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Otomatis tidur ke 1 FPS saat diam > 2.5s",
                                        style: TextStyle(
                                          color: secondaryTextColor,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  CupertinoSwitch(
                                    value: engineEnabled,
                                    activeTrackColor: const Color(0xFF34C759),
                                    onChanged: (val) {
                                      HapticFeedback.selectionClick();
                                      ProMotionManager.instance
                                          .toggleEngine(val);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Section 2: Tampilan & Tema
                  Text(
                    "TAMPILAN & TEMA",
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.04),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Mode Gelap (Dark Mode)",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isDark
                                    ? "Palet Obsidian Kristal & Safir"
                                    : "Palet Clean Studio Terang",
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          CupertinoSwitch(
                            value: isDark,
                            activeTrackColor: const Color(0xFF5856D6),
                            onChanged: (_) {
                              HapticFeedback.selectionClick();
                              Navigator.pop(ctx);
                              widget.onToggleTheme();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Chip Spek Perangkat
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF101626).withValues(alpha: 0.60)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFE2E8F0),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.sparkles,
                            color: secondaryTextColor, size: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "ProMotion Dynamic Display • 60Hz - 144Hz Adaptive",
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
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
        );
      },
    );
  }

  Widget _buildWalletItem({
    required IconData icon,
    required Color iconColor,
    required String name,
    required String detail,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            CupertinoIcons.chevron_forward,
            color: Color(0xFF64748B),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return BouncyTouchWrapper(
      scaleFactor: 0.98,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_forward,
              color: Color(0xFF64748B),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 0.6,
      color: isDark ? const Color(0xFF1E2640) : const Color(0xFFE2E8F0),
    );
  }
}
