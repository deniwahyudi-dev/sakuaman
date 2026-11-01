import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SakuTheme {
  // Ultra-Luxe VisionOS / Cyber Jewel Accents
  static const Color cyberCyan = Color(0xFF00F5D4);
  static const Color electricBlue = Color(0xFF007AFF);
  static const Color royalIndigo = Color(0xFF5856D6);
  static const Color neonPurple = Color(0xFF7209B7);
  static const Color neonGreen = Color(0xFF00E676);
  static const Color crimsonRed = Color(0xFFFF2A55);
  static const Color radiantAmber = Color(0xFFFF9E00);
  static const Color sunsetPink = Color(0xFFF72585);

  // iOS Clean Light Mode (Pristine Pearl Ceramic & Crystal Ice)
  static const Color lightBg = Color(0xFFF6F8FC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFE2E8F0);
  static const Color lightCardBorderSpecular = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightPillBg = Color(0xFFE2E8F0);
  static const Color lightPillBgActive = Color(0xFF0F172A);

  // iOS Clean Dark Mode (Smoked Obsidian & Midnight Titanium)
  static const Color darkBg = Color(0xFF090C15);
  static const Color darkCard = Color(0xFF101626);
  static const Color darkCardBorder = Color(0xFF1B2338);
  static const Color darkCardBorderSpecular = Color(0xFF2B3857);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkPillBg = Color(0xFF151C30);
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
