import 'dart:ui';
import 'package:flutter/material.dart';
import 'bouncy_touch_wrapper.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final double blur;
  final bool isDark;
  final bool enableBouncy;
  final double scaleFactor;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 22,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.color,
    this.blur = 20,
    this.isDark = true,
    this.enableBouncy = true,
    this.scaleFactor = 0.96,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? const EdgeInsets.all(16);

    // Dark Mode: Smoked Obsidian Glass (Calm, Deep & Anti-Rame)
    // Light Mode: Crystal Ice Glass with Prismatic Clarity
    final defaultBgColor = isDark
        ? const Color(0xFF101626).withValues(alpha: 0.72)
        : Colors.white.withValues(alpha: 0.84);

    final effectiveColor = color ?? defaultBgColor;

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.09)
        : const Color(0xFFFFFFFF).withValues(alpha: 0.85);

    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.35)
        : const Color(0xFF0F172A).withValues(alpha: 0.05);

    Widget content = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: isDark ? 18 : 16,
            offset: const Offset(0, 5),
          ),
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: effectivePadding,
            decoration: BoxDecoration(
              color: effectiveColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor,
                width: isDark ? 0.9 : 1.1,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0.02),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.90),
                        Colors.white.withValues(alpha: 0.60),
                      ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );

    if (enableBouncy) {
      return BouncyTouchWrapper(
        scaleFactor: scaleFactor,
        onTap: onTap,
        onLongPress: onLongPress,
        child: content,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}
