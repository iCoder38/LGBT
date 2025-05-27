import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';
import 'package:lgbt_togo/Features/Utils/resources/text.dart';

class Localizer {
  static String _langCode = 'en';

  static Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _langCode = prefs.getString('language') ?? 'en';
  }

  static String get(String key) {
    return _localizedValues[_langCode]?[key] ?? key;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'textOnboard1Heading': AppText().kEN_Onboarding1Heading,
      'textOnboard1Message': AppText().kEN_Onboarding1Message,

      'textOnboard2Heading': AppText().kEN_Onboarding2Heading,
      'textOnboard2Message': AppText().kEN_Onboarding2Message,

      'textOnboard3Heading': AppText().kEN_Onboarding3Heading,
      'textOnboard3Message': AppText().kEN_Onboarding3Message,

      'textOnboard4Heading': AppText().kEN_Onboarding4Heading,
      'textOnboard4Message': AppText().kEN_Onboarding4Message,

      'textOnboard5Heading': AppText().kEN_Onboarding5Heading,
      'textOnboard5Message': AppText().kEN_Onboarding5Message,
    },
    'fr': {
      'welcome': 'BIENVENUE',
      'whoAreWe': 'QUI SOMMES-NOUS ?',
      'description':
          'La communauté LGBT du Togo (LGBT-TG) est une association à but non lucratif qui défend les droits des minorités sexuelles...',
      'getStarted': 'Commencer maintenant',
    },
  };
}
