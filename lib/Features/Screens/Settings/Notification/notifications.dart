import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool storeNotificationNewFriendRequest = true;
  bool storeNotificationAcceptOrReject = true;
  bool storeNotificationSendMessage = true;
  bool storeNotificationLikeProfile = true;

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
      'notifications',
    );
    GlobalUtils().customLog("🔔 Notifications: $notificationSettings");

    // parse
    storeNotificationNewFriendRequest =
        notificationSettings!["new_friend_request"];
    storeNotificationAcceptOrReject =
        notificationSettings["accept_reject_request"];
    storeNotificationSendMessage = notificationSettings["chat_message"];
    storeNotificationLikeProfile = notificationSettings["like_profile"];

    setState(() {
      screenLoader = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title:
            "${Localizer.get(AppText.notification.key)} ${Localizer.get(AppText.setting.key)}",
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
          selectedOption: storeNotificationNewFriendRequest,
          onUpdate: (val) {
            setState(() {
              final boolValue = val.toString().toLowerCase() == 'true';
              storeNotificationNewFriendRequest = boolValue;
              updateNotificationSettingsInFirebase(
                "new_friend_request",
                boolValue,
              );
            });
          },
        ),
        CustomNotificationTile(
          title: Localizer.get(AppText.notificationAcceptReject.key),
          selectedOption: storeNotificationAcceptOrReject,

          onUpdate: (val) {
            setState(() {
              final boolValue = val.toString().toLowerCase() == 'true';
              storeNotificationAcceptOrReject = boolValue;
              updateNotificationSettingsInFirebase(
                "accept_reject_request",
                boolValue,
              );
            });
          },
        ),
        CustomNotificationTile(
          title: Localizer.get(AppText.notificationSendMessage.key),
          selectedOption: storeNotificationSendMessage,

          onUpdate: (val) {
            setState(() {
              final boolValue = val.toString().toLowerCase() == 'true';
              storeNotificationSendMessage = boolValue;
              updateNotificationSettingsInFirebase("chat_message", boolValue);
            });
          },
        ),
        CustomNotificationTile(
          title: Localizer.get(AppText.notificationLikeProfile.key),
          selectedOption: storeNotificationLikeProfile,

          onUpdate: (val) {
            setState(() {
              final boolValue = val.toString().toLowerCase() == 'true';
              storeNotificationLikeProfile = boolValue;
              updateNotificationSettingsInFirebase("like_profile", boolValue);
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
