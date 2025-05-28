import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class GlobalUtils {
  // ====================== DATE FORMAT ========================================
  // ===========================================================================

  String APP_DATE_FORMAT = "yyyy-MM-dd";

  // ====================== LOGGER =============================================
  // ===========================================================================

  final Logger logger = Logger(
    level: kReleaseMode ? Level.off : Level.debug,
    printer: PrettyPrinter(colors: true),
  );
  void customLog(dynamic message) {
    if (kDebugMode) {
      // print(message);
      logger.d(message);
    }
  }

  // ====================== SVG ================================================
  // ===========================================================================

  var svgPath = 'assets/svg';
  var formatSVG = 'svg';
  Widget svgImage(imageName, height, width, {ColorFilter? colorFilter}) {
    return SvgPicture.asset(
      '$svgPath/$imageName.$formatSVG',
      height: height,
      width: width,
      colorFilter:
          colorFilter ?? const ColorFilter.mode(Colors.black, BlendMode.srcIn),
    );
  }

  //
  Future<DateTime?> pickDateOfBirth(BuildContext context) async {
    final DateTime today = DateTime.now();
    final DateTime initialDate = DateTime(
      today.year - 18,
      today.month,
      today.day,
    );
    final DateTime firstDate = DateTime(1900);
    final DateTime lastDate = today;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select Date of Birth',
    );

    return picked;
  }
}
