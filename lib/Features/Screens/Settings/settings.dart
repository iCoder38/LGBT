import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lgbt_togo/Features/Screens/Settings/General/edit_profile.dart';
import 'package:lgbt_togo/Features/Screens/Settings/Notification/notifications.dart';
import 'package:lgbt_togo/Features/Screens/change_password/change_password.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

void main() {
  runApp(const MaterialApp(home: AccountSettingsScreen()));
}

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  // scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // user data
  var userData;

  @override
  void initState() {
    super.initState();

    callInitAPI();
  }

  void callInitAPI() async {
    userData = await UserLocalStorage.getUserData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: Localizer.get(AppText.setting.key),
        backgroundColor: AppColor().kNavigationColor,
        backIcon: Icons.menu,
        showBackButton: true,
        onBackPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppImage().BG_2),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: 280,
                width: double.infinity,
                color: Colors.black.withOpacity(0.5),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 12),
                          customText(
                            "",
                            14,
                            context,
                            color: AppColor().kWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      customText(
                        FIREBASE_AUTH_NAME(),
                        22,
                        context,
                        color: AppColor().kWhite,
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(height: 12),
                      customText(
                        "${GlobalUtils().calculateAge(userData["dob"].toString())} || ${GlobalUtils().calculateAge(userData["gender"].toString())}",
                        16,
                        context,
                        color: AppColor().TEAL,
                      ),
                      const SizedBox(height: 12),
                      customText(
                        FIREBASE_AUTH_EMAIL(),
                        14,
                        context,
                        color: AppColor().kWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: 0,
                right: 0,
                child: Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 40,
                      child: CustomCacheImageForUserProfile(
                        imageURL: userData["image"].toString(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          const Divider(height: 1),
          buildTile(context, "General Settings"),
          buildTile(context, "Privacy Settings"),
          buildTile(context, "Notification Settings"),
          buildTile(context, "Email Settings"),
          buildTile(context, "Languages"),
          buildTile(context, "Delete Account", isDestructive: true),
        ],
      ),
    );
  }

  Widget buildTile(context, String title, {bool isDestructive = false}) {
    return Column(
      children: [
        ListTile(
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (title == "Privacy Settings") ...[
                Icon(
                  Icons.privacy_tip,
                  size: 18,
                  color: AppColor().PRIMARY_COLOR,
                ),
              ] else if (title == "Notification Settings") ...[
                Icon(
                  Icons.notifications,
                  size: 18,
                  color: AppColor().PRIMARY_COLOR,
                ),
              ] else if (title == "Email Settings") ...[
                Icon(Icons.email, size: 18, color: AppColor().PRIMARY_COLOR),
              ] else if (title == "General Settings") ...[
                Icon(Icons.person, size: 18, color: AppColor().PRIMARY_COLOR),
              ] else if (title == "Languages") ...[
                Icon(Icons.language, size: 18, color: AppColor().PRIMARY_COLOR),
              ] else if (title == "Delete Account") ...[
                Icon(Icons.delete, size: 18, color: AppColor().RED),
              ],
            ],
          ),
          title: customText(
            title,
            14,
            context,
            color: isDestructive ? AppColor().RED : AppColor().kBlack,
            fontWeight: isDestructive ? FontWeight.w600 : FontWeight.w400,
          ),

          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            if (title == "Privacy Settings") {
              NavigationUtils.pushTo(context, PrivacyScreen());
              return;
            }
            if (title == "Notification Settings") {
              NavigationUtils.pushTo(context, NotificationsSettingsScreen());
              return;
            }
            if (title == "Email Settings") {
              NavigationUtils.pushTo(context, EmailScreen());
              return;
            }
            if (title == "General Settings") {
              // NavigationUtils.pushTo(context, EditProfileScreen(isEdit: true));
              pushToEditScreen(context);
              return;
            }
            if (title == "Languages") {
              NavigationUtils.pushTo(
                context,
                LanguageSelectionScreen(isBack: true),
              );
              return;
            }
            if (title == "Delete Account") {
              AlertsUtils().showCustomBottomSheet(
                context: context,
                message: "Delete account",
                buttonText: 'Delete account',
                onItemSelected: (selectedItem) {
                  callUserDelete();
                },
              );
              return;
            }
          },
        ),
        const Divider(height: 1),
      ],
    );
  }

  Future<void> callUserDelete() async {
    AlertsUtils.showLoaderUI(
      context: context,
      title: Localizer.get(AppText.pleaseWait.key),
    );
    final userData = await UserLocalStorage.getUserData();
    var payload = {
      "action": "userdelete",
      "userId": userData['userId'].toString(),
    };

    GlobalUtils().customLog(payload);

    try {
      final response = await callCommonNetwordApi(payload);
      GlobalUtils().customLog(response);

      if (response['status'].toString().toLowerCase() == "success") {
        await FirebaseFirestore.instance
            .collection('LGBT_TOGO_PLUS/ONLINE_STATUS/STATUS')
            .doc(FIREBASE_AUTH_UID())
            .set({
              'isOnline': false,
              'lastSeen': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
        HapticFeedback.mediumImpact();
        await FirebaseAuth.instance.signOut();
        await UserLocalStorage.clearUserData();
        // dismiss alert
        Navigator.pop(context);
        NavigationUtils.pushReplacementTo(context, LoginScreen());
      } else {
        // dismiss keyboard
        FocusScope.of(context).requestFocus(FocusNode());
        // dismiss alert
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: response['msg'].toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      // showExceptionPopup(context: context, message: e.toString());
    } finally {
      // customLog('Finally');
    }
  }

  Future<void> pushToEditScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen(isEdit: true)),
    );
    if (!mounted) return;
    if (result == 'reload') {
      setState(() {
        callInitAPI();
      });
    }
  }
}
