import 'dart:ui';
import 'package:flutter/material.dart';

/// Dynamic Ambient Breathing Mesh Orbs
///
/// Paints vibrant, multi-layered glowing light pools in the background.
/// These colors provide rich visual data for Liquid Glass lenses to refract,
/// distort, and disperse with prismatic chromatic aberration!
class AmbientMeshBackground extends StatefulWidget {
  final bool isDark;
  final Widget child;

  const AmbientMeshBackground({
    super.key,
    required this.isDark,
    required this.child,
  });

  @override
  State<AmbientMeshBackground> createState() => _AmbientMeshBackgroundState();
}

class _AmbientMeshBackgroundState extends State<AmbientMeshBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _meshController;

  @override
  void initState() {
    super.initState();
    _meshController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _meshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark
        ? const Color(0xFF090C15)
        : const Color(0xFFF6F8FC);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Color Base
          Container(color: bgColor),

          // Animated Ambient Mesh Orbs
          AnimatedBuilder(
            animation: _meshController,
            builder: (context, _) {
              final t = _meshController.value;

              if (widget.isDark) {
                // Dark Mode: Serene Midnight Sapphire & Ice Slate (Calm, Deep & Anti-Rame)
                return Stack(
                  children: [
                    // Top Right: Deep Sapphire Blue Pool
                    Positioned(
                      top: -40 + (t * 25),
                      right: -50 + (t * 15),
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0D6EFD).withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    // Middle Left: Deep Slate Abyssal Pool
                    Positioned(
                      top: 220 - (t * 20),
                      left: -70 - (t * 10),
                      child: Container(
                        width: 290,
                        height: 290,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1E3A8A).withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    // Bottom Right: Gentle Ambient Azure Pool
                    Positioned(
                      bottom: 80 + (t * 15),
                      right: -60 - (t * 20),
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF007AFF).withValues(alpha: 0.07),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // Light Mode: Soft Studio Glow Orbs (Soft Azure & Light Rose)
                return Stack(
                  children: [
                    Positioned(
                      top: -60 + (t * 20),
                      right: -40 + (t * 10),
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF007AFF).withValues(alpha: 0.10),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 240 - (t * 15),
                      left: -60 + (t * 15),
                      child: Container(
                        width: 270,
                        height: 270,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF5856D6).withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 100 + (t * 10),
                      right: -30,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF00C4FF).withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),

          // Soft Global Defocus Blur Layer to smoothly blend the Mesh Orbs
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: const SizedBox.expand(),
            ),
          ),

          // Main Screen Foreground Content
          widget.child,
        ],
      ),
    );
  }
}
