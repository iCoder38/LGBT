import 'dart:ui';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class AppText {
  static const login = AppTextEntry("LOGIN", "Login", "Connexion");

  static const createAnAccount = AppTextEntry(
    "CREATE_AN_ACCOUNT",
    "Create an account",
    "Créer un compte",
  );
  static const cancel = AppTextEntry("CANCEL", "Cancel", "Annuler");
  static const editProfile = AppTextEntry(
    "EDIT_PROFILE",
    "Edit profile",
    "Modifier le profil",
  );

  static const blocked = AppTextEntry("BLOCKED", "Blocked", "Bloqué");
  static const blockedMessage = AppTextEntry(
    "BLOCKED_MESSAGE",
    "Good job! You have no blocked friend.",
    "Bravo ! Vous n'avez aucun ami bloqué.",
  );

  static const forgotPassword = AppTextEntry(
    "FORGOT_PASSWORD",
    "Forgot password",
    "Mot de passe oublié",
  );

  static const dntHaveAnAccount = AppTextEntry(
    "DON_T_HAVE_AN_AACOUNT",
    "Don't have an account",
    "Vous n'avez pas de compte ?",
  );

  static const pleaseWait = AppTextEntry(
    "PLEASE_WAIT",
    "Please wait",
    "Veuillez patienter",
  );
  static const postLimitAlert = AppTextEntry(
    "POST_LIMIT_ALERT",
    "Upgrade your membership to unlock up to 50 posts! 🚀 As a free user you can post only once — but with premium you also earn points, increase your level, and enjoy more benefits.",
    "Améliorez votre abonnement pour débloquer jusqu’à 50 publications ! 🚀 En tant qu’utilisateur gratuit, vous ne pouvez publier qu’une seule fois — mais avec le premium, vous gagnez aussi des points, augmentez votre niveau et profitez de plus d’avantages.",
  );
  static const publish = AppTextEntry("PUBLISH", "Publish", "Publier");
  static const noImagesFound = AppTextEntry(
    "NO_IMAGES_FOUND",
    "Add New photo.",
    "Aucune image trouvée.",
  );
  static const uploadMultipleImages = AppTextEntry(
    "UPLOAD_MULTIPLE_IMAGES",
    "Upload multiple images",
    "Importer plusieurs images",
  );
  static const uploadFiveImages = AppTextEntry(
    "UPLOAD_FIVE_IMAGES",
    "Upload up to 5 images at a time",
    "Téléchargez jusqu'à 5 images à la fois",
  );

  static const noChatYet = AppTextEntry(
    "NO_CHAT_YET",
    "No chats yet. Start new chat.",
    "Pas encore de conversations. Commencez une nouvelle discussion.",
  );
  static const writeSomething = AppTextEntry(
    "WRITE_SOMTHING",
    "Write Something",
    "Écrivez quelque chose",
  );

  static const noMessageYet = AppTextEntry(
    "NO_MESSAGE_YET",
    "No Message Yet",
    "Aucun message pour l’instant",
  );

  static const freeTrialMembership = AppTextEntry(
    "FREE_TRIAL_MEMBERSHIP",
    "Free Trial Membership",
    "Adhésion d’essai gratuite",
  );

  static const searchAndView = AppTextEntry(
    "SEARCH_AND_VIEW",
    "Search and view basic details",
    "Rechercher et afficher les détails de base",
  );

  static const limitedContent = AppTextEntry(
    "LIMITED_CONTENT",
    "Access to limited content",
    "Accès à un contenu limité",
  );

  static const basicSupport = AppTextEntry(
    "BASIC_SUPPORT",
    "Basic Support",
    "Assistance de base",
  );

  static const premiumMonthlyPlan = AppTextEntry(
    "PREMIUM_MONTHLY_PLAN",
    "Premium Monthly Plan: Monthly: \$9",
    "Forfait mensuel Premium : 9 \$ / mois",
  );

  static const myProfile = AppTextEntry(
    "MY_PROFILE",
    "My Profile",
    "Mon profil",
  );
  static const myStory = AppTextEntry("MY_STORY", "My Story", "Mon histoire");

  static const whyAreYouHere = AppTextEntry(
    "WHY_ARE_YOUR_HERE",
    "Why are you here",
    "Pourquoi es-tu ici ?",
  );

  static const viewFullProfile = AppTextEntry(
    "VIEW_FULL_PROFILE",
    "View full profile and Photos",
    "Voir le profil complet et les photos",
  );

  static const accessUnlimitedContent = AppTextEntry(
    "ACCESS_UNLIMITED_CONTENT",
    "Access to unlimited content",
    "Accès à un contenu illimité",
  );

  static const accessPremiumContent = AppTextEntry(
    "ACCESS_PREMIUM_CONTENT",
    "Access to the premium content",
    "Accès au contenu premium",
  );

  static const prioritySupport = AppTextEntry(
    "PRIORITY_SUPPORT",
    "Priority Support",
    "Assistance prioritaire",
  );
  static const subscribe = AppTextEntry("SUBSCRIBE", "Subscribe", "S'abonner");

  static const selectAtLeastOneImage = AppTextEntry(
    "SELECT_AT_LEAST_ONE_IMAGE",
    "Please select at least one image.",
    "Veuillez sélectionner au moins une image.",
  );

  // Shorter alternatives:
  static const uploadImagesShort = AppTextEntry(
    "UPLOAD_IMAGES_SHORT",
    "Upload images",
    "Importer des images",
  );

  // Plan title
  static const premiumYearlyPlan = AppTextEntry(
    "PREMIUM_YEARLY_PLAN",
    "Premium Yearly Plan: Yearly: \$99",
    "Forfait annuel Premium : 99 \$ / an",
  );

  // Features

  static const accessLimitedContent = AppTextEntry(
    "ACCESS_LIMITED_CONTENT",
    "Access to limited content",
    "Accès à un contenu limité",
  );

  static const earlyAccess = AppTextEntry(
    "EARLY_ACCESS_NEW_FEATURES",
    "Early access to new features",
    "Accès anticipé aux nouvelles fonctionnalités",
  );

  static const reportPost = AppTextEntry(
    "REPORT_POST",
    "Report post",
    "Signaler la publication",
  );
  static const confirm = AppTextEntry("CONFIRM", "Confirm", "Confirmer");

  static const like = AppTextEntry("LIKE", "Like", "J'aime");
  static const likes = AppTextEntry("LIKES", "Likes", "J'aime");

  static const whatsInYourMind = AppTextEntry(
    "WHAT_IS_IN_YOU_MIND",
    "What's in your mind",
    "Qu'avez-vous en tête ?",
  );

  static const sharedaText = AppTextEntry(
    "SHARED_A_TEXT",
    "Shared a text",
    "A partagé un texte",
  );
  static const sharedaPhoto = AppTextEntry(
    "SHARED_A_PHOTO",
    "Shared a photo",
    "A partagé une photo",
  );
  static const sharedaVideo = AppTextEntry(
    "SHARED_A_VIDEO",
    "Shared a video",
    "A partagé une vidéo",
  );

  static const email = AppTextEntry("EMAIL", "Email", "E-mail");

  static const password = AppTextEntry("PASSWORD", "******", "Mot de passe");

  static const firstName = AppTextEntry("FIRST_NAME", "First name", "Prénom");

  static const phone = AppTextEntry("PHONE", "Phone", "Téléphone");

  static const signIn = AppTextEntry("SIGNIN", "Sign In", "Se connecter");

  static const signUp = AppTextEntry("SIGNUP", "Sign Up", "S'inscrire");

  static const facebook = AppTextEntry("FACEBOOK", "Facebook", "Facebook");

  static const google = AppTextEntry("GOOGLE", "Google", "Google");

  static const updated = AppTextEntry("UPDATED", "Update", "Mettre à jour");

  static const completeProfile = AppTextEntry(
    "COMPLETE_PROFILE",
    "Complete profile",
    "Compléter le profil",
  );

  static const acceptOur = AppTextEntry(
    "ACCEPT_OUT",
    "Accept our terms",
    "Accepter nos conditions",
  );

  static const termsAnd = AppTextEntry(
    "TERMS",
    "Terms and conditions",
    "Conditions générales",
  );

  static const web = AppTextEntry("WEB", "Web", "Web");

  static const ourMission = AppTextEntry(
    "OUR_MISSION",
    "Our mission",
    "Notre mission",
  );

  static const submit = AppTextEntry("SUBMIT", "Submit", "Soumettre");

  static const writeYourBiography = AppTextEntry(
    "WRITE_YOUR_BIO",
    "Write your biography in a few words…",
    "Écrivez votre biographie en quelques mots…",
  );

  static const whatsYourStory = AppTextEntry(
    "WHATS_YOUR_STORY",
    "What's your story (max.300)",
    "Quelle est votre histoire ? (max. 300)",
  );

  static const whatDoYouLike = AppTextEntry(
    "WHAT_DO_YOU_LIKE",
    "What do you like?",
    "Qu'est-ce que vous aimez ?",
  );

  static const biography = AppTextEntry(
    "YOUR_BIOGRAPHY",
    "Your biography",
    "Votre biographie",
  );

  static const biographyFooter = AppTextEntry(
    "BIOGRAPHY_FOOTER",
    "Write your biography in a few words…",
    "Écrivez votre biographie en quelques mots…",
  );

  static const thought = AppTextEntry(
    "THOUGHT_OF_THE_DAY",
    "Thought of the day",
    "Pensée du jour",
  );

  static const thoughtMessage = AppTextEntry(
    "THOUGHT_MESSAGE",
    "Tell us what you think today. Your idea will be immediately seen by thousands of online users",
    "Partagez ce que vous pensez aujourd'hui. Votre idée sera immédiatement visible par des milliers d'utilisateurs en ligne",
  );

  static const logoutMessage = AppTextEntry(
    "LOGOUT_MESSAGE",
    "Are you sure you want to logout?",
    "Êtes-vous sûr de vouloir vous déconnecter ?",
  );

  static const deletePhotoMessage = AppTextEntry(
    "DELETE_PHOTO_MESSAGE",
    "Are you sure you want to delete this photo?",
    "Êtes-vous sûr de vouloir supprimer cette photo ?",
  );
  static const yesDelete = AppTextEntry(
    "YES_DELETE",
    "Yes, Delete",
    "Oui, Supprimer",
  );

  static const yesLogout = AppTextEntry(
    "YES_LOGOUT",
    "Yes, Logout",
    "Oui, Se déconnecter",
  );

  static const logout = AppTextEntry("LOGOUT", "Logout", "Se déconnecter");

  static const membership = AppTextEntry(
    "MEMBERSHIP",
    "Membership",
    "Adhésion",
  );

  final freeTrialFeatures = [
    "Search and view basic details",
    "Access to limited content",
    "Basic Support",
    "Priority Support",
  ];

  static const organizationMembership = AppTextEntry(
    "ORGANIZATION_MEMBERSHIP",
    "Organization Membership",
    "Adhésion de l'organisation",
  );

  static const currentCity = AppTextEntry(
    "CURRENT_CITY",
    "Current city",
    "Ville actuelle",
  );

  static const iAm = AppTextEntry("I_AM", "I am", "Je suis");

  static const yourBelief = AppTextEntry(
    "YOUR_BELIEF",
    "Your belief",
    "Vos croyances",
  );
  static const years = AppTextEntry("YEARS", "Years", "Ans");
  static const dob = AppTextEntry("DOB", "Date of birth", "Date de naissance");
  static const gender = AppTextEntry("GENDER", "Gender", "Genre");
  static const justNow = AppTextEntry("JUST_NOW", "Just now", "À l'instant");
  static const minAgo = AppTextEntry("MIN_AGO", "min ago", "min");
  static const hrAgo = AppTextEntry("HR_AGO", "hr ago", "h");
  static const yesterday = AppTextEntry("YESTERDAY", "Yesterday", "Hier");
  static const daysAgo = AppTextEntry("DAYS_AGO", "days ago", "jours");
  static const weeksAgo = AppTextEntry("WEEKS_AGO", "wk ago", "sem");
  static const monthsAgo = AppTextEntry("MONTHS_AGO", "mo ago", "mois");
  static const yearsAgo = AppTextEntry("YEARS_AGO", "yr ago", "ans");

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

  static const preferedLanguage = AppTextEntry(
    "PREFERED_LANGUAGE",
    "Preferred language",
    "Langue préférée",
  );

  static const language = AppTextEntry("LANGUAGE", "Language", "Langue");

  static const preferedLanguageAlert = AppTextEntry(
    "PREFERED_LANGUAGE_ALERT",
    'Please select the languages that you would like to use in app.',
    "Veuillez sélectionner les langues que vous souhaitez utiliser dans l'application.",
  );

  static const alreadyHaveAnAccount = AppTextEntry(
    "ALREADY_HAVE_AN_ACCOUNT",
    'Already have an account.',
    "Vous avez déjà un compte.",
  );

  static const post = AppTextEntry("POST", "Post", "Publication");
  static const levelPoints = AppTextEntry(
    "LEVEL_POINTS",
    "Level || Points",
    "Niveau || Points",
  );

  static const comments = AppTextEntry("COMMENTS", "Comments", "Commentaires");

  static const continueB = AppTextEntry("CONTINUE", "Continue", "Continuer");

  static const userProfile = AppTextEntry(
    "USER_PROFILE",
    "User Profile",
    "Profil utilisateur",
  );
  static const sharee = AppTextEntry("SHARE", "Share", "Partager");
  static const unknown = AppTextEntry("UNKNOWN", "Unknown", "Inconnu");
  static const searchFriend = AppTextEntry(
    "SEARCH_FRIEND",
    "Search friend",
    "Rechercher un ami",
  );

  static const enterPostTitle = AppTextEntry(
    "ENTER_POST_TITLE",
    "What's in your mind",
    "Saisissez le titre de la publication",
  );

  static const uploadImage = AppTextEntry("UPLOAD_IMAGE", "Post", "Image");

  static const uploadVideo = AppTextEntry("UPLOAD_VIDEO", "Video", "Vidéo");

  static const uploadPost = AppTextEntry(
    "UPLOAD_POST",
    "Upload post",
    "Publier",
  );

  static const requests = AppTextEntry("REQUESTS", "Requests", "Demandes");
  static const youDntHaveAnyRequest = AppTextEntry(
    "DONT_HAVE_ANY_REQUEST",
    "You don't have any request now.",
    "Vous n'avez aucune demande pour le moment.",
  );
  static const youDntHaveAnyFriend = AppTextEntry(
    "DONT_HAVE_ANY_FRIEND",
    "You don't have any friend. Add friend to see them here.",
    "Vous n'avez aucun ami. Ajoutez des amis pour les voir ici.",
  );

  static const friend = AppTextEntry("FRIEND", "Friend", "Ami");

  static const chat = AppTextEntry("CHAT", "Chat", "Discussion");
  static const album = AppTextEntry("ALBUM", "Album", "Album");
  static const addAlbum = AppTextEntry(
    "ADD_ALBUM",
    "Add album",
    "Ajouter un album",
  );
  static const albumVisibility = AppTextEntry(
    "ALBUM_VISIBILITY",
    "Album Visibility",
    "Visibilité de l'album",
  );

  static const tapMultipleItems = AppTextEntry(
    "TAP_MULTIPLE_ITEMS",
    "Tap multiple items to mark ✓",
    "Touchez plusieurs éléments pour marquer ✓",
  );

  static const tapOneItem = AppTextEntry(
    "TAP_ONE_ITEM",
    "Tap one item to mark ✓",
    "Touchez un élément pour marquer ✓",
  );

  static const changePassword = AppTextEntry(
    "CHANGE_PASSWORD",
    "Change password",
    "Changer le mot de passe",
  );

  static const aboutLGBT = AppTextEntry(
    "ABOUT_LGBT",
    "About LGBT+TOGO",
    "À propos de LGBT+TOGO",
  );

  static const help = AppTextEntry("HELP", "Help", "Aide");

  static const notification = AppTextEntry(
    "NOTIFICATION",
    "Notification",
    "Notification",
  );

  static const notifications = AppTextEntry(
    "NOTIFICATIONS",
    "Notifications",
    "Notifications",
  );

  static const unblockFriend = AppTextEntry(
    "UNBLOCK_FRIEND",
    "Unblock friend",
    "Débloquer un ami",
  );

  static const passwordNotMatched = AppTextEntry(
    "PASSWORD_NOT_MATCHED",
    "Password not matched",
    "Les mots de passe ne correspondent pas",
  );

  static const privacy = AppTextEntry("PRIVACY", "Privacy", "Confidentialité");

  static const setting = AppTextEntry("SETTING", "Setting", "Paramètres");

  static const tapAnywhereToDismiss = AppTextEntry(
    "TAP_ANY_WHERE_TO_DISMISS",
    "Tap anywhere to dismiss",
    "Appuyez n'importe où pour fermer",
  );

  static const privacyProfile = AppTextEntry(
    "PRIVACY_PROFILE",
    "Who can view your profile?",
    "Qui peut voir votre profil ?",
  );
  static const trueValue = AppTextEntry("TRUE_VALUE", "True", "Vrai");

  static const falseValue = AppTextEntry("FALSE_VALUE", "False", "Faux");

  static const friends = AppTextEntry("FRIENDS", "Friends", "Amis");

  static const private = AppTextEntry("PRIVATE", "Private", "Privé");

  static const public = AppTextEntry("PUBLIC", "Public", "Public");

  static const gifts = AppTextEntry("GIFTS", "Gifts", "Cadeaux");

  static const privacyPost = AppTextEntry(
    "PRIVACY_POST",
    "Who can view your post?",
    "Qui peut voir vos publications ?",
  );

  static const generalSettings = AppTextEntry(
    "GENERAL_SETTINGS",
    "General Settings",
    "Paramètres généraux",
  );

  static const privacySettings = AppTextEntry(
    "PRIVACY_SETTINGS",
    "Privacy Settings",
    "Paramètres de confidentialité",
  );

  static const notificationSettings = AppTextEntry(
    "NOTIFICATION_SETTINGS",
    "Notification Settings",
    "Paramètres de notification",
  );

  static const emailSettings = AppTextEntry(
    "EMAIL_SETTINGS",
    "Email Settings",
    "Paramètres de messagerie",
  );

  static const languages = AppTextEntry("LANGUAGES", "Languages", "Langues");

  static const deleteAccount = AppTextEntry(
    "DELETE_ACCOUNT",
    "Delete Account",
    "Supprimer le compte",
  );
  static const deletePhoto = AppTextEntry(
    "DELETE_PHOTO",
    "Delete Photo",
    "Supprimer le compte",
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

  static const notificationFriendRequest = AppTextEntry(
    "NOTIFICATION_FRIEND_REQUEST",
    "When any user sends a new friend request.",
    "Lorsqu'un utilisateur envoie une nouvelle demande d'ami.",
  );

  static const notificationAcceptReject = AppTextEntry(
    "NOTIFICATION_ACCEPT_REJECT",
    "When any user accepts/rejects their friend request.",
    "Lorsqu'un utilisateur accepte/rejette une demande d'ami.",
  );

  static const notificationSendMessage = AppTextEntry(
    "NOTIFICATION_SEND_MESSAGE",
    "When any user sends a message.",
    "Lorsqu'un utilisateur envoie un message.",
  );

  static const notificationLikeProfile = AppTextEntry(
    "NOTIFICATION_LIKE_PROFILE",
    "When any user liked your profile.",
    "Lorsqu'un utilisateur a aimé votre profil.",
  );

  static const emailNewRequest = AppTextEntry(
    "EMAIL_NEW_REQUEST",
    "When any user sends a new friend request.",
    "Lorsqu'un utilisateur envoie une nouvelle demande d'ami.",
  );

  static const emailAcceptReject = AppTextEntry(
    "EMAIL_ACCEPT_REJECT",
    "When any user accepts/rejects a friend request.",
    "Lorsqu'un utilisateur accepte/rejette une demande d'ami.",
  );

  static const emailTwoStep = AppTextEntry(
    "EMAIL_TWO_STEP",
    "Two step auth for account deletion",
    "Authentification en deux étapes pour la suppression de compte",
  );

  static const onboard1Heading = AppTextEntry(
    "HOW_T0_START",
    "HOW TO START",
    "COMMENT COMMENCER1",
  );

  static const getStartedNow = AppTextEntry(
    "GET_STARTED_NOW",
    "Get Started Now",
    "Commencer maintenant",
  );

  static const next = AppTextEntry("NEXT", "Next", "Suivant");

  static const skip = AppTextEntry("SKIP", "Skip", "Passer");

  static const onboard1Message = AppTextEntry(
    "ONBOARD1_MESSAGE",
    "Create Your Profile. Make Friends and Securing Safely. Building Relation with Respect.",
    "Créez votre profil. Faites des amis et assurez votre sécurité. Construisez des relations avec respect.",
  );

  static const onboard2Heading = AppTextEntry(
    "ONBOARD2_HEADING",
    "OUR HISTORY",
    "NOTRE HISTOIRE",
  );

  static const onboard2Message = AppTextEntry(
    "ONBOARD2_MESSAGE",
    "Indeed, the idea of creating the Club of 7 Days Association was born in 2005 by a group of seven...",
    "En effet, l'idée de créer l'association 'Club of 7 Days' est née en 2005 par un groupe de sept amis...",
  );

  static const onboard3Heading = AppTextEntry(
    "ONBOARD3_HEADING",
    "BECOME A PARTNER",
    "DEVENEZ PARTENAIRE",
  );

  static const onboard3Message = AppTextEntry(
    "ONBOARD3_MESSAGE",
    "Display your support for the LGBT-TG community by sharing your logo on our website...",
    "Affichez votre soutien à la communauté LGBT-TG en partageant votre logo sur notre site web...",
  );

  static const onboard4Heading = AppTextEntry(
    "ONBOARD4_HEADING",
    "OUR HUMBLE BEGINNINGS",
    "NOS DÉBUTS MODESTES",
  );

  static const onboard4Message = AppTextEntry(
    "ONBOARD4_MESSAGE",
    'Originally known as "C7" or "The Club of 7 Days," was founded by a group of seven friends who wanted to...',
    "À l'origine connu sous le nom de « C7 » ou « Le Club des 7 Jours », il a été fondé par un groupe de sept amis qui voulaient...",
  );

  static const onboard5Heading = AppTextEntry(
    "ONBOARD5_HEADING",
    "OUR MISSION",
    "NOTRE MISSION",
  );

  static const onboard5Message = AppTextEntry(
    "ONBOARD5_MESSAGE",
    "Working towards the physical, social and psychological well-being...",
    "Œuvrer pour le bien-être physique, social et psychologique...",
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
    updated.key: updated,
    passwordNotMatched.key: passwordNotMatched,

    whatsYourStory.key: whatsYourStory,
    whyAreYouHere.key: whyAreYouHere,
    whatDoYouLike.key: whatDoYouLike,
    dob.key: dob,
    gender.key: gender,
    sex.key: sex,
    location.key: location,
    interestIn.key: interestIn,
    aboutYourself.key: aboutYourself,
    biography.key: biography,
    thought.key: thought,
    currentCity.key: currentCity,
    iAm.key: iAm,
    yourBelief.key: yourBelief,
    biographyFooter.key: biographyFooter,
    thoughtMessage.key: thoughtMessage,
    logoutMessage.key: logoutMessage,

    dashboard.key: dashboard,
    userProfile.key: userProfile,
    searchFriend.key: searchFriend,
    chat.key: chat,
    notification.key: notification,
    notifications.key: notifications,
    unblockFriend.key: unblockFriend,
    friend.key: friend,
    privacy.key: privacy,

    setting.key: setting,
    privacyProfile.key: privacyProfile,
    privacyPost.key: privacyPost,
    privacyFriend.key: privacyFriend,
    privacyPicture.key: privacyPicture,

    notificationFriendRequest.key: notificationFriendRequest,
    notificationAcceptReject.key: notificationAcceptReject,
    notificationSendMessage.key: notificationSendMessage,
    notificationLikeProfile.key: notificationLikeProfile,

    emailNewRequest.key: emailNewRequest,
    emailAcceptReject.key: emailAcceptReject,
    emailTwoStep.key: emailTwoStep,

    pleaseWait.key: pleaseWait,

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

    comments.key: comments,
    web.key: web,
    post.key: post,
    preferedLanguage.key: preferedLanguage,
    preferedLanguageAlert.key: preferedLanguageAlert,
    continueB.key: continueB,
    forgotPassword.key: forgotPassword,
    dntHaveAnAccount.key: dntHaveAnAccount,
    acceptOur.key: acceptOur,
    termsAnd.key: termsAnd,
    alreadyHaveAnAccount.key: alreadyHaveAnAccount,
    ourMission.key: ourMission,
    writeYourBiography.key: writeYourBiography,
    membership.key: membership,
    changePassword.key: changePassword,
    aboutLGBT.key: aboutLGBT,
    language.key: language,
    help.key: help,
    logout.key: logout,
    editProfile.key: editProfile,
    requests.key: requests,
    album.key: album,
    addAlbum.key: addAlbum,
    deletePhotoMessage.key: deletePhotoMessage,
    gifts.key: gifts,
    organizationMembership.key: organizationMembership,

    friends.key: friends,
    private.key: private,
    public.key: public,
    unknown.key: unknown,

    generalSettings.key: generalSettings,
    privacySettings.key: privacySettings,
    notificationSettings.key: notificationSettings,
    emailSettings.key: emailSettings,
    languages.key: languages,
    deleteAccount.key: deleteAccount,

    trueValue.key: trueValue,
    falseValue.key: falseValue,
    cancel.key: cancel,
    reportPost.key: reportPost,
    confirm.key: confirm,
    whatsInYourMind.key: whatsInYourMind,

    sharedaText.key: sharedaText,
    sharedaPhoto.key: sharedaPhoto,
    sharedaVideo.key: sharedaVideo,

    like.key: like,
    likes.key: likes,
    sharee.key: sharee,

    enterPostTitle.key: enterPostTitle,
    uploadImage.key: uploadImage,
    uploadVideo.key: uploadVideo,
    uploadPost.key: uploadPost,

    years.key: years,
    justNow.key: justNow,
    minAgo.key: minAgo,
    hrAgo.key: hrAgo,
    yesterday.key: yesterday,
    daysAgo.key: daysAgo,
    weeksAgo.key: weeksAgo,
    monthsAgo.key: monthsAgo,
    yearsAgo.key: yearsAgo,

    tapMultipleItems.key: tapMultipleItems,
    tapOneItem.key: tapOneItem,

    albumVisibility.key: albumVisibility,
    noImagesFound.key: noImagesFound,
    yesDelete.key: yesDelete,
    uploadMultipleImages.key: uploadMultipleImages,
    uploadImagesShort.key: uploadImagesShort,
    uploadFiveImages.key: uploadFiveImages,
    selectAtLeastOneImage.key: selectAtLeastOneImage,

    freeTrialMembership.key: freeTrialMembership,
    searchAndView.key: searchAndView,
    limitedContent.key: limitedContent,
    basicSupport.key: basicSupport,
    premiumMonthlyPlan.key: premiumMonthlyPlan,

    viewFullProfile.key: viewFullProfile,
    accessUnlimitedContent.key: accessUnlimitedContent,
    accessPremiumContent.key: accessPremiumContent,
    prioritySupport.key: prioritySupport,
    premiumYearlyPlan.key: premiumYearlyPlan,
    accessLimitedContent.key: accessLimitedContent,
    earlyAccess.key: earlyAccess,
    subscribe.key: subscribe,
    yesLogout.key: yesLogout,
    publish.key: publish,
    youDntHaveAnyRequest.key: youDntHaveAnyRequest,
    youDntHaveAnyFriend.key: youDntHaveAnyFriend,
    noChatYet.key: noChatYet,
    blocked.key: blocked,
    blockedMessage.key: blockedMessage,
    postLimitAlert.key: postLimitAlert,
    myProfile.key: myProfile,
    getStartedNow.key: getStartedNow,
    next.key: next,
    skip.key: skip,
    deletePhoto.key: deletePhoto,
    writeSomething.key: writeSomething,
    noMessageYet.key: noMessageYet,
    levelPoints.key: levelPoints,
    myStory.key: myStory,
    whyAreYouHere.key: whyAreYouHere,
  };
}
