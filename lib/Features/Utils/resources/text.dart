import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class AppText {
  static const login = AppTextEntry("LOGIN", "Login", "Connexion");
  static const createAnAccount = AppTextEntry(
    "CREATE_AN_ACCOUNT",
    "Create an account",
    "Mot de passe",
  );
  static const email = AppTextEntry("EMAIL", "Email", "E-mail");
  static const password = AppTextEntry("PASSWORD", "******", "Mot de passe");
  static const firstName = AppTextEntry("FIRST_NAME", "First name", "E-mail");
  static const phone = AppTextEntry("PHONE", "Phone", "E-mail");
  static const signIn = AppTextEntry("SIGNIN", "Sign In", "Mot de passe");
  static const signUp = AppTextEntry("SIGNUP", "Sign Up", "Mot de passe");
  static const facebook = AppTextEntry("FACEBOOK", "Facebook", "Mot de passe");
  static const google = AppTextEntry("GOOGLE", "Google", "Mot de passe");
  static const completeProfile = AppTextEntry(
    "COMPLETE_PROFILE",
    "Complete profile",
    "Mot de passe",
  );
  static const submit = AppTextEntry("SUBMIT", "Submit", "Mot de passe");

  static const dob = AppTextEntry("DOB", "DOB", "Mot de passe");
  static const gender = AppTextEntry("GENDER", "Gender", "Mot de passe");
  static const sex = AppTextEntry("SEX", "Sex orientation", "Mot de passe");
  static const location = AppTextEntry("LOCATION", "Location", "Mot de passe");
  static const interestIn = AppTextEntry(
    "INTEREST_IN",
    "Interest in",
    "Mot de passe",
  );
  static const aboutYourself = AppTextEntry(
    "ABOUT_YOURSELF",
    "About yourself",
    "Mot de passe",
  );

  static const dashboard = AppTextEntry(
    "DASHBOARD",
    "Dashboard",
    "Mot de passe",
  );

  static const userProfile = AppTextEntry(
    "USER_PROFILE",
    "User Profile",
    "Mot de passe",
  );
  static const searchFriend = AppTextEntry(
    "SEARCH_FRIEND",
    "Search friend",
    "Mot de passe",
  );

  static const friend = AppTextEntry("FRIEND", "friend", "Mot de passe");

  static const chat = AppTextEntry("CHAT", "Chat", "Mot de passe");
  static const notification = AppTextEntry(
    "NOTIFICATION",
    "Notifications",
    "Mot de passe",
  );

  static const unblockFriend = AppTextEntry(
    "UNBLOCK_FRIEND",
    "Unblock friend",
    "Mot de passe",
  );

  static const privacy = AppTextEntry("PRIVACY", "Privacy", "Mot de passe");
  static const setting = AppTextEntry("SETTING", "Setting", "Mot de passe");

  // alert message
  static const tapAnywhereToDismiss = AppTextEntry(
    "TAP_ANY_WHERE_TO_DISMISS",
    "Google",
    "Mot de passe",
  );

  // SETTINGS

  // privacy
  static const privacyProfile = AppTextEntry(
    "PRIVACY_PROFILE",
    "Who can view your profile?",
    "Mot de passe",
  );
  static const privacyPost = AppTextEntry(
    "PRIVACY_POST",
    "Who can view your post?",
    "Mot de passe",
  );
  static const privacyFriend = AppTextEntry(
    "PRIVACY_FRIEND",
    "Who can view your friends?",
    "Mot de passe",
  );
  static const privacyPicture = AppTextEntry(
    "PRIVACY_PROFILE_PICTURE",
    "Who can view your profile picture?",
    "Mot de passe",
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
