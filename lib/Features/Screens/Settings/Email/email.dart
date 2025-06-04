import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  bool storeEmailNewRequest = true;
  bool storeEmailAcceptRequest = true;
  bool storeEmailTwoStep = true;

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
      'email',
    );
    GlobalUtils().customLog("🔔 Email: $notificationSettings");

    // parse
    storeEmailNewRequest = notificationSettings!["new_friend_request"];
    storeEmailAcceptRequest = notificationSettings["accept_reject_request"];
    storeEmailTwoStep = notificationSettings["chat_message"];

    setState(() {
      screenLoader = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title:
            "${Localizer.get(AppText.email.key)} ${Localizer.get(AppText.setting.key)}",
        backgroundColor: AppColor().kNavigationColor,
        backIcon: Icons.chevron_left,
        showBackButton: true,
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: screenLoader ? SizedBox() : _UIKit(),
    );
  }

  Column _UIKit() {
    return Column(
      children: [
        CustomNotificationTile(
          title: Localizer.get(AppText.notificationFriendRequest.key),
          selectedOption: storeEmailNewRequest,
          onUpdate: (val) {
            setState(() {
              final boolValue = val.toString().toLowerCase() == 'true';
              storeEmailNewRequest = boolValue;
              updateNotificationSettingsInFirebase(
                "new_friend_request",
                boolValue,
              );
            });
          },
        ),
        CustomNotificationTile(
          title: Localizer.get(AppText.notificationAcceptReject.key),
          selectedOption: storeEmailAcceptRequest,

          onUpdate: (val) {
            setState(() {
              final boolValue = val.toString().toLowerCase() == 'true';
              storeEmailAcceptRequest = boolValue;
              updateNotificationSettingsInFirebase(
                "accept_reject_request",
                boolValue,
              );
            });
          },
        ),
        CustomNotificationTile(
          title: Localizer.get(AppText.notificationSendMessage.key),
          selectedOption: storeEmailTwoStep,

          onUpdate: (val) {
            setState(() {
              final boolValue = val.toString().toLowerCase() == 'true';
              storeEmailTwoStep = boolValue;
              updateNotificationSettingsInFirebase("chat_message", boolValue);
            });
          },
        ),
      ],
    );
  }

  // update on firebase
  void updateNotificationSettingsInFirebase(String key, bool value) async {
    GlobalUtils().customLog('notifications.$key:$value');
    GlobalUtils().customLog(FIREBASE_AUTH_UID());
    await SettingsService()
        .updateSettings(FIREBASE_AUTH_UID(), {'notifications.$key': value})
        .then((v) {
          GlobalUtils().customLog("Notification settings updated");
        });
  }
}
