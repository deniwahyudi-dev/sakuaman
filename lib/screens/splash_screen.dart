import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/ambient_mesh_background.dart';
import '../widgets/saku_logo.dart';
import 'onboarding_screen.dart';
import 'auth_screen.dart';
import 'main_tab_screen.dart';

/// Screen Pembuka Otentik ala Apple iOS
/// Bersih, minimalis, tanpa spinner, transisi mulus 1.2 detik.
class SplashScreen extends StatefulWidget {
  final bool isDark;
  final bool hasSeenOnboarding;
  final bool isLoggedIn;

  const SplashScreen({
    super.key,
    this.isDark = true,
    this.hasSeenOnboarding = false,
    this.isLoggedIn = false,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOut,
      ),
    );

    _animController.forward().then((_) {
      HapticFeedback.lightImpact();
    });

    // Masuk mulus ke halaman tujuan (Onboarding untuk pertama kali, atau langsung Dashboard jika sudah pernah)
    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      Widget targetScreen;
      if (!widget.hasSeenOnboarding) {
        targetScreen = OnboardingScreen(isDark: widget.isDark);
      } else if (!widget.isLoggedIn) {
        targetScreen = AuthScreen(isDark: widget.isDark, onThemeChanged: () {});
      } else {
        targetScreen = MainTabScreen(initialIsDark: widget.isDark);
      }

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, _, _) => targetScreen,
          transitionsBuilder: (_, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AmbientMeshBackground(
        isDark: widget.isDark,
        child: Center(
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: SakuLogo(
                    size: 80,
                    isDark: widget.isDark,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
