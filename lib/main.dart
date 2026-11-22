import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'services/preferences_service.dart';
import 'services/auth_service.dart';
import 'theme/saku_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/main_tab_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // Muat status cache preferensi lokal (Tema & Riwayat Onboarding)
  final initialIsDark = await PreferencesService.isDarkMode();
  final hasSeenOnboarding = await PreferencesService.hasSeenOnboarding();
  final isLoggedIn = await AuthService.instance.isLoggedIn();

  // Warm-up and pre-compile Liquid Glass Shaders directly onto GPU
  try {
    await LiquidGlassShaders.ensureLoaded();
  } catch (_) {
    // Graceful fallback for non-shader headless test environments
  }

  // 1. PAKSA mode Edge-to-Edge murni di seluruh layar Android (Tembus Notch & Navigation Bar)
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // 2. PAKSA Status Bar & Navigation Bar 100% transparan (0 opacity) tanpa pembatas/scrim OS
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: initialIsDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: initialIsDark ? Brightness.dark : Brightness.light,
      systemStatusBarContrastEnforced: false, // MATIKAN pembatas scrim/bayangan dari OS Android!
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: initialIsDark ? Brightness.light : Brightness.dark,
      systemNavigationBarContrastEnforced: false, // MATIKAN pembatas navigation bar!
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  runApp(SakuAmanApp(
    initialIsDark: initialIsDark,
    hasSeenOnboarding: hasSeenOnboarding,
    isLoggedIn: isLoggedIn,
    showSplash: true,
  ));
}

class SakuAmanApp extends StatelessWidget {
  final bool initialIsDark;
  final bool hasSeenOnboarding;
  final bool isLoggedIn;
  final bool showSplash;
  final Widget? home;

  const SakuAmanApp({
    super.key,
    this.initialIsDark = false,
    this.hasSeenOnboarding = true,
    this.isLoggedIn = false,
    this.showSplash = false,
    this.home,
  });

  @override
  Widget build(BuildContext context) {
    Widget defaultHome;
    if (showSplash) {
      defaultHome = SplashScreen(
        isDark: initialIsDark,
        hasSeenOnboarding: hasSeenOnboarding,
        isLoggedIn: isLoggedIn,
      );
    } else {
      if (!hasSeenOnboarding) {
        defaultHome = OnboardingScreen(isDark: initialIsDark);
      } else if (!isLoggedIn) {
        defaultHome = AuthScreen(isDark: initialIsDark, onThemeChanged: () {});
      } else {
        defaultHome = MainTabScreen(initialIsDark: initialIsDark);
      }
    }

    return MaterialApp(
      title: 'SakuAman',
      debugShowCheckedModeBanner: false,
      theme: SakuTheme.getTheme(isDark: initialIsDark),
      home: home ?? defaultHome,
    );
  }
}
