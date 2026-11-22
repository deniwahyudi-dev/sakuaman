import 'package:flutter/material.dart';
import '../services/promotion_manager.dart';

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

    ProMotionManager.instance.isIdle.addListener(_handleProMotionIdleChange);
  }

  void _handleProMotionIdleChange() {
    if (!mounted) return;
    if (ProMotionManager.instance.isIdle.value &&
        ProMotionManager.instance.isEngineEnabled.value) {
      if (_meshController.isAnimating) {
        _meshController.stop(canceled: false);
      }
    } else {
      if (!_meshController.isAnimating) {
        _meshController.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    ProMotionManager.instance.isIdle.removeListener(_handleProMotionIdleChange);
    _meshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDark
        ? const Color(0xFF000000)
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
                // Apple Pure OLED Black: Solid pitch black (#000000) canvas for true iOS depth & infinite contrast
                return const SizedBox.shrink();
              } else {
                // Light Mode: Soft Studio Glow Orbs (Native GPU Radial Gradient Glow)
                return Stack(
                  children: [
                    Positioned(
                      top: -60 + (t * 20),
                      right: -40 + (t * 10),
                      child: Container(
                        width: 340,
                        height: 340,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF007AFF).withValues(alpha: 0.15),
                              const Color(0xFF007AFF).withValues(alpha: 0.05),
                              const Color(0xFF007AFF).withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.55, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 240 - (t * 15),
                      left: -60 + (t * 15),
                      child: Container(
                        width: 310,
                        height: 310,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF5856D6).withValues(alpha: 0.12),
                              const Color(0xFF5856D6).withValues(alpha: 0.04),
                              const Color(0xFF5856D6).withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.55, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 100 + (t * 10),
                      right: -30,
                      child: Container(
                        width: 290,
                        height: 290,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF00C4FF).withValues(alpha: 0.12),
                              const Color(0xFF00C4FF).withValues(alpha: 0.04),
                              const Color(0xFF00C4FF).withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.55, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),

          // Main Screen Foreground Content
          widget.child,
        ],
      ),
    );
  }
}
