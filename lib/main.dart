import 'package:lgbt_togo/Features/Screens/Splash/splash.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint = (String? message, {int? wrapWidth}) {};

  // localizer
  await Localizer.loadLanguage();

  // Initialize Firebase
  await Firebase.initializeApp();

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
      valueListenable: Localizer.langNotifier, // listen to language change
      builder: (context, langCode, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          theme: ThemeData.light(),
          debugShowCheckedModeBanner: false,
          home: OnboardingScreen(),
          // home: SplashScreen(),
        );
      },
    );
  }
}
