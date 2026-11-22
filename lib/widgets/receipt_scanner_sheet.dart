import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../services/receipt_parser.dart';
import 'bouncy_touch_wrapper.dart';

class ReceiptScannerSheet extends StatefulWidget {
  final bool isDark;
  final Function(ParsedReceiptResult) onReceiptScanned;

  const ReceiptScannerSheet({
    super.key,
    required this.isDark,
    required this.onReceiptScanned,
  });

  @override
  State<ReceiptScannerSheet> createState() => _ReceiptScannerSheetState();
}

class _ReceiptScannerSheetState extends State<ReceiptScannerSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  ParsedReceiptResult? _activeResult;
  bool _isScanning = false;
  String _selectedPresetName = "";

  final List<Map<String, dynamic>> _presets = [];

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _laserController.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  void _selectPreset(Map<String, dynamic> preset) {
    setState(() {
      _selectedPresetName = preset["name"] as String;
      _activeResult = ReceiptParserEngine.parseReceiptText(preset["text"] as String);
    });
  }

  // ── AMBIL FOTO DARI KAMERA ATAU GALERI DENGAN ML KIT OCR ON-DEVICE ──
  Future<void> _pickImageAndScan(ImageSource source) async {
    HapticFeedback.lightImpact();
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (image == null) return;

      setState(() => _isScanning = true);
      HapticFeedback.mediumImpact();

      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      final rawText = recognizedText.text;
      if (rawText.trim().isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tidak ada teks terdeteksi dari foto struk"),
            duration: Duration(seconds: 2),
          ),
        );
        setState(() => _isScanning = false);
        return;
      }

      final parsed = ReceiptParserEngine.parseReceiptText(rawText);
      if (!mounted) return;
      HapticFeedback.selectionClick();
      setState(() {
        _activeResult = parsed;
        _isScanning = false;
        _selectedPresetName = "";
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memproses struk: $e"),
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() => _isScanning = false);
    }
  }

  String _formatRp(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor =
        isDark ? const Color(0xFF8E8E93) : const Color(0xFF64748B);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF141416).withValues(alpha: 0.94)
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.16)
                    : Colors.white,
                width: 1.2,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 30,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grabber Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: secondaryTextColor.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Header Modal Apple Style
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF007AFF).withValues(alpha: isDark ? 0.20 : 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF007AFF).withValues(alpha: isDark ? 0.35 : 0.20),
                          width: 0.8,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          CupertinoIcons.viewfinder,
                          color: Color(0xFF007AFF),
                          size: 19,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pindai Struk & Nota",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 1.5),
                          Row(
                            children: [
                              Container(
                                width: 5.5,
                                height: 5.5,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF34C759),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "Apple Intelligence • On-Device OCR",
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    BouncyTouchWrapper(
                      scaleFactor: 0.84,
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: secondaryTextColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            CupertinoIcons.xmark,
                            color: secondaryTextColor,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                height: 1,
                thickness: 0.5,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
              ),

              // Content Body
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. VisionOS Viewfinder Platter
                    Container(
                      height: 135,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0B0E17)
                            : const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFF007AFF).withValues(alpha: isDark ? 0.30 : 0.20),
                          width: 1.2,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background Watermark Viewfinder
                          Icon(
                            CupertinoIcons.doc_text_viewfinder,
                            size: 64,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.04),
                          ),

                          // Viewfinder Bracket Frame
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF007AFF).withValues(alpha: 0.35),
                                width: 1.2,
                              ),
                            ),
                          ),

                          // Animated Cyan Laser Scanning Line
                          AnimatedBuilder(
                            animation: _laserController,
                            builder: (context, child) {
                              return Positioned(
                                top: 20 + (_laserController.value * 88),
                                left: 32,
                                right: 32,
                                child: Container(
                                  height: 2.0,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Color(0xFF00F5D4),
                                        Color(0xFF007AFF),
                                        Color(0xFF00F5D4),
                                        Colors.transparent,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF007AFF).withValues(alpha: 0.7),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // Status Capsule Chip
                          Positioned(
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4.5),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.black.withValues(alpha: 0.75)
                                    : Colors.white.withValues(alpha: 0.88),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : Colors.black.withValues(alpha: 0.06),
                                  width: 0.7,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_isScanning) ...[
                                    const CupertinoActivityIndicator(radius: 5.5),
                                    const SizedBox(width: 6),
                                    const Text(
                                      "Mengekstrak teks struk dengan AI...",
                                      style: TextStyle(
                                        color: Color(0xFF007AFF),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ] else ...[
                                    const Icon(
                                      CupertinoIcons.sparkles,
                                      color: Color(0xFF007AFF),
                                      size: 12,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "Arahkan kamera ke nota belanja",
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 2. Dual Action Buttons (Kamera Asli & Galeri Foto Asli)
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: BouncyTouchWrapper(
                            scaleFactor: 0.96,
                            onTap: () => _pickImageAndScan(ImageSource.camera),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF007AFF), Color(0xFF0056B3)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF007AFF).withValues(alpha: 0.32),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(CupertinoIcons.camera_fill,
                                      color: Colors.white, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    "Buka Kamera",
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
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: BouncyTouchWrapper(
                            scaleFactor: 0.96,
                            onTap: () => _pickImageAndScan(ImageSource.gallery),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : const Color(0xFFF2F2F7),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : Colors.black.withValues(alpha: 0.06),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.photo_on_rectangle,
                                    color: textColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Galeri",
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Quick Preset Simulator Chips (Minimal, Apple Style, No screaming debug text)
                    SizedBox(
                      height: 30,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _presets.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 6),
                        itemBuilder: (context, index) {
                          final p = _presets[index];
                          final isSelected = p["name"] == _selectedPresetName;
                          final Color chipColor = p["color"] as Color;
                          return BouncyTouchWrapper(
                            scaleFactor: 0.94,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _selectPreset(p);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? chipColor.withValues(alpha: isDark ? 0.22 : 0.12)
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.black.withValues(alpha: 0.04)),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? chipColor.withValues(alpha: isDark ? 0.45 : 0.30)
                                      : Colors.transparent,
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    p["icon"] as IconData,
                                    color: isSelected ? chipColor : secondaryTextColor,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    p["name"] as String,
                                    style: TextStyle(
                                      color: isSelected ? textColor : secondaryTextColor,
                                      fontSize: 11.5,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 3. Apple VisionOS Receipt Platter (The Clean Result Ticket)
                    if (_activeResult != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.10)
                                : Colors.black.withValues(alpha: 0.06),
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row 1: Merchant & Category Tag
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF34C759).withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        CupertinoIcons.checkmark_seal_fill,
                                        color: Color(0xFF34C759),
                                        size: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _activeResult!.merchant,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF007AFF).withValues(alpha: isDark ? 0.20 : 0.10),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "${_activeResult!.category} • ${_activeResult!.source}",
                                    style: const TextStyle(
                                      color: Color(0xFF007AFF),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Row 2: Big Numerical Focal Point (Anchor)
                            Text(
                              _formatRp(_activeResult!.amount),
                              style: TextStyle(
                                color: textColor,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Total Terdeteksi • 14 Nov 2026",
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),

                            if (_activeResult!.detectedItems.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Divider(
                                height: 1,
                                thickness: 0.5,
                                color: isDark ? Colors.white12 : Colors.black12,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: _activeResult!.detectedItems.take(4).map((item) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.06)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.08)
                                            : Colors.black.withValues(alpha: 0.05),
                                      ),
                                    ),
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        color: secondaryTextColor,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],

                            const SizedBox(height: 14),

                            // Primary Action Button (Apple Green / Blue Primary)
                            BouncyTouchWrapper(
                              scaleFactor: 0.96,
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                widget.onReceiptScanned(_activeResult!);
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF34C759),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF34C759).withValues(alpha: 0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Gunakan Transaksi Ini",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Icon(
                                        CupertinoIcons.chevron_forward,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
