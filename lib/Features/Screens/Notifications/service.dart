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
      // Save
      await DeviceTokenStorage.saveToken(token.toString());
    } else {
      GlobalUtils().customLog("❌ Notification permission not granted");
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
