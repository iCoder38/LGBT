// lib/main.dart
import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports
import 'package:lgbt_togo/Features/Screens/Chat/observer.dart';
import 'package:lgbt_togo/Features/Screens/Dashboard/post_details.dart';
import 'package:lgbt_togo/Features/Screens/Splash/splash.dart';
import 'package:lgbt_togo/Features/Screens/Subscription/revenueCat/revenuecat_service.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';
import 'package:lgbt_togo/Features/Utils/deep_link/deep_link_holder.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Background message handler (keeps your original behavior)
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  dynamic actualData = message.data;
  if (message.data['data'] is String) {
    try {
      actualData = json.decode(message.data['data']);
    } catch (_) {
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

  // optional: silence debug logs in production-like dev
  // comment this out if you want debug prints while developing
  // debugPrint = (String? message, {int? wrapWidth}) {};

  await Localizer.loadLanguage();
  await Firebase.initializeApp();

  // Replace with your RevenueCat public Android SDK key
  await RevenueCatService.instance.init(
    apiKey: 'goog_TzOvaqHditUmJPiRscGfLHZgdFl',
  );
  // 2. Check entitlement at startup
  await RevenueCatService.instance.isEntitlementActive('premium');

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // initialize flutter local notifications with tap callback
  final androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  final initSettings = InitializationSettings(android: androidInit);

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // payload was encoded as JSON string in setupFirebaseMessagingNavigation
      try {
        if (response.payload != null && response.payload!.isNotEmpty) {
          final Map parsed = json.decode(response.payload!);
          final data = <String, String>{};
          parsed.forEach((k, v) => data[k.toString()] = v?.toString() ?? '');
          _handleNotificationNavigation(data);
        }
      } catch (e) {
        debugPrint('local notification tap parse error: $e');
      }
    },
    // For older plugin versions you can use `onSelectNotification` which receives String? payload
  );

  try {
    await dotenv.load(fileName: ".env");
    GlobalUtils().customLog('.env loaded successfully');
  } catch (e) {
    GlobalUtils().customLog('Failed to load .env: $e');
  }

  // set up firebase messaging listeners (foreground/background/terminated)
  setupFirebaseMessagingNavigation();

  runApp(const MyApp());
}

/// Extract data map robustly from RemoteMessage
/// - handles both flat `message.data` and nested json string under `data` key.
Map<String, String> _extractDataMap(RemoteMessage message) {
  final Map<String, String> result = {};
  try {
    if (message.data.isNotEmpty) {
      message.data.forEach((k, v) {
        result[k.toString()] = v?.toString() ?? '';
      });

      // some backends put a JSON string under message.data['data']
      if (result.containsKey('data')) {
        final nested = result['data']!;
        if (nested.isNotEmpty) {
          try {
            final parsed = json.decode(nested);
            if (parsed is Map) {
              parsed.forEach((k, v) {
                result[k.toString()] = v?.toString() ?? '';
              });
            }
          } catch (_) {
            // ignore parse error
          }
        }
      }
    }
  } catch (e) {
    debugPrint('extractDataMap error: $e');
  }
  return result;
}

/// Setup FCM listeners and local-notification onMessage shows.
/// Call during app init after initializing firebase & flutterLocalNotificationsPlugin.
void setupFirebaseMessagingNavigation() {
  final fm = FirebaseMessaging.instance;

  // Cold start: app launched by tapping a notification (terminated)
  fm.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      final data = _extractDataMap(message);
      _handleNotificationNavigation(data);
    }
  });

  // When app is in background and opened via tap
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    final data = _extractDataMap(message);
    _handleNotificationNavigation(data);
  });

  // Foreground messages -> convert to local notification so user can tap it
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final title = message.notification?.title ?? 'LGBT TOGO';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    final data = _extractDataMap(message);
    final payload = json.encode(data);

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const platformDetails = NotificationDetails(android: androidDetails);

    // show local notification so user can tap it (payload holds routing info)
    flutterLocalNotificationsPlugin.show(
      message.hashCode,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  });
}

/// Handles routing for notification payloads (data contains keys like 'screen','feedId','commentId')
void _handleNotificationNavigation(Map<String, String> data) {
  if (data.isEmpty) return;

  final screen = (data['screen'] ?? '').toString();
  final feedId = (data['feedId'] ?? data['parentcontentId'] ?? '').toString();
  final commentId = (data['commentId'] ?? data['contentId'] ?? '').toString();

  debugPrint(
    'Notification navigation request: screen=$screen feedId=$feedId commentId=$commentId',
  );

  // Only handling comment/post deep links here - extend as needed.
  if (screen == 'comments' && feedId.isNotEmpty) {
    // Use same navigation pattern you already use for deep links:
    // 1) make Dashboard the root
    // 2) push '/post/{feedId}' on top
    try {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );

      // Attach pending comment id to DeepLinkHolder so target screen can pick it up
      if (commentId.isNotEmpty) {
        DeepLinkHolder.pendingPostId = feedId;
        DeepLinkHolder.pendingCommentId = commentId;
      } else {
        DeepLinkHolder.pendingPostId = feedId;
        DeepLinkHolder.pendingCommentId = null;
      }

      // Use microtask to let the pushAndRemoveUntil finish
      Future.microtask(() {
        try {
          navigatorKey.currentState?.pushNamed('/post/$feedId');
        } catch (e) {
          // fallback: direct push
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => PostDetailScreen(postId: feedId)),
          );
        }
      });
    } catch (e, st) {
      debugPrint('Notification navigation failed: $e\n$st');
      // fallback to direct push
      try {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => PostDetailScreen(postId: feedId)),
        );
      } catch (e2) {
        debugPrint('Fallback navigation also failed: $e2');
      }
    }
  } else {
    debugPrint(
      'Unhandled notification screen or missing feedId: screen=$screen',
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<Uri?>? _linkSub;
  StreamSubscription<User?>? _authSub;

  Uri? _lastHandledUri;

  String? _pendingPostId;
  bool _pendingNavigationScheduled = false;

  int _pendingNavAttempts = 0;
  final int _maxPendingNavAttempts = 10;
  final Duration _pendingNavRetryDelay = const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _initDeepLinks();

    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      debugPrint(
        'Auth state changed. user=${user?.uid} time=${DateTime.now()}',
      );
      if (user != null) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _tryNavigatePending(),
        );
      }
    });
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    // Clear stale pending id at startup (important for hot reload / stale state)
    DeepLinkHolder.pendingPostId = null;
    DeepLinkHolder.pendingCommentId = null;
    debugPrint('DeepLinkHolder cleared at startup time=${DateTime.now()}');

    final appLinks = AppLinks();

    // Cold start: capture initial link but don't navigate immediately.
    try {
      final initial = await appLinks.getInitialLink();
      if (initial != null) {
        debugPrint('Initial deep link (captured): $initial');
        final pid = _parsePostId(initial);
        if (pid != null) {
          _pendingPostId = pid;
          DeepLinkHolder.pendingPostId = pid;
          if (!_pendingNavigationScheduled) {
            _pendingNavigationScheduled = true;
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _tryNavigatePending(),
            );
          }
        } else {
          debugPrint('No post id parsed from initial link: $initial');
        }
      }
    } catch (e, st) {
      debugPrint('getInitialLink error: $e\n$st');
    }

    // Listen while app is running:
    _linkSub = appLinks.uriLinkStream.listen(
      (uri) {
        if (uri == null) return;
        debugPrint('onAppLink received: $uri');

        if (_lastHandledUri?.toString() == uri.toString()) {
          debugPrint('duplicate link ignored.');
          return;
        }
        _lastHandledUri = uri;

        final pid = _parsePostId(uri);
        if (pid != null) {
          // set global holder so Splash can detect pending deep-link
          DeepLinkHolder.pendingPostId = pid;
          _navigateToPostSafely(pid);
        } else {
          debugPrint('No post id found in uri: $uri');
        }
      },
      onError: (err) {
        debugPrint('uriLinkStream error: $err');
      },
    );
  }

  String? _parsePostId(Uri uri) {
    try {
      final segs = uri.pathSegments;
      final idx = segs.indexOf('post');
      if (idx != -1 && idx + 1 < segs.length) return segs[idx + 1];

      if (uri.fragment.isNotEmpty) {
        try {
          final frag = Uri.parse(uri.fragment);
          final fsegs = frag.pathSegments;
          final fidx = fsegs.indexOf('post');
          if (fidx != -1 && fidx + 1 < fsegs.length) return fsegs[fidx + 1];
        } catch (_) {}
      }

      if (uri.queryParameters.containsKey('id'))
        return uri.queryParameters['id'];
    } catch (e) {
      debugPrint('Error parsing post id: $e');
    }
    return null;
  }

  void _navigateToPostSafely(String postId) {
    if (_pendingPostId == postId && _pendingNavigationScheduled) {
      debugPrint('Already pending navigation to same id: $postId');
      return;
    }

    _pendingPostId = postId;
    _pendingNavAttempts = 0;
    _pendingNavigationScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) => _tryNavigatePending());
  }

  void _tryNavigatePending() {
    if (_pendingPostId == null) return;

    final nav = navigatorKey.currentState;
    final currentUser = FirebaseAuth.instance.currentUser;

    debugPrint(
      '_tryNavigatePending attempt=$_pendingNavAttempts nav=${nav != null} user=${currentUser?.uid} pending=$_pendingPostId time=${DateTime.now()}',
    );

    // Toggle based on whether you require auth before opening deep-link posts.
    const bool requireAuth = true;

    if (nav != null && (!requireAuth || currentUser != null)) {
      final id = _pendingPostId!;
      // clear pending early to avoid races
      _pendingPostId = null;
      DeepLinkHolder.pendingPostId = null;
      _pendingNavigationScheduled = false;
      _pendingNavAttempts = 0;

      debugPrint(
        'Navigating to post/$id now. Setting Dashboard as root then pushing post.',
      );

      try {
        // 1) Replace entire stack with Dashboard as root
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
          (route) => false,
        );

        // 2) Push PostDetail on top of Dashboard. Use microtask to let stack settle.
        Future.microtask(() {
          try {
            navigatorKey.currentState?.pushNamed('/post/$id');
          } catch (e, st) {
            debugPrint(
              'Failed to push post/$id after setting Dashboard root: $e\n$st',
            );
            // fallback: direct push with MaterialPageRoute
            navigatorKey.currentState?.push(
              MaterialPageRoute(builder: (_) => PostDetailScreen(postId: id)),
            );
          }
        });
      } catch (e, st) {
        debugPrint('Deep-link nav error (fallback to simple push): $e\n$st');
        try {
          nav?.pushNamed('/post/$id');
        } catch (_) {
          nav?.push(
            MaterialPageRoute(builder: (_) => PostDetailScreen(postId: id)),
          );
        }
      }

      return;
    }

    // Not ready yet - retry
    _pendingNavAttempts++;
    if (_pendingNavAttempts <= _maxPendingNavAttempts) {
      Future.delayed(_pendingNavRetryDelay, () {
        if (_pendingPostId != null) _tryNavigatePending();
      });
    } else {
      debugPrint(
        'Giving up pending navigation after $_pendingNavAttempts attempts for id=$_pendingPostId',
      );
      _pendingPostId = null;
      _pendingNavigationScheduled = false;
    }
  }

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
          home: const SplashScreen(),
          onGenerateRoute: (settings) {
            final name = settings.name ?? '/';
            if (name.startsWith('/post/')) {
              final id = name.replaceFirst('/post/', '');
              return MaterialPageRoute(
                builder: (_) => PostDetailScreen(postId: id),
                settings: settings,
              );
            }
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          },
        );
      },
    );
  }
}
