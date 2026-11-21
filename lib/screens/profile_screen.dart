import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import '../services/promotion_manager.dart';
import '../services/native_notification_service.dart';
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

  void _handleDismissSignal() {}

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF64748B);

    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double topIslandPadding = statusBarHeight > 0 ? statusBarHeight + 6 : 8.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── KONTEN SCROLLABLE DI BAWAH KACA (FLOWS UNDERNEATH PINNED TOP BAR) ──
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
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pengaturan",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Preferensi Akun, Dompet & Sistem",
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 2. APPLE ID HERO POD (DENI WAHYUDI) ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BouncyTouchWrapper(
                    scaleFactor: 0.98,
                    onTap: () => _showProfileAccountSheet(context),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1C1C1E).withValues(alpha: 0.88)
                            : Colors.white.withValues(alpha: 0.90),
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
                                ? Colors.black.withValues(alpha: 0.40)
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
                          child: Row(
                            children: [
                              // Avatar Initials "DW" with Specular Ring
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: isDark ? 0.25 : 0.60),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF007AFF).withValues(alpha: 0.25),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    "DW",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.5,
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
                                        fontSize: 18.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      "Saku ID • Akun Pribadi",
                                      style: TextStyle(
                                        color: secondaryTextColor,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7.5, vertical: 2.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF34C759)
                                            .withValues(alpha: isDark ? 0.16 : 0.10),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFF34C759)
                                              .withValues(alpha: isDark ? 0.30 : 0.20),
                                          width: 0.7,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            CupertinoIcons.checkmark_shield_fill,
                                            color: Color(0xFF34C759),
                                            size: 10.5,
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
                              ),
                              Icon(
                                CupertinoIcons.chevron_forward,
                                color: secondaryTextColor.withValues(alpha: 0.40),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 22)),

              // ── 3. SECTION: REKENING & E-WALLET ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    "REKENING & E-WALLET",
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
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: _buildGroupedCardDecoration(isDark),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Column(
                        children: [
                          _buildAppleSettingRow(
                            icon: CupertinoIcons.building_2_fill,
                            iconColor: const Color(0xFF007AFF),
                            title: "Bank Central Asia (BCA)",
                            trailingText: "Prioritas",
                            onTap: () => _showWalletDetailSheet(
                              context: context,
                              name: "Bank Central Asia (BCA)",
                              accountNo: "•••• 8821",
                              role: "Prioritas • Saldo Utama",
                              balance: "Rp 34.250.000",
                              color: const Color(0xFF007AFF),
                              icon: CupertinoIcons.building_2_fill,
                            ),
                            textColor: textColor,
                            secondaryTextColor: secondaryTextColor,
                            isDark: isDark,
                          ),
                          _buildDivider(isDark),
                          _buildAppleSettingRow(
                            icon: CupertinoIcons.creditcard_fill,
                            iconColor: const Color(0xFFFF9500),
                            title: "Bank Mandiri",
                            trailingText: "Payroll",
                            onTap: () => _showWalletDetailSheet(
                              context: context,
                              name: "Bank Mandiri",
                              accountNo: "•••• 3491",
                              role: "Tabungan Payroll",
                              balance: "Rp 12.800.000",
                              color: const Color(0xFFFF9500),
                              icon: CupertinoIcons.creditcard_fill,
                            ),
                            textColor: textColor,
                            secondaryTextColor: secondaryTextColor,
                            isDark: isDark,
                          ),
                          _buildDivider(isDark),
                          _buildAppleSettingRow(
                            icon: CupertinoIcons.money_dollar_circle_fill,
                            iconColor: const Color(0xFF34C759),
                            title: "GoPay & ShopeePay",
                            trailingText: "E-Wallet",
                            onTap: () => _showWalletDetailSheet(
                              context: context,
                              name: "GoPay & ShopeePay",
                              accountNo: "•••• 0812",
                              role: "E-Wallet Transaksi Harian",
                              balance: "Rp 1.450.000",
                              color: const Color(0xFF34C759),
                              icon: CupertinoIcons.money_dollar_circle_fill,
                            ),
                            textColor: textColor,
                            secondaryTextColor: secondaryTextColor,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 22)),

              // ── 4. SECTION: KEAMANAN & SISTEM ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    "KEAMANAN & SISTEM",
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
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: _buildGroupedCardDecoration(isDark),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Column(
                        children: [
                          _buildAppleSettingRow(
                            icon: CupertinoIcons.speedometer,
                            iconColor: const Color(0xFFFF9500),
                            title: "Layar & ProMotion",
                            trailingText: "144Hz Adaptive",
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _openSettingsSheet();
                            },
                            textColor: textColor,
                            secondaryTextColor: secondaryTextColor,
                            isDark: isDark,
                          ),
                          _buildDivider(isDark),
                          _buildAppleSettingRow(
                            icon: isDark
                                ? CupertinoIcons.moon_stars_fill
                                : CupertinoIcons.sun_max_fill,
                            iconColor: isDark
                                ? const Color(0xFF5856D6)
                                : const Color(0xFFFF9E00),
                            title: "Tema Tampilan",
                            trailingText: isDark ? "Obsidian Gelap" : "Clean Terang",
                            onTap: () {
                              HapticFeedback.selectionClick();
                              widget.onToggleTheme();
                            },
                            textColor: textColor,
                            secondaryTextColor: secondaryTextColor,
                            isDark: isDark,
                          ),
                          _buildDivider(isDark),
                          if (widget.onOpenAutoNotif != null) ...[
                            _buildAppleSettingRow(
                              icon: CupertinoIcons.bell_fill,
                              iconColor: const Color(0xFF007AFF),
                              title: "Auto-Detect Notifikasi",
                              trailingText: "Aktif",
                              onTap: widget.onOpenAutoNotif,
                              textColor: textColor,
                              secondaryTextColor: secondaryTextColor,
                              isDark: isDark,
                            ),
                            _buildDivider(isDark),
                          ],
                          _buildAppleSettingRow(
                            icon: CupertinoIcons.lock_shield_fill,
                            iconColor: const Color(0xFF34C759),
                            title: "Kunci Biometrik / PIN",
                            trailingText: "Aktif",
                            onTap: () => _showBiometricSecuritySheet(context),
                            textColor: textColor,
                            secondaryTextColor: secondaryTextColor,
                            isDark: isDark,
                          ),
                          _buildDivider(isDark),
                          _buildAppleSettingRow(
                            icon: CupertinoIcons.cloud_download_fill,
                            iconColor: const Color(0xFF5856D6),
                            title: "Ekspor & Cadangkan Data",
                            trailingText: "CSV / PDF",
                            onTap: () => _showExportDataSheet(context),
                            textColor: textColor,
                            secondaryTextColor: secondaryTextColor,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 22)),

              // ── 5. SECTION: OPTIMASI SISTEM & BACKGROUND ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        "OPTIMASI SISTEM & BACKGROUND",
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildMicroBadge("ANTI-MATI", const Color(0xFF007AFF), isDark),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: _buildGroupedCardDecoration(isDark),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Column(
                        children: [
                          _buildAppleSettingRow(
                            icon: CupertinoIcons.bell_circle_fill,
                            iconColor: const Color(0xFF007AFF),
                            title: "Akses Notifikasi Transaksi",
                            trailingBadge: _buildMicroBadge("TERHUBUNG", const Color(0xFF34C759), isDark),
                            onTap: () => _showNotificationPermissionSheet(context),
                            textColor: textColor,
                            secondaryTextColor: secondaryTextColor,
                            isDark: isDark,
                          ),
                          _buildDivider(isDark),
                          _buildAppleSettingRow(
                            icon: CupertinoIcons.battery_charging,
                            iconColor: const Color(0xFFFF9500),
                            title: "Bypass Penghemat Daya",
                            trailingBadge: _buildMicroBadge("OPTIMAL", const Color(0xFFFF9500), isDark),
                            onTap: () => _showBatteryOptimizationSheet(context),
                            textColor: textColor,
                            secondaryTextColor: secondaryTextColor,
                            isDark: isDark,
                          ),
                          _buildDivider(isDark),
                          _buildAppleSettingRow(
                            icon: CupertinoIcons.device_phone_portrait,
                            iconColor: const Color(0xFF34C759),
                            title: "Izin Mulai Otomatis per Merk",
                            trailingBadge: _buildMicroBadge("PANDUAN", const Color(0xFF007AFF), isDark),
                            onTap: () => _showAutoStartBrandGuideSheet(context),
                            textColor: textColor,
                            secondaryTextColor: secondaryTextColor,
                            isDark: isDark,
                          ),
                          _buildDivider(isDark),
                          _buildAppleSettingRow(
                            icon: CupertinoIcons.chevron_left_slash_chevron_right,
                            iconColor: const Color(0xFFAF52DE),
                            title: "Panduan Pasang di HP Asli",
                            trailingBadge: _buildMicroBadge("DEPLOY", const Color(0xFFAF52DE), isDark),
                            onTap: () => _showDeployGuideSheet(context),
                            textColor: textColor,
                            secondaryTextColor: secondaryTextColor,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // App Footer Info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          "Saku v2.0 • Liquid Glass Edition",
                          style: TextStyle(
                            color: secondaryTextColor.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "ProMotion Dynamic Pacer • On-Device Engine",
                          style: TextStyle(
                            color: secondaryTextColor.withValues(alpha: 0.6),
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Clearance Spacer for Floating Dock
              const SliverToBoxAdapter(child: SizedBox(height: 140)),
          ],
        ),

        // ── DYNAMIC NOTCH / TOP STATUS VIGNETTE (PROGRESSIVE GRADASI BLUR & WARNA ALA APPLE IOS) ──
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
            color: isDark
                ? Colors.black.withValues(alpha: 0.50)
                : Colors.white.withValues(alpha: 0.42),
          ),
        ),
      ],
    ),
  );
}

  void _openSettingsSheet() {
    final bool isDark = widget.isDark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF64748B);

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
                          ? const Color(0xFF2C2C2E)
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

  // ── MODAL SHEET: PROFIL & AKUN (APPLE ID STYLE) ──
  void _showProfileAccountSheet(BuildContext context) {
    HapticFeedback.selectionClick();
    final bool isDark = widget.isDark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 36),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF141416).withValues(alpha: 0.94)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white,
                  width: 1.2,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                const SizedBox(height: 20),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: isDark ? 0.30 : 0.70),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF007AFF).withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "DW",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Deni Wahyudi",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "deni.wahyudi@icloud.com • Saku ID",
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        icon: CupertinoIcons.shield_fill,
                        iconColor: const Color(0xFF34C759),
                        label: "Status Vault",
                        value: "Terenkripsi AES-256",
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                      Divider(
                        height: 16,
                        thickness: 0.5,
                        color: isDark ? Colors.white10 : Colors.black12,
                      ),
                      _buildInfoRow(
                        icon: CupertinoIcons.device_phone_portrait,
                        iconColor: const Color(0xFF007AFF),
                        label: "Penyimpanan",
                        value: "100% On-Device",
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                      Divider(
                        height: 16,
                        thickness: 0.5,
                        color: isDark ? Colors.white10 : Colors.black12,
                      ),
                      _buildInfoRow(
                        icon: CupertinoIcons.star_fill,
                        iconColor: const Color(0xFFFF9500),
                        label: "Tingkat Akun",
                        value: "Founder Edition",
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                BouncyTouchWrapper(
                  scaleFactor: 0.96,
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : const Color(0xFF007AFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        "Selesai",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
    );
  }

  // ── MODAL SHEET: DETAIL REKENING & E-WALLET ──
  void _showWalletDetailSheet({
    required BuildContext context,
    required String name,
    required String accountNo,
    required String role,
    required String balance,
    required Color color,
    required IconData icon,
  }) {
    HapticFeedback.selectionClick();
    final bool isDark = widget.isDark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 36),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF141416).withValues(alpha: 0.94)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white,
                  width: 1.2,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color,
                        color.withValues(alpha: 0.75),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(icon, color: Colors.white, size: 28),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              role.split("•").first.trim(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        balance,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            accountNo,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildModalActionRow(
                        icon: CupertinoIcons.doc_on_clipboard,
                        iconColor: color,
                        title: "Salin Nomor Rekening",
                        textColor: textColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Clipboard.setData(ClipboardData(text: accountNo));
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Nomor rekening $name disalin!"),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        color: isDark ? Colors.white10 : Colors.black12,
                        indent: 48,
                      ),
                      _buildModalActionRow(
                        icon: CupertinoIcons.arrow_2_circlepath,
                        iconColor: const Color(0xFF34C759),
                        title: "Sinkronkan Ulang Saldo",
                        textColor: textColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Saldo $name tersinkronkan!"),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                BouncyTouchWrapper(
                  scaleFactor: 0.96,
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : const Color(0xFFE5E5EA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        "Tutup",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
    );
  }

  // ── MODAL SHEET: KEAMANAN & BIOMETRIK ──
  void _showBiometricSecuritySheet(BuildContext context) {
    HapticFeedback.selectionClick();
    final bool isDark = widget.isDark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF64748B);

    bool biometricActive = true;
    bool hideBalanceActive = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 36),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF141416).withValues(alpha: 0.94)
                    : Colors.white.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white,
                    width: 1.2,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  const SizedBox(height: 18),
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF34C759).withValues(alpha: 0.16),
                      border: Border.all(
                        color: const Color(0xFF34C759).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      CupertinoIcons.lock_shield_fill,
                      color: Color(0xFF34C759),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Keamanan & Biometrik",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Lindungi akses keuangan dengan Face ID / Sidik Jari",
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Kunci Biometrik App",
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Verifikasi saat membuka Saku",
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              CupertinoSwitch(
                                value: biometricActive,
                                activeTrackColor: const Color(0xFF34C759),
                                onChanged: (val) {
                                  HapticFeedback.selectionClick();
                                  setSheetState(() => biometricActive = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: isDark ? Colors.white10 : Colors.black12,
                          indent: 14,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Samarkan Saldo",
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Sensor angka di layar beranda",
                                    style: TextStyle(
                                      color: secondaryTextColor,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              CupertinoSwitch(
                                value: hideBalanceActive,
                                activeTrackColor: const Color(0xFF34C759),
                                onChanged: (val) {
                                  HapticFeedback.selectionClick();
                                  setSheetState(() => hideBalanceActive = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  BouncyTouchWrapper(
                    scaleFactor: 0.96,
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF34C759),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          "Simpan Pengaturan",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
  }

  // ── MODAL SHEET: EKSPOR & CADANGKAN DATA ──
  void _showExportDataSheet(BuildContext context) {
    HapticFeedback.selectionClick();
    final bool isDark = widget.isDark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 36),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF141416).withValues(alpha: 0.94)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white,
                  width: 1.2,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                const SizedBox(height: 18),
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF5856D6).withValues(alpha: 0.16),
                    border: Border.all(
                      color: const Color(0xFF5856D6).withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    CupertinoIcons.cloud_download_fill,
                    color: Color(0xFF5856D6),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Ekspor & Cadangan Data",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Data kamu tersimpan aman secara offline",
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildModalActionRow(
                        icon: CupertinoIcons.table_badge_more,
                        iconColor: const Color(0xFF34C759),
                        title: "Ekspor ke CSV (Spreadsheet)",
                        subtitle: "Kompatibel dengan Microsoft Excel & Google Sheets",
                        textColor: textColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Data transaksi berhasil diekspor ke format CSV!"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        color: isDark ? Colors.white10 : Colors.black12,
                        indent: 48,
                      ),
                      _buildModalActionRow(
                        icon: CupertinoIcons.doc_text_fill,
                        iconColor: const Color(0xFFFF9500),
                        title: "Ekspor Ringkasan Laporan (PDF)",
                        subtitle: "Laporan rapi siap cetak atau dibagikan",
                        textColor: textColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Laporan PDF berhasil dibuat!"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        color: isDark ? Colors.white10 : Colors.black12,
                        indent: 48,
                      ),
                      _buildModalActionRow(
                        icon: CupertinoIcons.lock_shield_fill,
                        iconColor: const Color(0xFF007AFF),
                        title: "Cadangkan Brankas Saku (.saku)",
                        subtitle: "Backup terenkripsi AES-256 untuk pemulihan perangkat",
                        textColor: textColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Brankas Saku berhasil dicadangkan dengan enkripsi!"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                BouncyTouchWrapper(
                  scaleFactor: 0.96,
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : const Color(0xFFE5E5EA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        "Batal",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: secondaryTextColor,
            fontSize: 13.5,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildModalActionRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return BouncyTouchWrapper(
      scaleFactor: 0.98,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_forward,
              color: Color(0xFF8E8E93),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppleSettingRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    String? trailingText,
    Color? trailingTextColor,
    Widget? trailingBadge,
    VoidCallback? onTap,
    required Color textColor,
    required Color secondaryTextColor,
    required bool isDark,
    bool showChevron = true,
  }) {
    return BouncyTouchWrapper(
      scaleFactor: 0.98,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            // Apple Jewel Squircle
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.18 : 0.10),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: iconColor.withValues(alpha: isDark ? 0.28 : 0.16),
                  width: 0.8,
                ),
              ),
              child: Icon(icon, color: iconColor, size: 16.5),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                  if (subtitle != null) ...[
                    const SizedBox(height: 1.5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailingBadge != null) ...[
              trailingBadge,
              const SizedBox(width: 6),
            ] else if (trailingText != null) ...[
              Text(
                trailingText,
                style: TextStyle(
                  color: trailingTextColor ?? secondaryTextColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.1,
                ),
              ),
              const SizedBox(width: 4),
            ],
            if (showChevron)
              Icon(
                CupertinoIcons.chevron_forward,
                color: secondaryTextColor.withValues(alpha: isDark ? 0.45 : 0.35),
                size: 14,
              ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildGroupedCardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF1C1C1E).withValues(alpha: 0.85)
          : Colors.white.withValues(alpha: 0.88),
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
    );
  }

  Widget _buildMicroBadge(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.09),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.28 : 0.15),
          width: 0.6,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 58, right: 14),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFF3C3C43).withValues(alpha: 0.12),
      ),
    );
  }

  // ── MODAL SHEET PANDUAN & OPTIMASI HP ASLI ──

  void _showNotificationPermissionSheet(BuildContext context) {
    HapticFeedback.selectionClick();
    final bool isDark = widget.isDark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.72,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0A0F1D) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(CupertinoIcons.bell_circle_fill,
                      color: Color(0xFF007AFF), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "1. Izin Akses Notifikasi",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "Membaca SMS Bank & Notifikasi E-Wallet",
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF007AFF).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF007AFF).withValues(alpha: 0.25),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        "Android memproteksi notifikasi finansial pengguna. SakuAman memproses 100% notifikasi secara on-device (tanpa internet) sehingga data saldo dan rekening Anda aman di HP.",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12.5,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "LANGKAH MENGAKTIFKAN:",
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildStepRow("1", "Tekan tombol biru 'Buka Pengaturan Android' di bawah.", textColor, secondaryTextColor),
                    _buildStepRow("2", "HP akan membuka menu 'Akses Notifikasi' sistem Android.", textColor, secondaryTextColor),
                    _buildStepRow("3", "Cari aplikasi 'Finances' atau 'SakuAman', lalu aktifkan tombol Izinkan (Allow).", textColor, secondaryTextColor),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            BouncyTouchWrapper(
              onTap: () {
                HapticFeedback.mediumImpact();
                NativeNotificationService().initialize(onTransactionDetected: (_) {});
                Navigator.pop(ctx);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF007AFF), Color(0xFF0056B3)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF007AFF).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.gear_alt_fill, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        "Buka Pengaturan Android Sekarang",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
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
    );
  }

  void _showBatteryOptimizationSheet(BuildContext context) {
    HapticFeedback.selectionClick();
    final bool isDark = widget.isDark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.72,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0A0F1D) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9500).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(CupertinoIcons.battery_charging,
                      color: Color(0xFFFF9500), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "2. Anti-Mati Latar Belakang",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "Bebaskan dari Penghemat Baterai Android",
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9500).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFF9500).withValues(alpha: 0.25),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        "Android sering membunuh aplikasi yang berjalan di background setelah 15 menit layar mati. Agar transaksi m-banking tetap tercatat saat HP di saku, ubah opsi baterai menjadi 'Tidak Ada Batasan'.",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12.5,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "PANDUAN LANGKAH (1 MENIT):",
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildStepRow("1", "Buka Pengaturan HP -> Aplikasi -> Kelola Aplikasi.", textColor, secondaryTextColor),
                    _buildStepRow("2", "Cari aplikasi 'Finances' (atau SakuAman).", textColor, secondaryTextColor),
                    _buildStepRow("3", "Pilih menu 'Penggunaan Baterai' / 'Penghemat Baterai'.", textColor, secondaryTextColor),
                    _buildStepRow("4", "Ubah dari 'Dioptimalkan' ke 'Tidak Ada Batasan' (No Restrictions).", textColor, secondaryTextColor),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            BouncyTouchWrapper(
              onTap: () {
                HapticFeedback.mediumImpact();
                Clipboard.setData(const ClipboardData(text: "Finances"));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Nama aplikasi 'Finances' disalin ke clipboard!"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9500), Color(0xFFE08500)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF9500).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.doc_on_clipboard_fill, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        "Salin Nama Aplikasi untuk Dicari di HP",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
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
    );
  }

  void _showAutoStartBrandGuideSheet(BuildContext context) {
    HapticFeedback.selectionClick();
    final bool isDark = widget.isDark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.78,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0A0F1D) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34C759).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(CupertinoIcons.device_phone_portrait,
                      color: Color(0xFF34C759), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "3. Izin Mulai Otomatis (Auto-Start)",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "Panduan Khusus Sesuai Merk HP Anda",
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildBrandCard(
                      brand: "Xiaomi / POCO / Redmi (MIUI & HyperOS)",
                      steps: [
                        "Buka Info Aplikasi 'Finances' -> Aktifkan toggle 'Mulai Otomatis' (Autostart).",
                        "Di Penghemat Baterai: Pilih 'Tidak Ada Pembatasan'.",
                        "Di Layar Multitasking (Recent Apps): Tekan lama kartu Finances -> Klik icon 'Gembok' agar tidak terhapus saat bersihkan RAM.",
                      ],
                      isDark: isDark,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    const SizedBox(height: 10),
                    _buildBrandCard(
                      brand: "Samsung Galaxy (One UI)",
                      steps: [
                        "Buka Pengaturan -> Perawatan Perangkat -> Baterai.",
                        "Pilih 'Batas Penggunaan Latar Belakang'.",
                        "Masukkan 'Finances' ke daftar 'Aplikasi yang tidak pernah tidur' (Never sleeping apps).",
                      ],
                      isDark: isDark,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    const SizedBox(height: 10),
                    _buildBrandCard(
                      brand: "Oppo & Realme (ColorOS / Realme UI)",
                      steps: [
                        "Buka Manajemen Aplikasi -> Finances -> Penggunaan Baterai.",
                        "Aktifkan 'Izinkan Aktivitas Latar Belakang' dan 'Izinkan Mulai Otomatis'.",
                      ],
                      isDark: isDark,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    const SizedBox(height: 10),
                    _buildBrandCard(
                      brand: "Vivo & iQOO (Funtouch OS)",
                      steps: [
                        "Buka Pengaturan -> Baterai -> Konsumsi Daya Latar Belakang Tinggi.",
                        "Cari Finances dan berikan izin aktif penuh.",
                        "Di Pengelola Izin, aktifkan 'Mulai Otomatis'.",
                      ],
                      isDark: isDark,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeployGuideSheet(BuildContext context) {
    HapticFeedback.selectionClick();
    final bool isDark = widget.isDark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.78,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0A0F1D) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFAF52DE).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(CupertinoIcons.chevron_left_slash_chevron_right,
                      color: Color(0xFFAF52DE), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "4. Jalankan di HP Asli (USB / APK)",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "Panduan Deploy untuk Developer & Pengguna",
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cara A: USB Debugging
                    Text(
                      "OPSI A: COLOK KABEL USB (LANGSUNG DARI LAPTOP)",
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStepRow("1", "Di HP: Buka Pengaturan -> Tentang Ponsel -> Ketuk 'Nomor Versi' (Build Number) 7 kali.", textColor, secondaryTextColor),
                          _buildStepRow("2", "Masuk ke 'Opsi Pengembang' -> Aktifkan 'USB Debugging'.", textColor, secondaryTextColor),
                          _buildStepRow("3", "Colok kabel data dari HP ke Laptop.", textColor, secondaryTextColor),
                          _buildStepRow("4", "Ketik perintah ini di terminal laptop:", textColor, secondaryTextColor),
                          const SizedBox(height: 6),
                          _buildCommandBox("flutter run -d android", context),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Cara B: Install APK Siap Pakai
                    Text(
                      "OPSI B: BUAT FILE APK (PASANG DI HP TANPA KABEL)",
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStepRow("1", "Di terminal laptop, buat file APK mandiri:", textColor, secondaryTextColor),
                          const SizedBox(height: 6),
                          _buildCommandBox("flutter build apk --debug", context),
                          const SizedBox(height: 10),
                          _buildStepRow("2", "File APK langsung tersedia di lokasi ini:", textColor, secondaryTextColor),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF34C759).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "build/app/outputs/flutter-apk/app-debug.apk",
                              style: TextStyle(
                                color: Color(0xFF34C759),
                                fontSize: 11.5,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildStepRow("3", "Kirim file app-debug.apk ke HP via WhatsApp/Drive lalu buka untuk meng-install!", textColor, secondaryTextColor),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow(String number, String text, Color textColor, Color secondaryTextColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Color(0xFF007AFF),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandCard({
    required String brand,
    required List<String> steps,
    required bool isDark,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            brand,
            style: const TextStyle(
              color: Color(0xFF34C759),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < steps.length; i++)
            _buildStepRow("${i + 1}", steps[i], textColor, secondaryTextColor),
        ],
      ),
    );
  }

  Widget _buildCommandBox(String command, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              command,
              style: const TextStyle(
                color: Color(0xFF00F5D4),
                fontSize: 12,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        BouncyTouchWrapper(
          onTap: () {
            HapticFeedback.lightImpact();
            Clipboard.setData(ClipboardData(text: command));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Perintah '$command' disalin!"),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(CupertinoIcons.doc_on_clipboard,
                color: Color(0xFF007AFF), size: 16),
          ),
        ),
      ],
    );
  }
}
