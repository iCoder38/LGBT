import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  String storeEmailNewRequest = "1";
  String storeEmailAcceptRequest = '1';
  String storeEmailTwoStep = "1";

  bool screenLoader = true;

  @override
  void initState() {
    super.initState();
    callSettings();
  }

  void callSettings() async {
    /*final uid = FIREBASE_AUTH_UID();

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
    });*/
    callGetSettings(context);
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
          selectedOption: GlobalUtils.manageKeysSwitch(
            storeEmailNewRequest.toString(),
          ),
          // selectedOption: ,
          onUpdate: (val) async {
            storeEmailNewRequest = val;
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
              "E_S_Friend_request",
              result.toString(),
            );
          },
        ),
        CustomNotificationTile(
          title: Localizer.get(AppText.notificationAcceptReject.key),
          selectedOption: GlobalUtils.manageKeysSwitch(
            storeEmailAcceptRequest.toString(),
          ),
          onUpdate: (val) async {
            storeEmailAcceptRequest = val;
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
              "E_S_Friend_accept",
              result.toString(),
            );
          },
        ),
        CustomNotificationTile(
          title: Localizer.get(AppText.notificationSendMessage.key),
          selectedOption: GlobalUtils.manageKeysSwitch(
            storeEmailTwoStep.toString(),
          ),

          onUpdate: (val) async {
            storeEmailTwoStep = val;
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
              "E_S_account_delete",
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
    if (response["data"].isEmpty) {
      storeEmailNewRequest = "1";
      storeEmailAcceptRequest = '1';
      storeEmailTwoStep = "1";
    } else {
      // false = 0, true = 1
      storeEmailNewRequest = response["data"]["E_S_Friend_request"].toString();
      storeEmailAcceptRequest = response["data"]["E_S_Friend_accept"]
          .toString();
      storeEmailTwoStep = response["data"]["E_S_account_delete"].toString();
    }

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
