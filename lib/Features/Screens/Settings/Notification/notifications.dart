import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  String storeNotificationNewFriendRequest = '';
  String storeNotificationAcceptOrReject = '';
  String storeNotificationSendMessage = '';
  String storeNotificationLikeProfile = '';

  bool screenLoader = true;

  @override
  void initState() {
    super.initState();
    callSettings();
  }

  void callSettings() async {
    /* final uid = FIREBASE_AUTH_UID();

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
*/

    callGetSettings(context);
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
      body: screenLoader ? SizedBox() : _UIKIT(),
    );
  }

  Column _UIKIT() {
    return Column(
      children: [
        CustomNotificationTile(
          title: Localizer.get(AppText.notificationFriendRequest.key),
          selectedOption: GlobalUtils.manageKeysSwitch(
            storeNotificationNewFriendRequest.toString(),
          ),
          // ,
          onUpdate: (val) async {
            storeNotificationNewFriendRequest = val;
            GlobalUtils().customLog("Selected is: $val");
            final result = GlobalUtils.manageKeysSwitchServer(val);
            GlobalUtils().customLog("Selected is2: $result");
            // hit server
            await Future.delayed(Duration(milliseconds: 400));
            AlertsUtils.showLoaderUI(
              context: context,
              title: Localizer.get(AppText.pleaseWait.key),
            );
            callEditPrivacySeeting(
              context,
              "N_S_Friend_request",
              result.toString(),
            );
          },
        ),
        CustomNotificationTile(
          title: Localizer.get(AppText.notificationAcceptReject.key),
          selectedOption: GlobalUtils.manageKeysSwitch(
            storeNotificationAcceptOrReject.toString(),
          ),

          onUpdate: (val) async {
            storeNotificationAcceptOrReject = val;
            GlobalUtils().customLog("Selected is: $val");
            final result = GlobalUtils.manageKeysSwitchServer(val);
            GlobalUtils().customLog("Selected is2: $result");
            // hit server
            await Future.delayed(Duration(milliseconds: 400));
            AlertsUtils.showLoaderUI(
              context: context,
              title: Localizer.get(AppText.pleaseWait.key),
            );
            callEditPrivacySeeting(
              context,
              "N_S_Friend_accept",
              result.toString(),
            );
          },
        ),
        CustomNotificationTile(
          title: Localizer.get(AppText.notificationSendMessage.key),
          selectedOption: GlobalUtils.manageKeysSwitch(
            storeNotificationSendMessage.toString(),
          ),

          onUpdate: (val) async {
            storeNotificationSendMessage = val;
            GlobalUtils().customLog("Selected is: $val");
            final result = GlobalUtils.manageKeysSwitchServer(val);
            GlobalUtils().customLog("Selected is2: $result");
            // hit server
            await Future.delayed(Duration(milliseconds: 400));
            AlertsUtils.showLoaderUI(
              context: context,
              title: Localizer.get(AppText.pleaseWait.key),
            );
            callEditPrivacySeeting(
              context,
              "N_S_Friend_chat",
              result.toString(),
            );
          },
        ),
        CustomNotificationTile(
          title: Localizer.get(AppText.notificationLikeProfile.key),
          selectedOption: GlobalUtils.manageKeysSwitch(
            storeNotificationLikeProfile.toString(),
          ),

          onUpdate: (val) async {
            storeNotificationLikeProfile = val;
            GlobalUtils().customLog("Selected is: $val");
            final result = GlobalUtils.manageKeysSwitchServer(val);
            GlobalUtils().customLog("Selected is2: $result");
            // hit server
            await Future.delayed(Duration(milliseconds: 400));
            AlertsUtils.showLoaderUI(
              context: context,
              title: Localizer.get(AppText.pleaseWait.key),
            );
            callEditPrivacySeeting(
              context,
              "N_S_like_profile",
              result.toString(),
            );
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
          CustomFlutterToastUtils.showToast(
            message: Localizer.get(AppText.updated.key),
            backgroundColor: AppColor().GREEN,
          );
        });
  }

  // ----------------------- APIs ---------------------------
  Future<void> callGetSettings(context) async {
    final userData = await UserLocalStorage.getUserData();
    GlobalUtils().customLog(userData['userId'].toString());
    // dismiss keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadGetSettings(
        action: ApiAction().GET_SETTINGS,
        userId: userData['userId'].toString(),
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog(response);
      // save value here
      _getParseAndManage(response);
    } else {
      GlobalUtils().customLog("Failed to view stories: $response");
      Navigator.pop(context);
      // show error popup
      AlertsUtils().showExceptionPopup(
        context: context,
        message: response['msg'].toString(),
      );
    }
  }

  void _getParseAndManage(response) {
    // false = 0, true = 1
    storeNotificationNewFriendRequest = response["data"]["N_S_Friend_request"]
        .toString();
    storeNotificationAcceptOrReject = response["data"]["N_S_Friend_accept"]
        .toString();
    storeNotificationSendMessage = response["data"]["N_S_Friend_chat"]
        .toString();
    storeNotificationLikeProfile = response["data"]["N_S_like_profile"]
        .toString();

    setState(() {
      screenLoader = false;
    });
  }

  Future<void> callEditPrivacySeeting(context, String key, String value) async {
    final userData = await UserLocalStorage.getUserData();
    GlobalUtils().customLog(userData['userId'].toString());
    // dismiss keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadPrivacySetting(
        action: ApiAction().SETTINGS,
        userId: userData['userId'].toString(),
        key: key,
        value: value,
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog(response);
      Navigator.pop(context);
      CustomFlutterToastUtils.showToast(
        message: response["msg"],
        backgroundColor: AppColor().GREEN,
      );
    } else {
      GlobalUtils().customLog("Failed to view stories: $response");
      Navigator.pop(context);
      // show error popup
      AlertsUtils().showExceptionPopup(
        context: context,
        message: response['msg'].toString(),
      );
    }
  }
}
