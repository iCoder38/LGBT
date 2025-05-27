import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class AppText {
  static const login = AppTextEntry("LOGIN", "Login", "Connexion");
  static const email = AppTextEntry("EMAIL", "Email", "E-mail");
  static const password = AppTextEntry("PASSWORD", "Password", "Mot de passe");

  // on boarding
  static const onboard1Heading = AppTextEntry(
    "ONBOARD1_HEADING",
    "WHO ARE WE?",
    "QUI SOMMES-NOUS ?",
  );
  static const onboard1Message = AppTextEntry(
    "ONBOARD1_MESSAGE",
    "The Togo LGBT community (LGBT-TG) is a non-profit association that defends the rights of sexual minorities...",
    "La communauté LGBT du Togo (LGBT-TG) est une association à but non lucratif...",
  );
  static const onboard2Heading = AppTextEntry(
    "ONBOARD2_HEADING",
    "OUR HISTORY",
    "NOTRE HISTOIRE",
  );
  static const onboard2Message = AppTextEntry(
    "ONBOARD2_MESSAGE",
    "Indeed, the idea of creating the Club of 7 Days Association was born in 2005 by a group of seven...",
    "L'idée de créer le Club des 7 jours est née en 2005 par un groupe de sept...",
  );
  static const onboard3Heading = AppTextEntry(
    "ONBOARD3_HEADING",
    "BECOME A PARTNER",
    "DEVENEZ PARTENAIRE",
  );
  static const onboard3Message = AppTextEntry(
    "ONBOARD3_MESSAGE",
    "Display your support for the LGBT-TG community by sharing your logo on our website...",
    "Affichez votre soutien à la communauté LGBT-TG en partageant votre logo...",
  );
  static const onboard4Heading = AppTextEntry(
    "ONBOARD4_HEADING",
    "OUR HUMBLE BEGINNINGS",
    "NOS DÉBUTS MODESTES",
  );
  static const onboard4Message = AppTextEntry(
    "ONBOARD4_MESSAGE",
    "Originally known as 'C7' or 'The Club of 7 Days'...",
    "À l'origine connu sous le nom de 'C7' ou 'Le Club des 7 Jours'...",
  );
  static const onboard5Heading = AppTextEntry(
    "ONBOARD5_HEADING",
    "OUR MISSION",
    "NOTRE MISSION",
  );
  static const onboard5Message = AppTextEntry(
    "ONBOARD5_MESSAGE",
    "Working towards the physical, social and psychological well-being...",
    "Œuvrant pour le bien-être physique, social et psychologique...",
  );

  static final Map<String, AppTextEntry> all = {
    login.key: login,
    email.key: email,
    password.key: password,
    onboard1Heading.key: onboard1Heading,
    onboard1Message.key: onboard1Message,
    onboard2Heading.key: onboard2Heading,
    onboard2Message.key: onboard2Message,
    onboard3Heading.key: onboard3Heading,
    onboard3Message.key: onboard3Message,
    onboard4Heading.key: onboard4Heading,
    onboard4Message.key: onboard4Message,
    onboard5Heading.key: onboard5Heading,
    onboard5Message.key: onboard5Message,
  };
}
