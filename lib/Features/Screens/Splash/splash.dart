// lib/Features/Screens/Splash/splash.dart
import 'package:lgbt_togo/Features/Screens/Dashboard/home_page.dart';
import 'package:lgbt_togo/Features/Screens/Notifications/service.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';
import 'package:lgbt_togo/Features/Utils/deep_link/deep_link_holder.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // initialize push notifications (safe to await)
      await PushNotificationService().initialize();
    } catch (e, st) {
      debugPrint('PushNotificationService.initialize error: $e\n$st');
    }

    try {
      await checkLoginStatus();
    } catch (e, st) {
      debugPrint('checkLoginStatus error: $e\n$st');
      // If something unexpected happens, fallback to showing onboarding after a small delay
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LanguageSelectionScreen(isBack: false),
            ),
          );
        });
      }
    }
  }

  Future<void> checkLoginStatus() async {
    final isLoggedIn = await AuthHelper.isUserLoggedIn();

    // debug log to help verify startup ordering during testing
    debugPrint(
      'Splash.checkLoginStatus isLoggedIn=$isLoggedIn pending=${DeepLinkHolder.pendingPostId} time=${DateTime.now()}',
    );

    if (!mounted) return;
    if (DeepLinkHolder.pendingPostId != null) {
      debugPrint(
        'Splash: detected pending deep-link for post=${DeepLinkHolder.pendingPostId}, skipping pushReplacement.',
      );
      return;
    }

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePageScreen(isBack: false),
        ),
        // DashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LanguageSelectionScreen(isBack: false),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
