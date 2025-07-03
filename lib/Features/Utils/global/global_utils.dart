import 'package:intl/intl.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class GlobalUtils {
  String URL_TERMS = "https://www.lgbt.tg/mentions-legales";
  String URL_PRIVACY = "https://www.lgbt.tg/mentions-legales";
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

  // convert age
  String calculateAge(String dob) {
    try {
      DateTime birthDate = DateTime.parse(dob);
      DateTime today = DateTime.now();

      int age = today.year - birthDate.year;

      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }

      return "$age years";
    } catch (e) {
      return ""; // or return "Unknown" if you prefer
    }
  }

  static String manageKeys(String values) {
    // GlobalUtils().customLog("Values: ==> $values");

    if (values == "" || values == "0" || values == "1" || values == "Friends") {
      return "Friends";
    }
    if (values == "2" || values == "Private") {
      return "Private";
    }
    if (values == "3" || values == "Public") {
      return "Public";
    }
    return "Unknown"; // Optional fallback
  }

  static String manageKeysForServer(String values) {
    // GlobalUtils().customLog("Values: ==> $values");

    if (values == "" || values == "0" || values == "1" || values == "Friends") {
      return "1";
    }
    if (values == "2" || values == "Private") {
      return "2";
    }
    if (values == "3" || values == "Public") {
      return "3";
    }
    return "1"; // Optional fallback
  }

  // notification / email
  static String manageKeysSwitch(String values) {
    if (values == "" || values == "0" || values == "False") {
      return "False";
    }
    if (values == "" || values == "1" || values == "True") {
      return "True";
    }

    return "False";
  }

  static String manageKeysSwitchServer(String values) {
    if (values == "" || values == "0" || values == "False") {
      return "0";
    }
    if (values == "" || values == "1" || values == "True") {
      return "1";
    }

    return "0";
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

  // current timestamp
  int currentTimeStamp() {
    int timeStamp = DateTime.now().millisecondsSinceEpoch;
    return timeStamp;
  }

  static String convertTimeStampTo12HourFormat(int timestamp) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('hh:mm a').format(dateTime);
  }

  String timeAgo(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays >= 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else if (difference.inDays >= 1) {
      return difference.inDays == 1
          ? '1 day ago'
          : '${difference.inDays} days ago';
    } else if (difference.inHours >= 1) {
      return difference.inHours == 1
          ? '1 hour ago'
          : '${difference.inHours} hours ago';
    } else if (difference.inMinutes >= 1) {
      return difference.inMinutes == 1
          ? '1 minute ago'
          : '${difference.inMinutes} minutes ago';
    } else {
      return 'just now';
    }
  }
}
