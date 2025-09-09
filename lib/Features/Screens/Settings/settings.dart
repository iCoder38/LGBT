// lib/Features/Screens/Settings/account_settings_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lgbt_togo/Features/Screens/Settings/General/edit_profile.dart';
import 'package:lgbt_togo/Features/Screens/Settings/Notification/notifications.dart';
import 'package:lgbt_togo/Features/Screens/Settings/language_sheet/languages.dart';
import 'package:lgbt_togo/Features/Screens/change_password/change_password.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Map<String, dynamic>? userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final data = await UserLocalStorage.getUserData();
      if (!mounted) return;
      setState(() {
        userData = Map<String, dynamic>.from(data ?? {});
        _loading = false;
      });
    } catch (e, st) {
      GlobalUtils().customLog('init error: $e\n$st');
      if (!mounted) return;
      setState(() {
        userData = {};
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = Localizer.get(AppText.setting.key);

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: title,
        backgroundColor: AppColor().kNavigationColor,
        backIcon: Icons.menu,
        showBackButton: true,
        onBackPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: const CustomDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildHeader(context),
                const SizedBox(height: 64), // space for avatar overlap
                const Divider(height: 1),
                _buildTile(context, Localizer.get(AppText.generalSettings.key)),
                _buildTile(context, Localizer.get(AppText.privacySettings.key)),
                _buildTile(
                  context,
                  Localizer.get(AppText.notificationSettings.key),
                ),
                _buildTile(context, Localizer.get(AppText.emailSettings.key)),
                _buildTile(context, Localizer.get(AppText.languages.key)),
                _buildTile(
                  context,
                  Localizer.get(AppText.deleteAccount.key),
                  isDestructive: true,
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final cover = AppImage().BG_2;
    final name = FIREBASE_AUTH_NAME();
    final email = FIREBASE_AUTH_EMAIL();
    final imageUrl = (userData?['image'] ?? '').toString();

    final gender = userData?['gender']?.toString() ?? '';
    final dob = userData?['dob']?.toString() ?? '';

    final age = (dob.isNotEmpty) ? GlobalUtils().calculateAge(dob) : '';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // cover image
        SizedBox(
          height: 240,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(cover, fit: BoxFit.cover),
              Container(color: Colors.black.withOpacity(0.45)),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // ✅ center horizontally
                    children: [
                      const SizedBox(height: 18),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColor().kWhite,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (age.isNotEmpty || gender.isNotEmpty)
                        Text(
                          '$age ${gender.isNotEmpty ? "• $gender" : ""}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColor().TEAL,
                            fontSize: 14,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        email,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColor().kWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // avatar overlapping
        Positioned(
          bottom: -48,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: () => pushToEditScreen(context),
              child: CircleAvatar(
                radius: 56,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.grey.shade200,
                  child: ClipOval(
                    child: CustomCacheImageForUserProfile(imageURL: imageUrl),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTile(
    BuildContext context,
    String title, {
    bool isDestructive = false,
  }) {
    // Localized labels resolved once
    final genLabel = Localizer.get(AppText.generalSettings.key);
    final privacyLabel = Localizer.get(AppText.privacySettings.key);
    final notifLabel = Localizer.get(AppText.notificationSettings.key);
    final emailLabel = Localizer.get(AppText.emailSettings.key);
    final languagesLabel = Localizer.get(AppText.languages.key);
    final deleteLabel = Localizer.get(AppText.deleteAccount.key);

    // Leading icon
    final Widget leadingIcon = () {
      if (title == privacyLabel) {
        return Icon(
          Icons.privacy_tip,
          size: 20,
          color: AppColor().PRIMARY_COLOR,
        );
      } else if (title == notifLabel) {
        return Icon(
          Icons.notifications,
          size: 20,
          color: AppColor().PRIMARY_COLOR,
        );
      } else if (title == emailLabel) {
        return Icon(Icons.email, size: 20, color: AppColor().PRIMARY_COLOR);
      } else if (title == genLabel) {
        return Icon(Icons.person, size: 20, color: AppColor().PRIMARY_COLOR);
      } else if (title == languagesLabel) {
        return Icon(Icons.language, size: 20, color: AppColor().PRIMARY_COLOR);
      } else if (title == deleteLabel) {
        return Icon(Icons.delete, size: 20, color: AppColor().RED);
      } else {
        return Icon(Icons.settings, size: 20, color: AppColor().PRIMARY_COLOR);
      }
    }();

    return Column(
      children: [
        ListTile(
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [leadingIcon],
          ),
          title: customText(
            title,
            14,
            context,
            color: isDestructive ? AppColor().RED : AppColor().kBlack,
            fontWeight: isDestructive ? FontWeight.w600 : FontWeight.w400,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () async {
            // route by localized titles
            if (title == privacyLabel) {
              NavigationUtils.pushTo(context, PrivacyScreen());
              return;
            }
            if (title == notifLabel) {
              NavigationUtils.pushTo(context, NotificationsSettingsScreen());
              return;
            }
            if (title == emailLabel) {
              NavigationUtils.pushTo(context, EmailScreen());
              return;
            }
            if (title == genLabel) {
              pushToEditScreen(context);
              return;
            }
            if (title == languagesLabel) {
              NavigationUtils.pushTo(
                context,
                LanguageSelectionScreen(isBack: true),
              );
              return;
              // 1) simple call — not waiting result
              showLanguageSelectionSheet(context, isBack: true);

              // 2) await result
              final selected = await showLanguageSelectionSheet(
                context,
                isBack: false,
              );
              if (selected != null) {
                // selected contains the language code, e.g. 'en' or 'fr'
                debugPrint('User selected language: $selected');
                // app is already updated inside the sheet by Localizer.setLanguage,
                // but you can also handle UI/navigation here if needed.
                setState(() {});
              }

              return;
            }
            if (title == deleteLabel) {
              AlertsUtils().showCustomBottomSheet(
                context: context,
                message: Localizer.get(AppText.deleteAccount.key),
                buttonText: Localizer.get(AppText.deleteAccount.key),
                onItemSelected: (_) => callUserDelete(),
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
    final uData = await UserLocalStorage.getUserData();
    var payload = {
      "action": "userdelete",
      "userId": uData['userId'].toString(),
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
        if (mounted) Navigator.pop(context);
        NavigationUtils.pushReplacementTo(context, LoginScreen());
      } else {
        if (mounted) Navigator.pop(context);
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
    } catch (e, st) {
      GlobalUtils().customLog('callUserDelete error: $e\n$st');
      if (mounted) Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Something went wrong');
    }
  }

  Future<void> pushToEditScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen(isEdit: true)),
    );
    if (!mounted) return;
    if (result == 'reload') {
      // reload user data
      _init();
    }
  }
}
