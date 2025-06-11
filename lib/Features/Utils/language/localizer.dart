import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class Localizer {
  static String _langCode = 'en';

  // Notifier to trigger UI rebuilds
  static final ValueNotifier<String> langNotifier = ValueNotifier<String>(
    _langCode,
  );

  static Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _langCode = prefs.getString('language') ?? 'en';
    langNotifier.value = _langCode; // notify listeners
  }

  static Future<void> setLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);
    _langCode = langCode;
    langNotifier.value = langCode; // notify listeners
  }

  static String get(String key) {
    final entry = AppText.all[key];
    if (entry == null) return key;
    return _langCode == 'fr' ? entry.fr : entry.en;
  }

  static String get currentLanguage => _langCode;
}
