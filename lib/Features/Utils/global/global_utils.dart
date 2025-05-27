import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class GlobalUtils {
  // ====================== LOGGER ===============================================
  // =============================================================================

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

  // ====================== SVG ===============================================
  // =============================================================================

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
}
