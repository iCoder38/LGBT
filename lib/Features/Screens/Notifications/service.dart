import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // 🔐 Request permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // ✅ Permission granted, get token
      String? token = await _fcm.getToken();
      GlobalUtils().customLog("📲 Device Token: $token");
    } else {
      GlobalUtils().customLog("❌ Notification permission not granted");
    }
  }
}
