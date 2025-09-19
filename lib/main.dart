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
  debugPrint = (String? message, {int? wrapWidth}) {};

  await Localizer.loadLanguage();
  await Firebase.initializeApp();

  // Replace with your RevenueCat public Android SDK key
  await RevenueCatService.instance.init(
    apiKey: 'goog_TzOvaqHditUmJPiRscGfLHZgdFl',
  );
  // 2. Check entitlement at startup
  await RevenueCatService.instance.isEntitlementActive('premium');

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  try {
    await dotenv.load(fileName: ".env");
    GlobalUtils().customLog('.env loaded successfully');
  } catch (e) {
    GlobalUtils().customLog('Failed to load .env: $e');
  }

  runApp(const MyApp());
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
