// lib/main.dart
import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// your project imports
import 'package:lgbt_togo/Features/Screens/Chat/observer.dart';
import 'package:lgbt_togo/Features/Screens/Dashboard/post_details.dart';
import 'package:lgbt_togo/Features/Screens/Splash/splash.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// 🔧 Background message handler
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
  debugPrint = (String? message, {int? wrapWidth}) {};

  await Localizer.loadLanguage();
  await Firebase.initializeApp();

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

  @override
  void initState() {
    super.initState();
    _initDeepLinks();

    // Listen to auth changes. When user becomes non-null, try pending navigation.
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      debugPrint('Auth state changed. user=${user?.uid}');
      if (user != null) {
        // Try navigation after next frame so UI is ready
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
    final appLinks = AppLinks();

    // Cold start
    try {
      final initial = await appLinks.getInitialLink();
      if (initial != null) {
        debugPrint('Initial deep link: $initial');
        _handleIncomingUri(initial);
      }
    } catch (e, st) {
      debugPrint('getInitialLink error: $e\n$st');
    }

    // Listen while running
    _linkSub = appLinks.uriLinkStream.listen(
      (uri) {
        if (uri != null) {
          debugPrint('onAppLink: $uri');
          _handleIncomingUri(uri);
        }
      },
      onError: (err) {
        debugPrint('uriLinkStream error: $err');
      },
    );
  }

  void _handleIncomingUri(Uri uri) {
    debugPrint('HANDLE URI -> $uri');

    // avoid duplicate handling
    if (_lastHandledUri?.toString() == uri.toString()) return;
    _lastHandledUri = uri;

    final postId = _parsePostId(uri);
    if (postId != null) {
      _navigateToPostSafely(postId);
    } else {
      debugPrint('No post id found in uri: $uri');
    }
  }

  // keep your existing parsing logic
  String? _parsePostId(Uri uri) {
    // pathSegments (/post/123)
    final segs = uri.pathSegments;
    final idx = segs.indexOf('post');
    if (idx != -1 && idx + 1 < segs.length) return segs[idx + 1];

    // fragment (#/post/123)
    if (uri.fragment.isNotEmpty) {
      try {
        final frag = Uri.parse(uri.fragment);
        final segs = frag.pathSegments;
        final idx = segs.indexOf('post');
        if (idx != -1 && idx + 1 < segs.length) return segs[idx + 1];
      } catch (_) {}
    }

    // query (?id=123)
    return uri.queryParameters['id'];
  }

  /// If navigator is ready AND user is signed-in, navigate immediately.
  /// Otherwise store pending id and try later (after auth or first frame).
  void _navigateToPostSafely(String postId) {
    final nav = navigatorKey.currentState;
    final currentUser = FirebaseAuth.instance.currentUser;

    debugPrint(
      'navigateToPostSafely called. navReady=${nav != null}, user=${currentUser?.uid}',
    );

    // If nav available and user present -> navigate immediately
    if (nav != null && currentUser != null) {
      nav.pushNamed('/post/$postId');
      _pendingPostId = null;
      _pendingNavigationScheduled = false;
      return;
    }

    // otherwise schedule for later (either nav becomes ready, or auth happens)
    _pendingPostId = postId;
    if (!_pendingNavigationScheduled) {
      _pendingNavigationScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _tryNavigatePending(),
      );
    }
  }

  void _tryNavigatePending() {
    if (_pendingPostId == null) return;
    final nav = navigatorKey.currentState;
    final currentUser = FirebaseAuth.instance.currentUser;

    debugPrint(
      '_tryNavigatePending: nav=${nav != null}, user=${currentUser?.uid}',
    );

    // Only navigate when both nav and currentUser are present
    if (nav != null && currentUser != null) {
      final id = _pendingPostId!;
      _pendingPostId = null;
      _pendingNavigationScheduled = false;
      nav.pushNamed('/post/$id');
    } else {
      // If you want posts to be viewable without auth, uncomment this:
      // if (nav != null) {
      //   final id = _pendingPostId!;
      //   _pendingPostId = null;
      //   _pendingNavigationScheduled = false;
      //   nav.pushNamed('/post/$id');
      // }
      // Otherwise wait for auth listener to call _tryNavigatePending again.
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


/*class _MyAppState extends State<MyApp> {
  StreamSubscription<Uri?>? _linkSub;
  Uri? _lastHandledUri;
  String? _pendingPostId;
  bool _pendingNavigationScheduled = false;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    final appLinks = AppLinks();

    // Cold start
    try {
      final initial = await appLinks.getInitialLink();
      if (initial != null) _handleIncomingUri(initial);
    } catch (_) {}

    // Listen while running
    _linkSub = appLinks.uriLinkStream.listen((uri) {
      if (uri != null) _handleIncomingUri(uri);
    });
  }

  void _handleIncomingUri(Uri uri) {
    if (_lastHandledUri?.toString() == uri.toString()) return;
    _lastHandledUri = uri;

    final postId = _parsePostId(uri);
    if (postId != null) {
      _navigateToPost(postId);
    }
  }

  String? _parsePostId(Uri uri) {
    // pathSegments (/post/123)
    final segs = uri.pathSegments;
    final idx = segs.indexOf('post');
    if (idx != -1 && idx + 1 < segs.length) return segs[idx + 1];

    // fragment (#/post/123)
    if (uri.fragment.isNotEmpty) {
      try {
        final frag = Uri.parse(uri.fragment);
        final segs = frag.pathSegments;
        final idx = segs.indexOf('post');
        if (idx != -1 && idx + 1 < segs.length) return segs[idx + 1];
      } catch (_) {}
    }

    // query (?id=123)
    return uri.queryParameters['id'];
  }

  void _navigateToPost(String postId) {
    final nav = navigatorKey.currentState;
    if (nav != null) {
      nav.pushNamed('/post/$postId');
    } else {
      _pendingPostId = postId;
      if (!_pendingNavigationScheduled) {
        _pendingNavigationScheduled = true;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _tryNavigatePending(),
        );
      }
    }
  }

  void _tryNavigatePending() {
    if (_pendingPostId != null && navigatorKey.currentState != null) {
      navigatorKey.currentState?.pushNamed('/post/${_pendingPostId!}');
      _pendingPostId = null;
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
*/