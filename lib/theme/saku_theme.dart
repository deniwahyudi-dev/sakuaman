import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SakuTheme {
  // Ultra-Luxe VisionOS / Apple System Jewel Accents
  static const Color cyberCyan = Color(0xFF5AC8FA);   // Apple System Teal
  static const Color electricBlue = Color(0xFF007AFF); // Apple System Blue
  static const Color royalIndigo = Color(0xFF5856D6);  // Apple System Indigo
  static const Color neonPurple = Color(0xFFAF52DE);   // Apple System Purple
  static const Color neonGreen = Color(0xFF34C759);    // Apple System Green
  static const Color crimsonRed = Color(0xFFFF3B30);   // Apple System Red
  static const Color radiantAmber = Color(0xFFFF9500); // Apple System Orange
  static const Color sunsetPink = Color(0xFFFF2D55);   // Apple System Pink

  // iOS Clean Light Mode (Pristine Pearl Ceramic & Crystal Ice)
  static const Color lightBg = Color(0xFFF6F8FC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFE2E8F0);
  static const Color lightCardBorderSpecular = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightPillBg = Color(0xFFE2E8F0);
  static const Color lightPillBgActive = Color(0xFF0F172A);

  // iOS Clean Dark Mode (Apple Pure OLED Black & Smoked Charcoal Gray 6)
  static const Color darkBg = Color(0xFF000000);
  static const Color darkCard = Color(0xFF1C1C1E);
  static const Color darkCardBorder = Color(0xFF2C2C2E);
  static const Color darkCardBorderSpecular = Color(0xFF3A3A3C);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF8E8E93);
  static const Color darkPillBg = Color(0xFF2C2C2E);
  static const Color darkPillBgActive = Color(0xFFFFFFFF);

  static ThemeData getTheme({required bool isDark}) {
    final bg = isDark ? darkBg : lightBg;
    final card = isDark ? darkCard : lightCard;
    final textPrim = isDark ? darkTextPrimary : lightTextPrimary;

    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bg,
      cardColor: card,
      fontFamily: '.SF Pro Text',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: Colors.black,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: lightBg,
              ),
      ),
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: electricBlue,
        onPrimary: Colors.white,
        secondary: cyberCyan,
        onSecondary: Colors.black,
        error: crimsonRed,
        onError: Colors.white,
        surface: card,
        onSurface: textPrim,
      ),
      // ── APPLE IOS PAGE TRANSITIONS THEME (NATIVE CUERTINO PARALLAX SLIDE) ──
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primaryColor: electricBlue,
        scaffoldBackgroundColor: bg,
        barBackgroundColor: isDark
            ? const Color(0xCC0F1423)
            : const Color(0xCCFFFFFF),
      ),
    );
  }
}
