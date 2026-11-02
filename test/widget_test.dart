import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:finances/main.dart';
import 'package:finances/screens/main_tab_screen.dart';
import 'package:finances/widgets/bouncy_touch_wrapper.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('SakuAman app smoke test and 4-tab verification', (WidgetTester tester) async {
    await tester.pumpWidget(const SakuAmanApp());
    // Pump frames with duration since LiquidCard runs an infinite wave animation
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Brand title & Greeting exist
    expect(find.text('SakuAman'), findsWidgets);
    expect(find.text('Halo, Deni'), findsOneWidget);

    // Verify 4 Tab Items exist in Bottom Liquid Glass Bar
    expect(find.text('Beranda'), findsWidgets);
    expect(find.text('Riwayat'), findsWidgets);
    expect(find.text('Analisa AI'), findsWidgets);
    expect(find.text('Akun'), findsWidgets);
  });

  testWidgets('Responsive layout check without RenderFlex overflow (360x800)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SakuAmanApp());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('SakuAman'), findsWidgets);
    expect(find.text('Halo, Deni'), findsOneWidget);
    expect(find.text('Akun'), findsWidgets);
  });

  testWidgets('BouncyTouchWrapper triggers tap callback', (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: BouncyTouchWrapper(
          onTap: () => tapped = true,
          child: const Text('Bouncy Test'),
        ),
      ),
    );

    expect(find.text('Bouncy Test'), findsOneWidget);
    await tester.tap(find.text('Bouncy Test'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(tapped, isTrue);
  });

  testWidgets('MainTabScreen in Light Mode renders cleanly without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: MainTabScreen(initialIsDark: false),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Beranda'), findsWidgets);
    expect(find.text('Akun'), findsWidgets);
    expect(find.byIcon(CupertinoIcons.plus), findsWidgets);
  });

  testWidgets('Switch to Akun tab renders ProfileScreen with pinned island', (WidgetTester tester) async {
    await tester.pumpWidget(const SakuAmanApp());
    await tester.pump(const Duration(milliseconds: 300));

    // Tap on the Akun tab
    await tester.tap(find.text('Akun').first, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 350));

    // Profile screen details should be visible
    expect(find.text('Deni Wahyudi'), findsOneWidget);
    expect(find.text('Akun & Pengaturan'), findsOneWidget);
    expect(find.text('Profil Deni'), findsOneWidget);
    expect(find.text('REKENING & E-WALLET'), findsOneWidget);
  });

  testWidgets('LiquidGlassTabBar authentic pill mode and tab drag support across screens', (WidgetTester tester) async {
    await tester.pumpWidget(const SakuAmanApp());
    await tester.pump(const Duration(milliseconds: 300));

    // Tap on Riwayat tab
    await tester.tap(find.text('Riwayat').first, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Riwayat Kas'), findsOneWidget);

    // Tap on Analisa AI tab
    await tester.tap(find.text('Analisa AI').first, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('SakuAI'), findsOneWidget);
    expect(find.text('100% Offline'), findsOneWidget);

    // Verify the animated nav gesture overlay is mounted directly by LiquidGlassScaffold
    expect(find.byKey(const ValueKey('lg-animated-nav-gesture-overlay')), findsOneWidget);
  });

  testWidgets('Tapping plus morph button expands into transaction menu', (WidgetTester tester) async {
    await tester.pumpWidget(const SakuAmanApp());
    await tester.pump(const Duration(milliseconds: 300));

    // Tap the plus button
    await tester.tap(find.byIcon(CupertinoIcons.plus).first, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 350));

    // Morphed menu should be visible
    expect(find.text('Catat Transaksi'), findsOneWidget);
    expect(find.text('Belanja, makan, transport'), findsOneWidget);
    expect(find.text('Gaji, transfer, bonus'), findsOneWidget);
  });

  testWidgets('Top bar brand pill, bell icon, and theme icon support fluid touch and taps', (WidgetTester tester) async {
    await tester.pumpWidget(const SakuAmanApp());
    await tester.pump(const Duration(milliseconds: 300));

    // Verify brand pill exists
    expect(find.text('SakuAman'), findsOneWidget);

    // Verify drag gesture on SakuAman brand pill (melar dan mantul, scroll dinonaktifkan saat disentuh)
    final gesture = await tester.startGesture(tester.getCenter(find.text('SakuAman')));
    await tester.pump();

    // Verify scroll physics is switched to NeverScrollableScrollPhysics while touching/dragging top bar
    final customScrollView = tester.widget<CustomScrollView>(find.byType(CustomScrollView));
    expect(customScrollView.physics, isA<NeverScrollableScrollPhysics>());

    await gesture.moveBy(const Offset(20, 10));
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.up();
    await tester.pump();

    // Verify scroll physics is restored to BouncingScrollPhysics after release
    final customScrollViewAfter = tester.widget<CustomScrollView>(find.byType(CustomScrollView));
    expect(customScrollViewAfter.physics, isA<BouncingScrollPhysics>());

    // Verify bell icon exists and morphs fluidly into recent notifications popover
    expect(find.byIcon(CupertinoIcons.bell_fill), findsOneWidget);
    expect(find.text('Notifikasi Terbaru'), findsNothing);

    // Tap bell icon to morph into notification popover
    await tester.tap(find.byIcon(CupertinoIcons.bell_fill), warnIfMissed: false);
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 30));
    }

    // Verify Notifikasi Terbaru popover opened
    expect(find.text('Notifikasi Terbaru'), findsOneWidget);
    expect(find.text('Lihat Notifikasi Lainnya'), findsOneWidget);

    // Tap "Lihat Notifikasi Lainnya" to navigate to full NotificationListenerScreen
    await tester.tap(find.text('Lihat Notifikasi Lainnya'), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify NotificationListenerScreen opened
    expect(find.text('Auto-Catat Notif HP'), findsOneWidget);
  });

  testWidgets('LiquidBalanceCard privacy toggle and hold-to-bounce scroll lock', (WidgetTester tester) async {
    await tester.pumpWidget(const SakuAmanApp());
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Verify Privacy Toggle replaces '100% Offline'
    expect(find.text('100% Offline'), findsNothing);
    expect(find.byKey(const ValueKey('privacy_toggle_button')), findsOneWidget);
    expect(find.text('Saldo Kas SakuAman'), findsOneWidget);

    // Tap Privacy button -> obscures balance
    await tester.tap(find.byKey(const ValueKey('privacy_toggle_button')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Rp ••••••••'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.eye_slash_fill), findsOneWidget);

    // Tap again -> restores visible balance
    await tester.tap(find.byKey(const ValueKey('privacy_toggle_button')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Rp ••••••••'), findsNothing);
    expect(find.byIcon(CupertinoIcons.eye_fill), findsOneWidget);

    // 2. Verify Hold-to-bounce: quick drag scrolls without lock
    await tester.drag(find.text('Saldo Kas SakuAman'), const Offset(0, -60));
    await tester.pump(const Duration(milliseconds: 50));
    final customScrollView = tester.widget<CustomScrollView>(find.byType(CustomScrollView));
    expect(customScrollView.physics, isA<BouncingScrollPhysics>());

    // 3. Verify Press and Hold (> 220ms) locks scroll
    final holdGesture = await tester.startGesture(tester.getCenter(find.text('Saldo Kas SakuAman')));
    await tester.pump(const Duration(milliseconds: 250)); // hold timer triggers

    final lockedScrollView = tester.widget<CustomScrollView>(find.byType(CustomScrollView));
    expect(lockedScrollView.physics, isA<NeverScrollableScrollPhysics>());

    // Drag while held (subtle elastic stretch)
    await holdGesture.moveBy(const Offset(10, 10));
    await tester.pump(const Duration(milliseconds: 50));

    // Release gesture -> scroll unlocked
    await holdGesture.up();
    await tester.pump(const Duration(milliseconds: 400)); // spring settle

    final unlockedScrollView = tester.widget<CustomScrollView>(find.byType(CustomScrollView));
    expect(unlockedScrollView.physics, isA<BouncingScrollPhysics>());
  });

  testWidgets('Aktivitas Terkini Grouped Inset Container and Lihat Semua navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const SakuAmanApp());
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Aktivitas Terkini header exists
    expect(find.text('Aktivitas Terkini'), findsOneWidget);
    expect(find.text('Lihat Semua'), findsOneWidget);

    // Verify chip filters are cleanly removed from dashboard
    expect(find.text('Semua'), findsNothing);

    // Tap 'Lihat Semua' -> switches to History tab
    await tester.tap(find.text('Lihat Semua'));
    await tester.pump(const Duration(milliseconds: 350));

    // History screen elements should now be visible
    expect(find.text('Riwayat Transaksi'), findsOneWidget);
  });

  testWidgets('Pinned Top Islands stay at fixed top screen coordinates when scrolling', (WidgetTester tester) async {
    await tester.pumpWidget(const SakuAmanApp());
    await tester.pump(const Duration(milliseconds: 300));

    // Get initial position of SakuAman brand pill
    final initialPillPos = tester.getTopLeft(find.text('SakuAman'));

    // Scroll dashboard content down
    await tester.drag(find.text('Saldo Kas SakuAman'), const Offset(0, -250));
    await tester.pump(const Duration(milliseconds: 100));

    // Position of SakuAman pill remains pinned at the exact same screen coordinates
    final afterScrollPillPos = tester.getTopLeft(find.text('SakuAman'));
    expect(afterScrollPillPos.dy, equals(initialPillPos.dy));
    expect(afterScrollPillPos.dx, equals(initialPillPos.dx));
  });

  testWidgets('Top-right Settings button in ProfileScreen morphs fluidly into Apple Glass Popover menu', (WidgetTester tester) async {
    await tester.pumpWidget(const SakuAmanApp());
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Switch to Akun tab
    await tester.tap(find.text('Akun').first, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(); // Let post-frame layout seed the morph measurement

    // 2. Settings button (glyph) should be visible in resting circular state
    expect(find.byIcon(CupertinoIcons.gear_alt_fill), findsWidgets);
    expect(find.text('Pengaturan Tampilan'), findsNothing);

    // 3. Tap the Settings button
    await tester.tap(find.byIcon(CupertinoIcons.gear_alt_fill).first, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 600)); // Allow fluid spring to settle completely

    // 4. LiquidGlassMorph expands into popover menu
    expect(find.text('Pengaturan Tampilan'), findsOneWidget);
    expect(find.text('Penanda FPS HUD'), findsOneWidget);
    expect(find.text('Smart 1 FPS Idle'), findsOneWidget);
    expect(find.text('Mode Gelap'), findsOneWidget);
    expect(find.text('Pengaturan Lanjutan'), findsOneWidget);

    // 5. Tap outside on the fullscreen barrier to dismiss and morph back
    await tester.tapAt(const Offset(100, 450));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 600));

    // 6. Morphed menu collapses back into glyph button
    expect(find.text('Pengaturan Tampilan'), findsNothing);
    expect(find.byIcon(CupertinoIcons.gear_alt_fill), findsWidgets);
  });
}
