import 'package:lgbt_togo/Features/Screens/OurMission/our_mission.dart';
// import 'package:lgbt_togo/Features/Screens/Settings/Language/languages.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  //
  String loginUserName = '';
  String loginUserAddress = '';
  var displayProfilePicture = '';
  var storeLoginUserData;
  // login user data
  var userData;
  String loginUserimage = '';

  @override
  void initState() {
    super.initState();
    callInitAPI();
  }

  void callInitAPI() async {
    userData = await UserLocalStorage.getUserData();
    loginUserimage = userData["image"] ?? "";
    GlobalUtils().customLog(loginUserimage);
    setState(() {});
  }

  void parseLoginUserdata() {}

  /*Future<Map<String, dynamic>?> getLoginResponse() async {
    final storage = FlutterSecureStorage();
    String? jsonString =
        await storage.read(key: AppResources.text.textSaveLoginResponseKey);
    if (jsonString != null) {
      // Decode the JSON string into a Map
      return jsonDecode(jsonString);
    }
    return null; // Return null if no data is found
  }*/

  /*localData() async {
    debugPrint('== LOCAL DATA ==');
    Map<String, dynamic>? loginData = await getLoginResponse();
    if (loginData != null) {
      // print("Login Data Retrieved: $loginData");
      customLog(loginData);
      loginUserName = loginData['data']['firstName'].toString();
      loginUserAddress = loginData['data']['address'].toString();
      setState(() {});
    } else {
      if (kDebugMode) {
        print("No login data found.");
      }
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: _UIBGImage(),
      // _UIKit(context),
    );
  }

  Container _UIBGImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColor().PRIMARY_COLOR,
      child: _UIKit(context),
    );
  }

  Widget _UIKit(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 80),
          Container(
            // height: 120,
            width: MediaQuery.of(context).size.width,
            color: Colors.black,
            child: ListTile(
              leading: CustomCacheImageForUserProfile(imageURL: loginUserimage),
              title: customText(
                FIREBASE_AUTH_NAME(),
                16,
                context,
                color: AppColor().kWhite,
                fontWeight: FontWeight.w600,
              ),
              subtitle: customText(
                FIREBASE_AUTH_EMAIL(),
                12,
                context,
                color: AppColor().YELLOW,
              ),
            ),
          ),
          const SizedBox(height: 10),
          buildListTile(
            title: Localizer.get(AppText.dashboard.key),
            icon: Icons.home,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen()),
              );
            },
          ),
          Divider(),
          buildListTile(
            title: Localizer.get(AppText.friend.key),
            icon: Icons.group,
            onTap: () {
              NavigationUtils.pushTo(context, FriendsScreen());
            },
          ),
          Divider(),
          buildListTile(
            title: Localizer.get(AppText.chat.key),
            icon: Icons.chat,
            onTap: () {
              NavigationUtils.pushTo(context, DialogsScreen());
            },
          ),
          Divider(),
          buildListTile(
            title: Localizer.get(AppText.membership.key),
            icon: Icons.credit_card,
            onTap: () {},
          ),
          Divider(),
          buildListTile(
            title: Localizer.get(AppText.notification.key),
            icon: Icons.notifications,
            onTap: () {
              NavigationUtils.pushTo(context, NotificationsScreen());
            },
          ),
          Divider(),
          // buildListTile(
          //   title: "Unblock friends",
          //   icon: Icons.block,
          //   onTap: () {
          //     NavigationUtils.pushTo(context, UnblockFriendsScreen());
          //   },
          // ),
          // Divider(),
          buildListTile(
            title: Localizer.get(AppText.searchFriend.key),
            icon: Icons.search,
            onTap: () {
              NavigationUtils.pushTo(context, SearchFriendsScreen());
            },
          ),
          Divider(),
          buildListTile(
            title: Localizer.get(AppText.setting.key),
            icon: Icons.settings,
            onTap: () {
              NavigationUtils.pushTo(context, AccountSettingsScreen());
            },
          ),
          Divider(),
          buildListTile(
            title: Localizer.get(AppText.changePassword.key),
            icon: Icons.lock,
            onTap: () {},
          ),
          Divider(),
          ListTile(
            minTileHeight: 40,
            leading: SizedBox(
              height: 40,
              width: 40,
              child: Image.asset(AppImage().LOGO_TRANSPARENT),
            ),
            title: customText(
              Localizer.get(AppText.aboutLGBT.key),
              14.0,
              context,
              fontWeight: FontWeight.w500,
              color: AppColor().kWhite,
            ),
            onTap: () {},
          ),
          Divider(),
          buildListTile(
            title: Localizer.get(AppText.termsAnd.key),
            icon: Icons.privacy_tip,
            onTap: () {
              NavigationUtils.pushTo(
                context,
                WebInAppScreen(URL: GlobalUtils().URL_TERMS),
              );
            },
          ),
          Divider(),
          buildListTile(
            title: Localizer.get(AppText.privacy.key),
            icon: Icons.privacy_tip,
            onTap: () {
              NavigationUtils.pushTo(
                context,
                WebInAppScreen(URL: GlobalUtils().URL_PRIVACY),
              );
            },
          ),
          Divider(),
          buildListTile(
            title: Localizer.get(AppText.ourMission.key),
            icon: Icons.list,
            onTap: () {
              NavigationUtils.pushTo(context, OurMissionScreen());
            },
          ),
          Divider(),
          buildListTile(
            title: Localizer.get(AppText.language.key),
            icon: Icons.language,
            onTap: () {
              NavigationUtils.pushTo(
                context,
                LanguageSelectionScreen(isBack: true),
              );
            },
          ),
          Divider(),
          buildListTile(
            title: Localizer.get(AppText.help.key),
            icon: Icons.help,
            onTap: () {},
          ),
          Divider(),
          buildListTile(
            title: Localizer.get(AppText.logout.key),
            icon: Icons.logout,
            onTap: () {
              AlertsUtils().showBottomSheetWithTwoBottom(
                context: context,
                message: Localizer.get(AppText.logoutMessage.key),
                onYesTap: () async {
                  HapticFeedback.mediumImpact();
                  await FirebaseAuth.instance.signOut();
                  await UserLocalStorage.clearUserData();
                  NavigationUtils.pushReplacementTo(context, LoginScreen());
                },
                yesTitle: 'Yes, Logout',
              );
            },
          ),
          Divider(),

          const SizedBox(height: 40),
          customText('v1.0.0(1)', 12.0, context, color: AppColor().GRAY),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  /*void showLogoutPopup({
    required BuildContext context,
    // required String message,
    Color? backgroundColor,
  }) async {
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: customText(
                            'Are you sure you want to logout ?',
                            18.0,
                            context,
                            darkModeColor:
                                hexToColor(AppResources.hexColor.whiteColor),
                            lightModeColor:
                                hexToColor(AppResources.hexColor.whiteColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6.0),
                GestureDetector(
                  onTap: () async {
                    dismissAlert(context);

                    final storageHelper = SecureStorageHelper();
                    String uid = '';
                    Map<String, dynamic>? data = await storageHelper.getData(
                      AppResources.text.textSaveLoginResponseKey,
                    );
                    if (data != null) {
                      // customLog('Retrieved Data: $data');
                      storeLoginUserData = data;
                      uid = storeLoginUserData['data']['userId'].toString();
                    } else {
                      customLog('No data found.');
                    }

                    final storage = FlutterSecureStorage();
                    await storage.delete(
                      key: AppResources.text.textSaveLoginResponseKey,
                    );
                    await storage.deleteAll().then((v) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    });
                    callLogout(context, uid.toString());
                  },
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width / 2,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: customText(
                            'Yes, logout',
                            14.0,
                            context,
                            fontWeight: FontWeight.w800,
                            darkModeColor:
                                hexToColor(AppResources.hexColor.whiteColor),
                            lightModeColor:
                                hexToColor(AppResources.hexColor.whiteColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }*/

  Widget buildListTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      minTileHeight: 40,
      leading: Icon(icon, color: Colors.white, size: 18.0),
      title: customText(
        title,
        14.0,
        context,
        fontWeight: FontWeight.w500,
        color: AppColor().kWhite,
      ),
      onTap: onTap,
    );
  }

  /*Future<void> callLogout(BuildContext context, String userId) async {
    var payload = {
      "action": "logout",
      "userId": userId,
    };

    customLog("Payload: $payload");

    try {
      final response = await ApiService().callCommonNetwordApi(payload);
      customLog(response);
      if (response['status'].toString() == AppResources.text.textSuccess) {
        customLog(response);
      } else {
        showExceptionPopup(
            context: context, message: response['msg'].toString());
      }
    } catch (e) {
      showExceptionPopup(context: context, message: e.toString());
    } finally {
      setState(() {});
    }
  }*/

  void showLogout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 200,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Delete account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Your account will be deleted account permanently.',
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
