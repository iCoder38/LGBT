import 'dart:convert';

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

    // ✅ Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // ✅ Create notification channel
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Used for important notifications',
      importance: Importance.max,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    // ✅ Init plugin for foreground and background use
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _flutterLocalNotificationsPlugin.initialize(initSettings);

    // ✅ Request permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _fcm.getToken();
      if (token != null) await DeviceTokenStorage.saveToken(token);

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("📲 Notification tapped (background): ${message.data}");
      });

      RemoteMessage? initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) {
        print("📲 App launched via notification: ${initialMessage.data}");
      }
    } else {
      print("❌ Notification permission not granted");
    }
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();

    print("📥 Background message received: ${message.messageId}");
    print("📦 Raw data: ${message.data}");

    // Decode malformed payload if needed
    dynamic actualData = message.data;
    if (message.data['data'] is String) {
      try {
        actualData = json.decode(message.data['data']);
      } catch (e) {
        print("❌ JSON decode failed in background: $e");
        actualData = {};
      }
    }

    final title = message.notification?.title ?? 'LGBT TOGO';
    final body =
        message.notification?.body ??
        actualData['message'] ??
        'You have a new notification';

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      title,
      body,
      notificationDetails,
    );
  }

  /// Handle and show notification in foreground
  void _handleForegroundMessage(RemoteMessage message) {
    // print("DEBUG raw message.data: ${message.data}");

    // Try to parse message.data['data'] if it's a JSON string
    dynamic actualData = message.data;
    if (message.data['data'] is String) {
      try {
        actualData = json.decode(message.data['data']);
      } catch (e) {
        // print("❌ JSON decode failed: $e");
        actualData = {};
      }
    }

    // Now safely extract the message text
    final title = message.notification?.title ?? 'LGBT TOGO';
    final body =
        message.notification?.body ??
        actualData['message'] ??
        'You have a new notification';

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      title,
      body,
      notificationDetails,
    );
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
