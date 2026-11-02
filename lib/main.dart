import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'theme/saku_theme.dart';
import 'screens/main_tab_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

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
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemStatusBarContrastEnforced: false, // MATIKAN pembatas scrim/bayangan dari OS Android!
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarContrastEnforced: false, // MATIKAN pembatas navigation bar!
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  runApp(const SakuAmanApp());
}

class SakuAmanApp extends StatefulWidget {
  const SakuAmanApp({super.key});

  @override
  State<SakuAmanApp> createState() => _SakuAmanAppState();
}

class _SakuAmanAppState extends State<SakuAmanApp> {
  // Default mode: Crisp Dark Mode (bisa di-toggle langsung di dalam app)
  final bool _isDark = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SakuAman',
      debugShowCheckedModeBanner: false,
      theme: SakuTheme.getTheme(isDark: _isDark),
      home: MainTabScreen(initialIsDark: _isDark),
    );
  }
}
