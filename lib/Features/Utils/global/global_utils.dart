import 'package:intl/intl.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class GlobalUtils {
  String URL_TERMS = "https://www.lgbt.tg/mentions-legales";
  String URL_PRIVACY = "https://www.lgbt.tg/mentions-legales";
  String URL_HELP = "https://www.lgbt.tg/mentions-legales";
  String URL_ORGANIZATION_MEMBERSHIP = "https://www.lgbt.tg/adhesion";
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

      return "$age ${Localizer.get(AppText.years.key)}";
    } catch (e) {
      return ""; // or return "Unknown" if you prefer
    }
  }

  static String manageKeys(String values) {
    if (values == "" || values == "0" || values == "1" || values == "Friends") {
      return Localizer.get(AppText.friends.key); // localized Friends
    }
    if (values == "2" || values == "Private") {
      return Localizer.get(AppText.private.key); // localized Private
    }
    if (values == "3" || values == "Public") {
      return Localizer.get(AppText.public.key); // localized Public
    }
    return Localizer.get(AppText.unknown.key);
  }

  static String manageKeysForServer(String values) {
    // GlobalUtils().customLog("Values: ==> $values");

    final friendsText = Localizer.get(AppText.friends.key);
    final privateText = Localizer.get(AppText.private.key);
    final publicText = Localizer.get(AppText.public.key);

    if (values == "" ||
        values == "0" ||
        values == "1" ||
        values == friendsText) {
      return "1";
    }
    if (values == "2" || values == privateText) {
      return "2";
    }
    if (values == "3" || values == publicText) {
      return "3";
    }
    return "1"; // ✅ Fallback to "Friends"
  }

  // notification / email
  /// Converts values into localized "True"/"False"
  static String manageKeysSwitch(String values) {
    if (values == "1" || values.toLowerCase() == "true") {
      return Localizer.get(AppText.trueValue.key);
    }
    if (values == "0" || values.toLowerCase() == "false") {
      return Localizer.get(AppText.falseValue.key);
    }
    // Fallback
    return Localizer.get(AppText.falseValue.key);
  }

  /// Converts localized or raw values back into "0"/"1" for server
  static String manageKeysSwitchServer(String values) {
    final trueText = Localizer.get(AppText.trueValue.key);
    final falseText = Localizer.get(AppText.falseValue.key);

    if (values == "1" || values.toLowerCase() == "true" || values == trueText) {
      return "1";
    }
    if (values == "0" ||
        values.toLowerCase() == "false" ||
        values == falseText) {
      return "0";
    }
    // Fallback
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

  /// Parse an ISO-like server time that may omit timezone info.
  /// If the string has no timezone offset, treat it as UTC (append 'Z'),
  /// then convert to local and return a friendly "time ago" string.
  String formatTimeAgoFromServer(String isoTimeString) {
    if (isoTimeString.trim().isEmpty) return '';

    DateTime parsed;
    try {
      final s = isoTimeString.trim();

      // If string already contains timezone info (Z or ±), parse directly.
      final hasOffset =
          s.endsWith('Z') ||
          s.contains(RegExp(r'[+-]\d{2}:\d{2}$')) ||
          s.contains(RegExp(r'[+-]\d{2}\d{2}$'));

      if (hasOffset) {
        parsed = DateTime.parse(s);
      } else {
        // Treat missing-offset timestamps as UTC (server sent UTC without 'Z').
        // Append 'Z' to indicate UTC before parsing.
        parsed = DateTime.parse(s + 'Z').toLocal();
      }

      // If parsed timezone was explicit and not local, convert to local for diff:
      parsed = parsed.toLocal();
    } catch (e) {
      // Fallback: return original string if parsing fails
      return isoTimeString;
    }

    final now = DateTime.now();
    final diff = now.difference(parsed);

    if (diff.inSeconds < 60) return Localizer.get(AppText.justNow.key);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} ${Localizer.get(AppText.minAgo.key)}';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} ${Localizer.get(AppText.hrAgo.key)}';
    }
    if (diff.inDays == 1) return Localizer.get(AppText.yesterday.key);
    if (diff.inDays < 7) {
      return '${diff.inDays} ${Localizer.get(AppText.daysAgo.key)}';
    }
    if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} ${Localizer.get(AppText.weeksAgo.key)}';
    }
    if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()} ${Localizer.get(AppText.monthsAgo.key)}';
    }
    return '${(diff.inDays / 365).floor()} ${Localizer.get(AppText.years.key)}';
  }
}
