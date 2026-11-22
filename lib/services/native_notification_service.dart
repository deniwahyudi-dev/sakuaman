import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:notification_listener_service/notification_event.dart';
import '../models/transaction.dart';
import 'notification_parser.dart';

class NativeNotificationService {
  static final NativeNotificationService _instance = NativeNotificationService._internal();
  factory NativeNotificationService() => _instance;
  NativeNotificationService._internal();

  StreamSubscription<ServiceNotificationEvent>? _subscription;
  Function(TransactionModel)? _onTransactionDetected;

  bool _isListening = false;
  bool get isListening => _isListening;

  /// Inisialisasi Service. Meminta izin jika belum diberikan.
  Future<bool> initialize({required Function(TransactionModel) onTransactionDetected}) async {
    _onTransactionDetected = onTransactionDetected;
    
    // Cek apakah permission sudah diberikan
    bool isGranted = await NotificationListenerService.isPermissionGranted();
    
    if (!isGranted) {
      // Buka halaman pengaturan Android
      isGranted = await NotificationListenerService.requestPermission();
    }
    
    return isGranted;
  }

  /// Mulai mendengarkan notifikasi secara real-time dari OS
  void startListening() {
    if (_isListening) return;
    
    _subscription = NotificationListenerService.notificationsStream.listen((event) {
      _handleIncomingNotification(event);
    });
    
    _isListening = true;
    debugPrint("NativeNotificationService: Memulai pendengaran notifikasi sistem.");
  }

  /// Hentikan pendengaran notifikasi
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;
    debugPrint("NativeNotificationService: Berhenti mendengarkan.");
  }

  void _handleIncomingNotification(ServiceNotificationEvent event) {
    // Abaikan notifikasi sistem atau dari aplikasi ini sendiri
    if (event.packageName.contains("android") || event.packageName.contains("com.example.finances")) {
        return;
    }

    debugPrint("📱 Notifikasi Masuk: [${event.packageName}] ${event.title}");
    
    // Kirim ke Parser Engine
    final result = NotificationParserEngine.parseNotification(
      appOrSender: event.packageName, 
      title: event.title, 
      body: event.content,
    );

    // Jika valid sebagai transaksi finansial, lempar ke UI/Database
    if (result != null) {
      final tx = result.toTransaction();
      debugPrint("✅ Transaksi Ditemukan: ${tx.title} - ${tx.formattedAmount}");
      if (_onTransactionDetected != null) {
        _onTransactionDetected!(tx);
      }
    }
  }
}
