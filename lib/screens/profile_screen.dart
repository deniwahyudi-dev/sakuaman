import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import '../widgets/glass_card.dart';
import '../widgets/bouncy_touch_wrapper.dart';

class ProfileScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  final VoidCallback? onOpenAutoNotif;

  const ProfileScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
    this.onOpenAutoNotif,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isInteractingTopBar = false;

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
            physics: _isInteractingTopBar
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
                        "Flagship GPU Accelerated • Dimensity 9300+",
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
                    // Pojok Kiri Atas: Floating Liquid Pill [ 👤 Profil Deni ]
                    Positioned(
                      left: 0,
                      top: 0,
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

                    // Pojok Kanan Atas: Quick Theme Switcher [ ☀️/🌙 ] (Posisi & Ukuran Identik dengan Beranda)
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
                              isDark
                                  ? CupertinoIcons.sun_max_fill
                                  : CupertinoIcons.moon_stars_fill,
                              color: isDark
                                  ? const Color(0xFFFF9E00)
                                  : const Color(0xFF5856D6),
                              size: 17,
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
