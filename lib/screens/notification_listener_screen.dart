import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import '../models/transaction.dart';
import '../services/notification_parser.dart';
import '../widgets/bouncy_touch_wrapper.dart';
import '../widgets/ambient_mesh_background.dart';
import '../theme/saku_theme.dart';

class NotificationListenerScreen extends StatefulWidget {
  final Function(TransactionModel) onTransactionDetected;
  final bool isDark;

  const NotificationListenerScreen({
    super.key,
    required this.onTransactionDetected,
    required this.isDark,
  });

  @override
  State<NotificationListenerScreen> createState() =>
      _NotificationListenerScreenState();
}

class _NotificationListenerScreenState extends State<NotificationListenerScreen> {
  bool _isServiceEnabled = true;
  bool _isInteractingTopBar = false;
  final TextEditingController _customNotifController = TextEditingController();

  // Dynamic Floating Glass Toast state
  TransactionModel? _detectedToast;
  String? _toastError;
  Timer? _toastTimer;

  // Preset Notifikasi Nyata Bank & E-Wallet Indonesia dengan Identitas Brand Asli
  final List<Map<String, dynamic>> _samplePresets = [
    {
      "source": "BCA Mobile",
      "title": "Transaksi QRIS Berhasil",
      "body": "Pembayaran QRIS di KOPI KENANGAN sebesar Rp 28.000 berhasil.",
      "merchant": "Kopi Kenangan",
      "amountFormatted": "- Rp 28.000",
      "tag": "QRIS",
      "time": "Baru saja",
      "icon": CupertinoIcons.creditcard_fill,
      "brandColor": const Color(0xFF005BAC),
      "isIncome": false,
    },
    {
      "source": "GoPay",
      "title": "Pembayaran Berhasil",
      "body": "Kamu telah membayar Rp 18.500 ke GoRide.",
      "merchant": "GoRide Transport",
      "amountFormatted": "- Rp 18.500",
      "tag": "E-Wallet",
      "time": "15 mnt lalu",
      "icon": CupertinoIcons.bolt_fill,
      "brandColor": const Color(0xFF00AED6),
      "isIncome": false,
    },
    {
      "source": "Livin by Mandiri",
      "title": "Transfer Masuk",
      "body": "Dana Rp 3.500.000 dari PT SOLUSI DIGITAL telah masuk ke rekeningmu.",
      "merchant": "Transfer PT Solusi Digital",
      "amountFormatted": "+ Rp 3.500.000",
      "tag": "Gaji / Transfer",
      "time": "45 mnt lalu",
      "icon": CupertinoIcons.arrow_down_left_circle_fill,
      "brandColor": const Color(0xFFFFB700),
      "isIncome": true,
    },
    {
      "source": "DANA",
      "title": "Transaksi Sukses",
      "body": "Pembayaran sebesar Rp 64.000 di ALFAMART berhasil.",
      "merchant": "Alfamart Belanja",
      "amountFormatted": "- Rp 64.000",
      "tag": "Minimarket",
      "time": "2 jam lalu",
      "icon": CupertinoIcons.qrcode_viewfinder,
      "brandColor": const Color(0xFF118EEA),
      "isIncome": false,
    },
    {
      "source": "ShopeePay",
      "title": "SPay Berhasil",
      "body": "Pembayaran SPay di INDOMARET sebesar Rp 45.000 sukses.",
      "merchant": "Indomaret Belanja",
      "amountFormatted": "- Rp 45.000",
      "tag": "SPay",
      "time": "Kemarin",
      "icon": CupertinoIcons.bag_fill,
      "brandColor": const Color(0xFFEE4D2D),
      "isIncome": false,
    },
    {
      "source": "BRImo",
      "title": "QRIS BRImo",
      "body": "Pembayaran QRIS Rp 120.000 di SPBU PERTAMINA berhasil diproses.",
      "merchant": "SPBU Pertamina",
      "amountFormatted": "- Rp 120.000",
      "tag": "BBM",
      "time": "Kemarin",
      "icon": CupertinoIcons.building_2_fill,
      "brandColor": const Color(0xFF00529C),
      "isIncome": false,
    },
  ];

  @override
  void dispose() {
    _toastTimer?.cancel();
    _customNotifController.dispose();
    super.dispose();
  }

  void _triggerSuccessToast(TransactionModel tx) {
    HapticFeedback.mediumImpact();
    _toastTimer?.cancel();
    setState(() {
      _detectedToast = tx;
      _toastError = null;
    });
    _toastTimer = Timer(const Duration(milliseconds: 3200), () {
      if (mounted) {
        setState(() {
          _detectedToast = null;
        });
      }
    });
  }

  void _triggerErrorToast(String message) {
    HapticFeedback.heavyImpact();
    _toastTimer?.cancel();
    setState(() {
      _toastError = message;
      _detectedToast = null;
    });
    _toastTimer = Timer(const Duration(milliseconds: 3200), () {
      if (mounted) {
        setState(() {
          _toastError = null;
        });
      }
    });
  }

  void _testPreset(Map<String, dynamic> preset) {
    if (!_isServiceEnabled) {
      _triggerErrorToast("Aktifkan Listener terlebih dahulu untuk membaca notifikasi.");
      return;
    }

    final result = NotificationParserEngine.parseNotification(
      appOrSender: preset["source"] as String,
      title: preset["title"] as String,
      body: preset["body"] as String,
    );

    if (result != null) {
      final tx = result.toTransaction();
      widget.onTransactionDetected(tx);
      _triggerSuccessToast(tx);
    }
  }

  void _testCustomInput() {
    final text = _customNotifController.text.trim();
    if (text.isEmpty) {
      _triggerErrorToast("Teks notifikasi masih kosong.");
      return;
    }

    if (!_isServiceEnabled) {
      _triggerErrorToast("Aktifkan Listener terlebih dahulu.");
      return;
    }

    final result = NotificationParserEngine.parseNotification(
      appOrSender: "Manual Simulator",
      title: "Notifikasi Uji Coba",
      body: text,
    );

    if (result != null) {
      final tx = result.toTransaction();
      widget.onTransactionDetected(tx);
      _customNotifController.clear();
      _triggerSuccessToast(tx);
    } else {
      _triggerErrorToast("Format tidak terbaca! Pastikan ada nominal (e.g. 'Rp 50.000') dan merchant.");
    }
  }

  Future<void> _pasteFromClipboard() async {
    HapticFeedback.selectionClick();
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null && data.text!.isNotEmpty) {
      setState(() {
        _customNotifController.text = data.text!;
      });
    } else {
      _triggerErrorToast("Papan klip (clipboard) Anda kosong.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double topIslandPadding = statusBarHeight > 0 ? statusBarHeight + 6 : 8.0;

    // Formula Kaca Kristal Standar iOS
    final pillGlassStyle = LiquidGlassStyle(
      shape: const LiquidGlassShape.continuousRoundedRectangle(
        cornerRadius: 18,
      ),
      color: isDark
          ? const Color(0xFF0F1626).withValues(alpha: 0.75)
          : Colors.white.withValues(alpha: 0.85),
      blur: 20.0,
      refractionIndex: 1.15,
      refractionWidth: 10.0,
      magnification: 1.0,
      dispersion: 0.2,
      specular: LiquidGlassLight.specular(
        thickness: 3.0,
        intensity: isDark ? 1.10 : 1.15,
      ),
      glow: LiquidGlassLight.glow(
        thickness: 5.0,
        intensity: isDark ? 0.15 : 0.20,
        color: const Color(0xFF007AFF),
      ),
      shadow: LiquidGlassShadow(
        blur: 12,
        opacity: isDark ? 0.25 : 0.08,
        color: Colors.black,
        offset: const Offset(0, 4),
      ),
    );

    const jellyTouch = LiquidGlassTouch(
      flex: LiquidGlassFlex(
        stretch: 9,
        squeeze: 0.35,
        lean: 0.22,
        grip: 0.55,
        compressInward: true,
        holdScale: 0.02,
        tapScale: 0.018,
        maxPull: 22,
        advanced: LiquidGlassFlexAdvanced(
          childFollow: 0.45,
          refractionBoost: 0.12,
          stiffness: 320,
          damping: 22,
          releaseDamping: 18,
        ),
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Theme(
        data: SakuTheme.getTheme(isDark: isDark),
        child: AmbientMeshBackground(
          isDark: isDark,
          child: Stack(
            fit: StackFit.expand,
            children: [
          // ── KONTEN SCROLLABLE DI BAWAH KACA (FLOWS UNDERNEATH PINNED TOP BAR) ──
          CustomScrollView(
            physics: _isInteractingTopBar
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            slivers: [
              // Spacer di bawah floating islands
              SliverToBoxAdapter(
                child: SizedBox(height: topIslandPadding + 46),
              ),

              // ── 1. LARGE TITLE "Auto-Catat Notif HP" & SUBTITLE ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Auto-Catat Notif HP",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Deteksi Otomatis Transaksi Bank & E-Wallet",
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

              // ── 2. HERO LIVE STATUS & LISTENER RADAR CARD ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: _buildHeroListenerCard(isDark, textColor, secondaryTextColor),
                ),
              ),

              // ── 3. SUPPORTED CHANNELS RIBBON (BANK & E-WALLET LOGOS) ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Bank & E-Wallet Terhubung",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        "6 Saluran Aktif",
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildBankChip("BCA Mobile", const Color(0xFF005BAC), isDark),
                      _buildBankChip("Livin Mandiri", const Color(0xFFFFB700), isDark),
                      _buildBankChip("GoPay", const Color(0xFF00AED6), isDark),
                      _buildBankChip("DANA", const Color(0xFF118EEA), isDark),
                      _buildBankChip("ShopeePay", const Color(0xFFEE4D2D), isDark),
                      _buildBankChip("BRImo", const Color(0xFF00529C), isDark),
                    ],
                  ),
                ),
              ),

              // ── 4. SIMULATOR PRESET LIST (GROUPED INSET GLASS CONTAINER) ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text(
                    "Simulasi Notifikasi Masuk",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: _buildGroupedPresetsCard(isDark, textColor, secondaryTextColor),
                ),
              ),

              // ── 5. MANUAL NOTIFICATION TESTER (GROUPED INSET CONTAINER) ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text(
                    "Uji Teks Notifikasi Kustom",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: _buildCustomTesterCard(isDark, textColor, secondaryTextColor),
                ),
              ),

              // ── 6. 100% ON-DEVICE PRIVACY GUARANTEE FOOTER ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 130),
                  child: _buildPrivacyCard(isDark, textColor, secondaryTextColor),
                ),
              ),
            ],
          ),

          // ── FLOATING TOP STATUS VIGNETTE (PROGRESSIVE BLUR ALA APPLE IOS) ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: (statusBarHeight > 0 ? statusBarHeight : 44) + 84,
            child: LiquidGlassScrollEdge(
              edge: LiquidGlassEdge.top,
              style: LiquidGlassScrollEdgeStyle.soft,
              blur: 12,
              blurCurve: Curves.easeInQuart,
              curve: Curves.easeOutCubic,
              color: isDark
                  ? const Color(0xFF090C15).withValues(alpha: 0.40)
                  : Colors.white.withValues(alpha: 0.45),
            ),
          ),

          // ── PINNED FLOATING LIQUID ISLANDS (TOP CONTROLS) ──
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
                      // Pojok Kiri Atas: Floating Liquid Pill [ < Kembali ]
                      Positioned(
                        left: 0,
                        top: 0,
                        width: 112,
                        height: 38,
                        child: LiquidGlassLens(
                          style: pillGlassStyle,
                          touch: jellyTouch,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              Navigator.of(context).pop();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        CupertinoIcons.chevron_left,
                                        color: Color(0xFF007AFF),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Kembali",
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 13.5,
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
                      ),

                      // Pojok Kanan Atas: Interactive Toggle Badge [ 🟢 Siaga / ⚪ Jeda ]
                      Positioned(
                        right: 0,
                        top: 0,
                        width: 126,
                        height: 38,
                        child: LiquidGlassLens(
                          style: pillGlassStyle,
                          touch: jellyTouch,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _isServiceEnabled = !_isServiceEnabled;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                          color: _isServiceEnabled
                                              ? const Color(0xFF34C759)
                                              : const Color(0xFF8E8E93),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            if (_isServiceEnabled)
                                              BoxShadow(
                                                color: const Color(0xFF34C759)
                                                    .withValues(alpha: 0.6),
                                                blurRadius: 6,
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _isServiceEnabled ? "Siaga Aktif" : "Dijeda",
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 12,
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── FLOATING LIQUID GLASS DYNAMIC ISLAND TOAST (INTERACTIVE INSTANT FEEDBACK) ──
          if (_detectedToast != null || _toastError != null)
            Positioned(
              top: topIslandPadding + 46,
              left: 20,
              right: 20,
              child: _buildDynamicToast(isDark, textColor),
            ),
            ],
          ),
        ),
      ),
    );
  }

  // ── WIDGET: HERO LISTENER RADAR CARD ──
  Widget _buildHeroListenerCard(
      bool isDark, Color textColor, Color secondaryTextColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0F1626).withValues(alpha: 0.70)
                : Colors.white.withValues(alpha: 0.80),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.75),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.35)
                    : const Color(0xFF0F172A).withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Glowing Radar Beacon Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (_isServiceEnabled
                              ? const Color(0xFF34C759)
                              : const Color(0xFF8E8E93))
                          .withValues(alpha: isDark ? 0.18 : 0.12),
                      border: Border.all(
                        color: (_isServiceEnabled
                                ? const Color(0xFF34C759)
                                : const Color(0xFF8E8E93))
                            .withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _isServiceEnabled
                            ? CupertinoIcons.bell_fill
                            : CupertinoIcons.bell_slash_fill,
                        color: _isServiceEnabled
                            ? const Color(0xFF34C759)
                            : const Color(0xFF8E8E93),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Listener Notifikasi",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _isServiceEnabled
                              ? "Siaga • Membaca BCA, Mandiri, GoPay dll"
                              : "Layanan Nonaktif",
                          style: TextStyle(
                            color: _isServiceEnabled
                                ? const Color(0xFF34C759)
                                : secondaryTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoSwitch(
                    value: _isServiceEnabled,
                    activeTrackColor: const Color(0xFF34C759),
                    onChanged: (val) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _isServiceEnabled = val;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(
                height: 0.5,
                thickness: 0.5,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : const Color(0xFF0F172A).withValues(alpha: 0.08),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMiniBadge(
                    icon: CupertinoIcons.sparkles,
                    label: "On-Device AI",
                    color: secondaryTextColor,
                    textColor: textColor,
                  ),
                  _buildMiniBadge(
                    icon: CupertinoIcons.lock_shield_fill,
                    label: "100% Privat",
                    color: secondaryTextColor,
                    textColor: textColor,
                  ),
                  _buildMiniBadge(
                    icon: CupertinoIcons.checkmark_seal_fill,
                    label: "Bebas Biaya",
                    color: secondaryTextColor,
                    textColor: textColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBadge({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: textColor.withValues(alpha: 0.85),
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── WIDGET: BANK CHIP RIBBON ──
  Widget _buildBankChip(String name, Color brandColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F1626).withValues(alpha: 0.60)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
          width: 0.8,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: brandColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            name,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── WIDGET: GROUPED INSET PRESETS CONTAINER ──
  Widget _buildGroupedPresetsCard(
      bool isDark, Color textColor, Color secondaryTextColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0F1626).withValues(alpha: 0.65)
                : Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.70),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.35)
                    : const Color(0xFF0F172A).withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < _samplePresets.length; i++) ...[
                _buildPresetItem(
                  _samplePresets[i],
                  isDark,
                  textColor,
                  secondaryTextColor,
                ),
                if (i < _samplePresets.length - 1)
                  Divider(
                    height: 0.5,
                    thickness: 0.5,
                    indent: 62,
                    endIndent: 16,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFF0F172A).withValues(alpha: 0.06),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetItem(
    Map<String, dynamic> preset,
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
  ) {
    final brandColor = preset["brandColor"] as Color;
    final icon = preset["icon"] as IconData;
    final merchant = preset["merchant"] as String;
    final source = preset["source"] as String;
    final amountFormatted = preset["amountFormatted"] as String;
    final tag = preset["tag"] as String;
    final isIncome = preset["isIncome"] as bool;

    return BouncyTouchWrapper(
      scaleFactor: 0.98,
      onTap: () => _testPreset(preset),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Bank Brand Icon Container
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF192234)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : const Color(0xFFE2E8F0),
                  width: 0.8,
                ),
              ),
              child: Center(
                child: Icon(icon, color: brandColor, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            // Merchant & Source Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    merchant,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "$source • $tag • ${preset['time']}",
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Amount & Action Hint
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amountFormatted,
                  style: TextStyle(
                    color: isIncome
                        ? const Color(0xFF34C759)
                        : (isDark ? Colors.white : const Color(0xFF0F172A)),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Uji",
                      style: TextStyle(
                        color: secondaryTextColor.withValues(alpha: 0.75),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      CupertinoIcons.chevron_forward,
                      color: secondaryTextColor.withValues(alpha: 0.5),
                      size: 11,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── WIDGET: CUSTOM TESTER CARD ──
  Widget _buildCustomTesterCard(
      bool isDark, Color textColor, Color secondaryTextColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0F1626).withValues(alpha: 0.65)
                : Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.70),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.35)
                    : const Color(0xFF0F172A).withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Input Teks Notifikasi",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _pasteFromClipboard,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.doc_on_clipboard,
                            color: Color(0xFF007AFF),
                            size: 13,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Tempel",
                            style: TextStyle(
                              color: Color(0xFF007AFF),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                controller: _customNotifController,
                placeholder: "Contoh: Pembayaran QRIS di Starbucks Rp 55.000 sukses",
                placeholderStyle: TextStyle(
                  color: secondaryTextColor.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
                style: TextStyle(color: textColor, fontSize: 13),
                maxLines: 3,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.35)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : const Color(0xFFE2E8F0),
                    width: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              BouncyTouchWrapper(
                scaleFactor: 0.96,
                onTap: _testCustomInput,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF007AFF).withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.sparkles,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Jalankan Engine Parser",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
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
    );
  }

  // ── WIDGET: 100% ON-DEVICE PRIVACY CARD ──
  Widget _buildPrivacyCard(
      bool isDark, Color textColor, Color secondaryTextColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F1626).withValues(alpha: 0.50)
            : Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            CupertinoIcons.lock_shield_fill,
            color: secondaryTextColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "100% Keamanan & Privasi On-Device",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "SakuAman tidak membutuhkan akses login akun bank atau API perbankan pihak ketiga. Seluruh parsing notifikasi berjalan 100% offline di smartphone Anda tanpa transmisi data keluar.",
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── WIDGET: FLOATING DYNAMIC ISLAND TOAST BANNER ──
  Widget _buildDynamicToast(bool isDark, Color textColor) {
    final bool isError = _toastError != null;
    final tx = _detectedToast;

    return GestureDetector(
      onTap: () {
        setState(() {
          _detectedToast = null;
          _toastError = null;
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF090D16).withValues(alpha: 0.90)
                  : Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isError
                    ? const Color(0xFFFF3B30).withValues(alpha: 0.5)
                    : const Color(0xFF34C759).withValues(alpha: 0.5),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isError
                          ? const Color(0xFFFF3B30)
                          : const Color(0xFF34C759))
                      .withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isError
                            ? const Color(0xFFFF3B30)
                            : const Color(0xFF34C759))
                        .withValues(alpha: 0.15),
                  ),
                  child: Center(
                    child: Icon(
                      isError
                          ? CupertinoIcons.exclamationmark_circle_fill
                          : CupertinoIcons.checkmark_circle_fill,
                      color: isError
                          ? const Color(0xFFFF3B30)
                          : const Color(0xFF34C759),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isError
                            ? "Peringatan Parser"
                            : "⚡ Auto-Catat Berhasil!",
                        style: TextStyle(
                          color: isError
                              ? const Color(0xFFFF3B30)
                              : const Color(0xFF34C759),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        isError
                            ? _toastError!
                            : "${tx?.title ?? ''} • ${tx?.source ?? ''}",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!isError && tx != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    tx.formattedAmount,
                    style: TextStyle(
                      color: tx.type == TransactionType.income
                          ? const Color(0xFF34C759)
                          : (isDark ? Colors.white : const Color(0xFF0F172A)),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
