import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  //
  String storePrivacyProfile = 'Friends';
  String storePrivacyPost = 'Friends';
  String storePrivacyFriends = 'Friends';
  String storePrivacyPicture = 'Friends';
  bool screenLoader = true;

  @override
  void initState() {
    super.initState();
    callSettings();
  }

  void callSettings() async {
    final uid = FIREBASE_AUTH_UID();

    final notificationSettings = await SettingsService().getSettingsSection(
      uid,
      'privacy',
    );
    GlobalUtils().customLog("🔔 Notifications: $notificationSettings");

    // parse
    storePrivacyProfile = notificationSettings!["profile"];
    storePrivacyPost = notificationSettings["post"];
    storePrivacyFriends = notificationSettings["friends"];
    storePrivacyPicture = notificationSettings["profile_picture"];

    setState(() {
      screenLoader = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title:
            "${Localizer.get(AppText.privacy.key)} ${Localizer.get(AppText.setting.key)}",
        backgroundColor: AppColor().kNavigationColor,
        backIcon: Icons.chevron_left,
        showBackButton: true,
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: screenLoader ? SizedBox() : _UIKIT(),
    );
  }

  Column _UIKIT() {
    return Column(
      children: [
        CustomPrivacyTile(
          title: Localizer.get(AppText.privacyProfile.key),
          selectedOption: storePrivacyProfile,
          onUpdate: (val) {
            setState(() {
              storePrivacyProfile = val;
              updatePrivacySettingsInFirebase("profile", val);
            });
          },
        ),
        CustomPrivacyTile(
          title: Localizer.get(AppText.privacyPost.key),
          selectedOption: storePrivacyPost,
          onUpdate: (val) {
            setState(() {
              storePrivacyPost = val;
              updatePrivacySettingsInFirebase("post", val);
            });
          },
        ),
        CustomPrivacyTile(
          title: Localizer.get(AppText.privacyFriend.key),
          selectedOption: storePrivacyFriends,
          onUpdate: (val) {
            setState(() {
              storePrivacyFriends = val;
              updatePrivacySettingsInFirebase("friends", val);
            });
          },
        ),
        CustomPrivacyTile(
          title: Localizer.get(AppText.privacyPicture.key),
          selectedOption: storePrivacyPicture,
          onUpdate: (val) {
            setState(() {
              storePrivacyPicture = val;
              updatePrivacySettingsInFirebase("profile_picture", val);
            });
          },
        ),
      ],
    );
  }

  // privacy
  // update on firebase
  void updatePrivacySettingsInFirebase(String key, String value) async {
    GlobalUtils().customLog('notifications.$key:$value');
    GlobalUtils().customLog(FIREBASE_AUTH_UID());
    await SettingsService()
        .updateSettings(FIREBASE_AUTH_UID(), {'privacy.$key': value})
        .then((v) {
          GlobalUtils().customLog("Privacy settings updated");
          CustomFlutterToastUtils.showToast(
            message: Localizer.get(AppText.updated.key),
            backgroundColor: AppColor().GREEN,
          );
        });
  }
}
