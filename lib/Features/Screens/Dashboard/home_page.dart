import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lgbt_togo/Features/Screens/Notifications/service.dart';
import 'package:lgbt_togo/Features/Screens/OurMission/our_mission.dart';
import 'package:lgbt_togo/Features/Screens/Subscription/revenueCat/helper.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key, required this.isBack});
  final bool isBack;
  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  bool _isPremium = false;
  var userProfileData;
  bool screenLoader = true;
  List<String> interests = [];

  String notificationCounter = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final coverHeight = width * 0.45;
    const avatarSize = 110.0;

    return Scaffold(
      appBar: CustomAppBar(
        centerImageAsset: AppImage().LOGO,
        title: Localizer.get(AppText.dashboard.key),
        backgroundColor: AppColor().kNavigationColor,
        showBackButton: widget.isBack,
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () async {
                  NavigationUtils.pushTo(context, NotificationsScreen());
                },
                icon: Icon(Icons.notifications, color: AppColor().kWhite),
              ),

              // Agar count > 0 ho tabhi badge dikhana hai
              Positioned(
                right: 8,
                top: 8,
                child: notificationCounter == "" || notificationCounter == "0"
                    ? SizedBox()
                    : Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          notificationCounter,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
            ],
          ),
          IconButton(
            onPressed: () async {
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
              NavigationUtils.pushReplacementTo(context, LoginScreen());
            },
            icon: Icon(Icons.exit_to_app, color: AppColor().kWhite),
          ),
        ],
      ),
      body: screenLoader
          ? Center(child: customText("...please wait...", 14, context))
          : _UIKIT(coverHeight, avatarSize, width, context),
    );
  }

  SafeArea _UIKIT(
    double coverHeight,
    double avatarSize,
    double width,
    BuildContext context,
  ) {
    return SafeArea(
      child: Column(
        children: [
          // Top Section (unchanged)
          SizedBox(
            height: coverHeight + avatarSize / 2 + 24,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Cover image
                Container(
                  height: coverHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    image: DecorationImage(
                      image: AssetImage(AppImage().BG_1),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Center avatar
                Positioned(
                  top: coverHeight - avatarSize / 2,
                  left: (width - avatarSize) / 2,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: avatarSize / 2,
                        backgroundImage: CachedNetworkImageProvider(
                          userProfileData["image"].toString(),
                        ),
                      ),
                      // Positioned(right: -6, bottom: -6, child: _cameraBadge()),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body Section - scrollable content only
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  if (_isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.amber),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          SizedBox(width: 6),
                          customText(
                            "Premium",
                            14,
                            context,
                            color: Colors.amber,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 14),
                  customText(
                    userProfileData["firstName"].toString(),
                    22,
                    context,
                    fontWeight: FontWeight.w800,
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      customText(
                        genderReverseMap[userProfileData["gender"]
                                .toString()] ??
                            "Not specified",
                        12,
                        context,
                        color: AppColor().GRAY,
                      ),
                      SizedBox(width: 8),
                      Text("•", style: TextStyle(color: Colors.grey)),
                      SizedBox(width: 8),
                      customText(
                        GlobalUtils().calculateAge(
                          userProfileData["dob"].toString(),
                        ),
                        12,
                        context,
                        color: AppColor().GRAY,
                      ),
                      Text(" •", style: TextStyle(color: Colors.grey)),
                      SizedBox(width: 8),
                      customText(
                        userProfileData["cityname"].toString(),
                        12,
                        context,
                        color: AppColor().GRAY,
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Stats Row
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _statTile(
                          Icons.groups,
                          userProfileData["total_fnd"].toString(),
                          "Total Friends",
                        ),
                        _divider(),
                        _statTile(
                          Icons.post_add,
                          userProfileData["total_Post"].toString(),
                          "Total Post",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    title: customText(
                      "Story",
                      16,
                      context,
                      fontWeight: FontWeight.w600,
                    ),
                    subtitle: Padding(
                      key: const Key('showMore'),
                      padding: const EdgeInsets.all(0),
                      child: ReadMoreText(
                        userProfileData["story"],
                        trimMode: TrimMode.Line,
                        trimLines: 3,
                        trimLength: 240,
                        style: const TextStyle(color: Colors.black),
                        colorClickableText: Colors.pink,
                        trimCollapsedText: '...Show more',
                        trimExpandedText: ' show less',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    title: customText(
                      "BIO",
                      16,
                      context,
                      fontWeight: FontWeight.w600,
                    ),
                    subtitle: Padding(
                      key: const Key('showMore'),
                      padding: const EdgeInsets.all(0),
                      child: ReadMoreText(
                        userProfileData["bio"],
                        trimMode: TrimMode.Line,
                        trimLines: 3,
                        trimLength: 240,
                        style: const TextStyle(color: Colors.black),
                        colorClickableText: Colors.pink,
                        trimCollapsedText: '...Show more',
                        trimExpandedText: ' show less',
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text(
                      "My Likes",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: userProfileData["interests"]
                            .toString()
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .map(
                              (interest) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.green,
                                    width: 0.6,
                                  ),
                                ),
                                child: Text(
                                  interest,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Add extra bottom space so last scroll item isn't hidden by fixed buttons
                  SizedBox(height: 84),
                ],
              ),
            ),
          ),

          // Fixed Buttons (always visible at bottom)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: CustomButton(
                        text: "About Us",
                        height: 44,
                        color: AppColor().kNavigationColor,
                        textColor: AppColor().kWhite,
                        borderRadius: 12,
                        onPressed: () {
                          NavigationUtils.pushTo(
                            context,
                            OurMissionScreen(isOurMission: false),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: CustomButton(
                        text: "Dashboard",
                        height: 44,
                        color: AppColor().kNavigationColor,
                        textColor: AppColor().kWhite,
                        borderRadius: 12,
                        onPressed: () {
                          NavigationUtils.pushTo(context, DashboardScreen());
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Small round icon button
  Widget _roundIconButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 22, color: Colors.black87),
        ),
      ),
    );
  }

  // Camera Badge
  Widget _cameraBadge() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
        ),
      ),
    );
  }

  // Stat tile
  Widget _statTile(IconData icon, String top, String bottom) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 22, color: Colors.black87),
          const SizedBox(height: 8),
          Text(
            top,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 6),
          Text(
            bottom,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // Divider between stats
  Widget _divider() {
    return Container(width: 1, height: 70, color: Colors.grey.shade300);
  }

  // Subscription check
  Future<void> _checkSubscription() async {
    final status = await SubscriptionHelper.checkPremiumStatus();
    _isPremium = status["isActive"] ?? false;
    GlobalUtils().customLog("Subscription status: $status");
    callEditProfile(context);
  }

  /// API: EDIT PROFILE
  Future<void> callEditProfile(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    final userData = await UserLocalStorage.getUserData();
    String? token = await DeviceTokenStorage.getToken();
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadEditDeviceToken(
        action: ApiAction().EDIT_PROFILE,
        userId: userData['userId'].toString(),
        deviceToken: token.toString(),
        firebaseId: FIREBASE_AUTH_UID(),
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog(response);
      await UserLocalStorage.saveUserData(response['data']);
      final userService = UserService();
      await userService.updateUser(FIREBASE_AUTH_UID(), {
        'image': response['data']["image"].toString(),
      });
      userProfileData = response["data"];
      if (userProfileData["interests"] != null) {
        interests = userProfileData["interests"]
            .toString()
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }

      callNotificationCounterWB(context);
    } else {
      HapticFeedback.mediumImpact();
      await FirebaseAuth.instance.signOut();
      await UserLocalStorage.clearUserData();
      NavigationUtils.pushReplacementTo(context, LoginScreen());
    }
  }

  Future<void> callNotificationCounterWB(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    final userData = await UserLocalStorage.getUserData();
    // String? token = await DeviceTokenStorage.getToken();
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadNotificationCounter(
        action: ApiAction().NOTIFICATION_COUNTER,
        userId: userData['userId'].toString(),
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog(response);
      notificationCounter = response["noti_unread_count"].toString();
      setState(() {
        screenLoader = false;
      });
    } else {
      HapticFeedback.mediumImpact();
      await FirebaseAuth.instance.signOut();
      await UserLocalStorage.clearUserData();
      NavigationUtils.pushReplacementTo(context, LoginScreen());
    }
  }
}

final Map<String, String> genderReverseMap = {
  "1": "Heterosexual",
  "2": "Homosexual",
  "3": "Bisexual",
  "4": "Asexual",
  "5": "Pansexual",
  "6": "Demisexual",
  "7": "Aromantic",
  "8": "Queer",
  "9": "Gay",
  "10": "Lesbian",
  "11": "Transsexual",
  "12": "Transgender",
};
