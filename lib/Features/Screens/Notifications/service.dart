import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Call this once (e.g. in SplashScreen initState)
  Future<void> initialize() async {
    await Firebase.initializeApp();

    // ✅ Notification permission (Android 13+, iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _fcm.getToken();
      GlobalUtils().customLog("📲 FCM Token: $token");

      if (token != null) {
        await DeviceTokenStorage.saveToken(token);
      }

      // ✅ Foreground listener
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // ✅ Background/tapped message listener
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        GlobalUtils().customLog("📲 Notification tapped: ${message.data}");
      });

      // ✅ Initialize local notification channel (for foreground)
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);
      await _flutterLocalNotificationsPlugin.initialize(initSettings);
    } else {
      GlobalUtils().customLog("❌ Notification permission not granted");
    }
  }

  /// Handle and show notification in foreground
  void _handleForegroundMessage(RemoteMessage message) {
    GlobalUtils().customLog(
      "🔔 Foreground message: ${message.notification?.title}",
    );

    if (message.notification != null) {
      const androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      _flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        notificationDetails,
      );
    }
  }
}

class DeviceTokenStorage {
  static const _key = 'device_token';

  /// Save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  /// Get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  /// Delete token
  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

/*
// Save
await DeviceTokenStorage.saveToken('abcd1234');

// Retrieve
String? token = await DeviceTokenStorage.getToken();
print('Device Token: $token');

// Delete
await DeviceTokenStorage.deleteToken();

 */
