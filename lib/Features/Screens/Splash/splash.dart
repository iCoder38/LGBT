import 'package:lgbt_togo/Features/Screens/Notifications/service.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Always call super.initState() first in Flutter
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await PushNotificationService().initialize();
    await checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final isLoggedIn = await AuthHelper.isUserLoggedIn();

    if (!mounted) return; // ✅ Prevents navigation if widget disposed

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
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
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // ✅ Better UX than empty screen
      ),
    );
  }
}
