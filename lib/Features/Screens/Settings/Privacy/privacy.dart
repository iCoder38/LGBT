import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  //
  String storePrivacyProfile = '1';
  String storePrivacyPost = '1';
  String storePrivacyFriends = '1';
  String storePrivacyPicture = '1';
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
      'privacy',
    );
    GlobalUtils().customLog("🔔 Notifications: $notificationSettings");

    // parse
    storePrivacyProfile = notificationSettings!["profile"];
    storePrivacyPost = notificationSettings["post"];
    storePrivacyFriends = notificationSettings["friends"];
    storePrivacyPicture = notificationSettings["profile_picture"];*/

    // call get setting
    callGetSettings(context);
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
          selectedOption: GlobalUtils.manageKeys(
            storePrivacyProfile.toString(),
          ),
          // storePrivacyProfile,
          onUpdate: (val) async {
            storePrivacyProfile = val;
            GlobalUtils().customLog("Selected is: $val");
            final result = GlobalUtils.manageKeysForServer(val);
            GlobalUtils().customLog("Selected is2: $result");
            // hit server
            await Future.delayed(Duration(milliseconds: 400));
            AlertsUtils.showLoaderUI(
              context: context,
              title: Localizer.get(AppText.pleaseWait.key),
            );
            callEditPrivacySeeting(context, "P_S_Profile", result.toString());
            setState(() {});
          },
        ),
        CustomPrivacyTile(
          title: Localizer.get(AppText.privacyPost.key),
          selectedOption: GlobalUtils.manageKeys(storePrivacyPost.toString()),
          // ,
          onUpdate: (val) async {
            storePrivacyPost = val;
            // updatePrivacySettingsInFirebase("post", val);
            GlobalUtils().customLog("Selected is: $val");
            final result = GlobalUtils.manageKeysForServer(val);
            GlobalUtils().customLog("Selected is2: $result");
            // hit server
            await Future.delayed(Duration(milliseconds: 400));
            AlertsUtils.showLoaderUI(
              context: context,
              title: Localizer.get(AppText.pleaseWait.key),
            );
            callEditPrivacySeeting(context, "P_S_Post", result.toString());
            setState(() {});
          },
        ),
        CustomPrivacyTile(
          title: Localizer.get(AppText.privacyFriend.key),
          selectedOption: GlobalUtils.manageKeys(
            storePrivacyFriends.toString(),
          ),
          // ,
          onUpdate: (val) async {
            storePrivacyFriends = val;
            // updatePrivacySettingsInFirebase("friends", val);
            GlobalUtils().customLog("Selected is: $val");
            final result = GlobalUtils.manageKeysForServer(val);
            GlobalUtils().customLog("Selected is2: $result");
            // hit server
            await Future.delayed(Duration(milliseconds: 400));
            AlertsUtils.showLoaderUI(
              context: context,
              title: Localizer.get(AppText.pleaseWait.key),
            );
            callEditPrivacySeeting(context, "P_S_Friends", result.toString());
            setState(() {});
          },
        ),
        CustomPrivacyTile(
          title: Localizer.get(AppText.privacyPicture.key),
          selectedOption: GlobalUtils.manageKeys(
            storePrivacyPicture.toString(),
          ),
          // ,
          onUpdate: (val) async {
            storePrivacyPicture = val;
            // updatePrivacySettingsInFirebase("profile_picture", val);
            GlobalUtils().customLog("Selected is: $val");
            final result = GlobalUtils.manageKeysForServer(val);
            GlobalUtils().customLog("Selected is2: $result");
            // hit server
            await Future.delayed(Duration(milliseconds: 400));
            AlertsUtils.showLoaderUI(
              context: context,
              title: Localizer.get(AppText.pleaseWait.key),
            );
            callEditPrivacySeeting(
              context,
              "P_S_Profile_picture",
              result.toString(),
            );
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
    // friends = 1
    // private = 2
    // public = 3
    storePrivacyProfile = response["data"]["P_S_Profile"].toString();
    storePrivacyPost = response["data"]["P_S_Post"].toString();
    storePrivacyFriends = response["data"]["P_S_Friends"].toString();
    storePrivacyPicture = response["data"]["P_S_Profile_picture"].toString();

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
