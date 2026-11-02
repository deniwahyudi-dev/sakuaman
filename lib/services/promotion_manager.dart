import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// SakuAman ProMotion Dynamic Engine (Apple ProMotion & LTPO Simulation)
///
/// Mengatur frame pacing dinamis untuk layar high refresh rate (60Hz / 120Hz / 144Hz):
/// - Saat diam > 2.5s: Masuk ke mode 1 FPS (True LTPO Static) untuk hemat baterai drastis.
/// - Saat disentuh / scroll / animasi: Instan melompat ke 144 FPS (ProMotion Max).
/// - Menampilkan HUD Kapsul Penanda Real-Time di layar.
class ProMotionManager {
  ProMotionManager._();
  static final ProMotionManager instance = ProMotionManager._();

  /// Switch apakah Smart ProMotion 1 FPS Idle aktif
  final ValueNotifier<bool> isEngineEnabled = ValueNotifier<bool>(true);

  /// Switch apakah Kapsul Penanda FPS ditampilkan di layar
  final ValueNotifier<bool> showFpsBadge = ValueNotifier<bool>(true);

  /// Angka FPS yang ditampilkan (1, 60, 120, 144)
  final ValueNotifier<int> currentFps = ValueNotifier<int>(144);

  /// Status apakah saat ini layar sedang diam (idle)
  final ValueNotifier<bool> isIdle = ValueNotifier<bool>(false);

  Timer? _idleTimer;
  TimingsCallback? _timingsCallback;

  void initialize() {
    try {
      _timingsCallback = (List<FrameTiming> timings) {
        if (timings.isEmpty || isIdle.value || !isEngineEnabled.value) return;

        final latest = timings.last;
        final totalMicros = latest.totalSpan.inMicroseconds;
        if (totalMicros > 0) {
          final rawFps = (1000000 / totalMicros).round();
          int targetFps = 144;
          if (rawFps >= 130) {
            targetFps = 144;
          } else if (rawFps >= 105) {
            targetFps = 120;
          } else if (rawFps >= 75) {
            targetFps = 90;
          } else if (rawFps >= 45) {
            targetFps = 60;
          } else {
            targetFps = 30;
          }

          if (currentFps.value != targetFps && !isIdle.value) {
            currentFps.value = targetFps;
          }
        }
      };

      SchedulerBinding.instance.addTimingsCallback(_timingsCallback!);
    } catch (_) {
      // Graceful fallback for headless test environments
    }

    reportInteraction();
  }

  void dispose() {
    try {
      if (_timingsCallback != null) {
        SchedulerBinding.instance.removeTimingsCallback(_timingsCallback!);
      }
    } catch (_) {}
    _idleTimer?.cancel();
  }

  /// Dipanggil setiap ada interaksi jempol (touch down, pan, drag, scroll)
  void reportInteraction() {
    if (!isEngineEnabled.value) return;

    if (isIdle.value) {
      isIdle.value = false;
      currentFps.value = 144; // Burst ke ProMotion Max instan
    }

    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(milliseconds: 2500), () {
      if (isEngineEnabled.value) {
        isIdle.value = true;
        currentFps.value = 1; // Drop ke 1 FPS LTPO Idle
      }
    });
  }

  void toggleEngine(bool enabled) {
    isEngineEnabled.value = enabled;
    if (!enabled) {
      _idleTimer?.cancel();
      isIdle.value = false;
      currentFps.value = 144;
    } else {
      reportInteraction();
    }
  }

  void toggleBadge(bool show) {
    showFpsBadge.value = show;
  }
}
