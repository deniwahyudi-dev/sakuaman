import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import '../models/transaction.dart';
import '../services/notification_parser.dart';
import '../widgets/glass_card.dart';
import '../widgets/bouncy_touch_wrapper.dart';

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
  String? _lastParsedStatus;

  // Preset Notifikasi Nyata Bank & E-Wallet Indonesia
  final List<Map<String, String>> _samplePresets = [
    {
      "source": "BCA Mobile",
      "title": "Transaksi QRIS Berhasil",
      "body": "Pembayaran QRIS di KOPI KENANGAN sebesar Rp 28.000 berhasil.",
    },
    {
      "source": "GoPay",
      "title": "Pembayaran Berhasil",
      "body": "Kamu telah membayar Rp 18.500 ke GoRide.",
    },
    {
      "source": "Livin by Mandiri",
      "title": "Transfer Masuk",
      "body": "Dana Rp 3.500.000 dari PT SOLUSI DIGITAL telah masuk ke rekeningmu.",
    },
    {
      "source": "DANA",
      "title": "Transaksi Sukses",
      "body": "Pembayaran sebesar Rp 64.000 di ALFAMART berhasil.",
    },
    {
      "source": "ShopeePay",
      "title": "SPay Berhasil",
      "body": "Pembayaran SPay di INDOMARET sebesar Rp 45.000 sukses.",
    },
    {
      "source": "BRImo",
      "title": "QRIS BRImo",
      "body": "Pembayaran QRIS Rp 120.000 di SPBU PERTAMINA berhasil diproses.",
    },
  ];

  @override
  void dispose() {
    _customNotifController.dispose();
    super.dispose();
  }

  void _testPreset(Map<String, String> preset) {
    final result = NotificationParserEngine.parseNotification(
      appOrSender: preset["source"]!,
      title: preset["title"]!,
      body: preset["body"]!,
    );

    if (result != null) {
      final tx = result.toTransaction();
      widget.onTransactionDetected(tx);

      setState(() {
        _lastParsedStatus =
            "Berhasil mencatat otomatis '${tx.title}' (${tx.formattedAmount}) dari ${tx.source}!";
      });

      _showSuccessPopup(tx);
    }
  }

  void _testCustomInput() {
    final text = _customNotifController.text.trim();
    if (text.isEmpty) return;

    final result = NotificationParserEngine.parseNotification(
      appOrSender: "Manual Simulator",
      title: "Notifikasi Uji Coba",
      body: text,
    );

    if (result != null) {
      final tx = result.toTransaction();
      widget.onTransactionDetected(tx);
      _customNotifController.clear();
      setState(() {
        _lastParsedStatus =
            "Berhasil membaca notifikasi kustom: '${tx.title}' (${tx.formattedAmount})";
      });
      _showSuccessPopup(tx);
    } else {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text("Format Tidak Terbaca"),
          content: const Text(
            "Pastikan teks mengandung kata kunci keuangan (e.g. 'Rp 50.000', 'berhasil', 'di Kopi Kenangan').",
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text("Mengerti"),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      );
    }
  }

  void _showSuccessPopup(TransactionModel tx) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text("⚡ Auto-Catat Berhasil"),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            children: [
              Text("Merchant: ${tx.title}"),
              Text("Nominal: ${tx.formattedAmount}"),
              Text("Kategori: ${tx.category}"),
              Text("Sumber: ${tx.source}"),
              const SizedBox(height: 6),
              const Text(
                "Tersimpan aman di penyimpanan lokal.",
                style: TextStyle(fontSize: 11, color: CupertinoColors.systemGrey),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("Mantap"),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

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

              // ── LARGE TITLE "Auto-Catat Notif HP" & Subtitle Lega ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
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
                      const SizedBox(height: 3),
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

              // Service Status Card (Squishy Bouncy)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: GlassCard(
                  isDark: widget.isDark,
                  borderRadius: 22,
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (_isServiceEnabled
                                      ? const Color(0xFF34C759)
                                      : const Color(0xFF8E8E93))
                                  .withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isServiceEnabled
                                  ? CupertinoIcons.bell_fill
                                  : CupertinoIcons.bell_slash_fill,
                              color: _isServiceEnabled
                                  ? const Color(0xFF34C759)
                                  : const Color(0xFF8E8E93),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Listener Notifikasi",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _isServiceEnabled
                                    ? "Aktif • Membaca BCA, Mandiri, GoPay dll"
                                    : "Nonaktif",
                                style: TextStyle(
                                  color: _isServiceEnabled
                                      ? const Color(0xFF34C759)
                                      : secondaryTextColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      CupertinoSwitch(
                        value: _isServiceEnabled,
                        activeTrackColor: const Color(0xFF34C759),
                        onChanged: (val) {
                          setState(() {
                            _isServiceEnabled = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Arsitektur & Privasi Info Box (Squishy Bouncy)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: BouncyTouchWrapper(
                  scaleFactor: 0.96,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF).withValues(alpha: widget.isDark ? 0.12 : 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF007AFF).withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                      boxShadow: [
                        if (!widget.isDark)
                          BoxShadow(
                            color: const Color(0xFF007AFF).withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          CupertinoIcons.info_circle_fill,
                          color: Color(0xFF007AFF),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Metode baca notifikasi ini adalah standar teraman (seperti Catat-in). Tidak membutuhkan integrasi login bank / API perbankan berbayar, bebas biaya admin, dan mutasi dibaca 100% lokal di HP tanpa dikirim ke server luar.",
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.85),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Live Simulator Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  "Uji Coba Cepat (Simulator Notifikasi)",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ),

            // Preset List (Squishy Bouncy on Tap)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final preset = _samplePresets[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: GlassCard(
                      isDark: widget.isDark,
                      borderRadius: 18,
                      padding: const EdgeInsets.all(14),
                      onTap: () => _testPreset(preset),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF007AFF).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              CupertinoIcons.bolt_fill,
                              color: Color(0xFF007AFF),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      preset["source"]!,
                                      style: const TextStyle(
                                        color: Color(0xFF007AFF),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Text(
                                      "Klik Uji Coba",
                                      style: TextStyle(
                                        color: Color(0xFF34C759),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  preset["body"]!,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 13,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _samplePresets.length,
              ),
            ),

            // Custom Notification Input
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GlassCard(
                  isDark: widget.isDark,
                  borderRadius: 20,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Tes Teks Notifikasi Kustom",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Ketik atau paste teks notifikasi dari HP untuk menguji parser SakuAman:",
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      CupertinoTextField(
                        controller: _customNotifController,
                        placeholder: "Contoh: Transaksi QRIS di Janji Jiwa Rp 24.000 sukses",
                        placeholderStyle: TextStyle(
                          color: secondaryTextColor.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                        style: TextStyle(color: textColor, fontSize: 13),
                        maxLines: 3,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? Colors.black.withValues(alpha: 0.3)
                              : const Color(0xFFE5E5EA).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      BouncyTouchWrapper(
                        scaleFactor: 0.94,
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
                          child: const Center(
                            child: Text(
                              "Jalankan Engine Parser",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
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

            if (_lastParsedStatus != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Text(
                    _lastParsedStatus!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF34C759),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
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
                          onTap: () => Navigator.of(context).pop(),
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

                    // Pojok Kanan Atas: Floating Liquid Badge [ ⚡ Auto-Catat ]
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
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: _isServiceEnabled
                                          ? const Color(0xFF34C759)
                                          : const Color(0xFF8E8E93),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _isServiceEnabled ? "Scanner Aktif" : "Nonaktif",
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
}
