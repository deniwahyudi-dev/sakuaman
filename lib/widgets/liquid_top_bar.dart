import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';

/// Floating Capsule Island Top Bar (Opsi A)
///
/// An ultra-luxurious floating top bar island with real liquid glass refraction,
/// specular edge illumination, and soft-body touch elasticity (LiquidGlassTouch).
class LiquidTopBar extends StatelessWidget {
  final Widget left;
  final Widget? right;
  final bool isDark;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  const LiquidTopBar({
    super.key,
    required this.left,
    this.right,
    required this.isDark,
    this.margin = const EdgeInsets.fromLTRB(16, 10, 16, 8),
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    // Smoked Obsidian in Dark Mode / Pristine Crystal Ice in Light Mode
    final islandStyle = LiquidGlassStyle(
      shape: const LiquidGlassShape.continuousRoundedRectangle(
        cornerRadius: 22,
      ),
      color: isDark
          ? const Color(0xFF1C1C1E).withValues(alpha: 0.82)
          : Colors.white.withValues(alpha: 0.80),
      blur: 16.0,
      refractionIndex: 1.12,
      refractionWidth: 10,
      specular: LiquidGlassLight.specular(
        thickness: 3.5,
        intensity: isDark ? 0.85 : 1.0,
      ),
      shadow: LiquidGlassShadow(
        blur: 16,
        opacity: isDark ? 0.45 : 0.08,
        color: isDark ? Colors.black : const Color(0xFF0F172A),
      ),
    );

    return Container(
      margin: margin,
      child: LiquidGlassLens(
        style: islandStyle,
        touch: const LiquidGlassTouch(
          flex: LiquidGlassFlex.subtle(),
        ),
        child: Padding(
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: left),
              if (right != null) ...[
                const SizedBox(width: 8),
                right!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
