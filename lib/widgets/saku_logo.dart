import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Komponen Logo SakuAman (Bentuk Saku / Wallet ala iOS)
/// Pengembang nantinya bisa mengganti child widget ini dengan SVG / Asset gambar kustom sendiri.
class SakuLogo extends StatelessWidget {
  final double size;
  final bool isDark;

  const SakuLogo({
    super.key,
    this.size = 36,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF007AFF),
            Color(0xFF00C6FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF007AFF).withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          CupertinoIcons.creditcard_fill, // Saku / Wallet style icon
          color: Colors.white,
          size: size * 0.52,
        ),
      ),
    );
  }
}
