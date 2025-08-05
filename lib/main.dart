import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lgbt_togo/Features/Screens/Chat/observer.dart';
import 'package:lgbt_togo/Features/Screens/Splash/splash.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// 🔧 Background message handler
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("📥 Background message received: ${message.messageId}");
  print("📦 Raw data: ${message.data}");

  dynamic actualData = message.data;
  if (message.data['data'] is String) {
    try {
      actualData = json.decode(message.data['data']);
    } catch (e) {
      // print("❌ Background JSON decode failed: $e");
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint = (String? message, {int? wrapWidth}) {};

  // Load language
  await Localizer.loadLanguage();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Register background handler ✅
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize local notification plugin ✅
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Load .env
  try {
    await dotenv.load(fileName: ".env");
    GlobalUtils().customLog('.env loaded successfully');
  } catch (e) {
    GlobalUtils().customLog('Failed to load .env: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: Localizer.langNotifier,
      builder: (context, langCode, _) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && currentUser.uid.isNotEmpty) {
          AppLifecycleHandler().start(currentUser.uid);
        }

        return MaterialApp(
          navigatorKey: navigatorKey,
          theme: ThemeData.light(),
          debugShowCheckedModeBanner: false,
          home: SplashScreen(),
        );
      },
    );
  }
}
