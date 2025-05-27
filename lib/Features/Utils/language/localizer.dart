import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class Localizer {
  static String _langCode = 'en';

  static Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _langCode = prefs.getString('language') ?? 'en';
  }

  static String get(String key) {
    final entry = AppText.all[key];
    if (entry == null) return key;
    return _langCode == 'fr' ? entry.fr : entry.en;
  }
}
