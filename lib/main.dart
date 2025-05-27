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

  runApp(
    MaterialApp(
      navigatorKey: navigatorKey,

      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(),
    ),
  );
}
