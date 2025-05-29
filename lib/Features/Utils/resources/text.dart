import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class AppText {
  static const login = AppTextEntry("LOGIN", "Login", "Connexion");
  static const createAnAccount = AppTextEntry(
    "CREATE_AN_ACCOUNT",
    "Create an account",
    "Créer un compte",
  );
  static const email = AppTextEntry("EMAIL", "Email", "E-mail");
  static const password = AppTextEntry("PASSWORD", "******", "Mot de passe");
  static const firstName = AppTextEntry("FIRST_NAME", "First name", "Prénom");
  static const phone = AppTextEntry("PHONE", "Phone", "Téléphone");
  static const signIn = AppTextEntry("SIGNIN", "Sign In", "Se connecter");
  static const signUp = AppTextEntry("SIGNUP", "Sign Up", "S'inscrire");
  static const facebook = AppTextEntry("FACEBOOK", "Facebook", "Facebook");
  static const google = AppTextEntry("GOOGLE", "Google", "Google");
  static const completeProfile = AppTextEntry(
    "COMPLETE_PROFILE",
    "Complete profile",
    "Compléter le profil",
  );
  static const submit = AppTextEntry("SUBMIT", "Submit", "Soumettre");

  static const dob = AppTextEntry("DOB", "DOB", "Date de naissance");
  static const gender = AppTextEntry("GENDER", "Gender", "Genre");
  static const sex = AppTextEntry(
    "SEX",
    "Sex orientation",
    "Orientation sexuelle",
  );
  static const location = AppTextEntry("LOCATION", "Location", "Localisation");
  static const interestIn = AppTextEntry(
    "INTEREST_IN",
    "Interest in",
    "Intéressé par",
  );
  static const aboutYourself = AppTextEntry(
    "ABOUT_YOURSELF",
    "About yourself",
    "À propos de vous",
  );

  static const dashboard = AppTextEntry(
    "DASHBOARD",
    "Dashboard",
    "Tableau de bord",
  );

  static const userProfile = AppTextEntry(
    "USER_PROFILE",
    "User Profile",
    "Profil utilisateur",
  );
  static const searchFriend = AppTextEntry(
    "SEARCH_FRIEND",
    "Search friend",
    "Rechercher un ami",
  );

  static const friend = AppTextEntry("FRIEND", "friend", "Ami");

  static const chat = AppTextEntry("CHAT", "Chat", "Discussion");
  static const notification = AppTextEntry(
    "NOTIFICATION",
    "Notifications",
    "Notifications",
  );

  static const unblockFriend = AppTextEntry(
    "UNBLOCK_FRIEND",
    "Unblock friend",
    "Débloquer un ami",
  );

  static const privacy = AppTextEntry("PRIVACY", "Privacy", "Confidentialité");
  static const setting = AppTextEntry("SETTING", "Setting", "Paramètre");

  // alert message
  static const tapAnywhereToDismiss = AppTextEntry(
    "TAP_ANY_WHERE_TO_DISMISS",
    "Google",
    "Appuyez n'importe où pour fermer",
  );

  // SETTINGS

  // privacy
  static const privacyProfile = AppTextEntry(
    "PRIVACY_PROFILE",
    "Who can view your profile?",
    "Qui peut voir votre profil ?",
  );
  static const privacyPost = AppTextEntry(
    "PRIVACY_POST",
    "Who can view your post?",
    "Qui peut voir vos publications ?",
  );
  static const privacyFriend = AppTextEntry(
    "PRIVACY_FRIEND",
    "Who can view your friends?",
    "Qui peut voir vos amis ?",
  );
  static const privacyPicture = AppTextEntry(
    "PRIVACY_PROFILE_PICTURE",
    "Who can view your profile picture?",
    "Qui peut voir votre photo de profil ?",
  );

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
    signIn.key: signIn,
    google.key: google,
    facebook.key: facebook,
    createAnAccount.key: createAnAccount,
    firstName.key: firstName,
    phone.key: phone,
    signUp.key: signUp,
    tapAnywhereToDismiss.key: tapAnywhereToDismiss,
    completeProfile.key: completeProfile,
    submit.key: submit,

    dob.key: dob,
    gender.key: gender,
    sex.key: sex,
    location.key: location,
    interestIn.key: interestIn,
    aboutYourself.key: aboutYourself,

    dashboard.key: dashboard,
    userProfile.key: userProfile,
    searchFriend.key: searchFriend,
    chat.key: chat,
    notification.key: notification,
    unblockFriend.key: unblockFriend,
    friend.key: friend,
    privacy.key: privacy,

    setting.key: setting,
    privacyProfile.key: privacyProfile,
    privacyPost.key: privacyPost,
    privacyFriend.key: privacyFriend,
    privacyPicture.key: privacyPicture,

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
