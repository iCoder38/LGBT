import 'package:lgbt_togo/Features/Screens/Notifications/service.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';
import 'package:share_plus/share_plus.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool screenLoader = true;
  bool isRefresh = false;

  var arrFeeds = [];

  int currentPage = 1;
  bool isLastPage = false;
  bool isLoadingMore = false;
  ScrollController _scrollController = ScrollController();

  String notificationCounter = '';

  var userData;
  String loginUserimage = '';

  final List<FriendCard> friends = [
    FriendCard(
      name: "Aberash Ada",
      age: 32,
      gender: "Female",
      imageUrl: AppImage().DUMMY_1,
    ),
    FriendCard(
      name: "Donnie Mclurrink",
      age: 39,
      gender: "Male",
      imageUrl: AppImage().DUMMY_1,
    ),
  ];

  @override
  void initState() {
    super.initState();

    callInitAPI();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !isLoadingMore &&
          !isLastPage) {
        currentPage++;
        loadMoreFeeds();
      }
    });

    callFeeds();
  }

  void callInitAPI() async {
    userData = await UserLocalStorage.getUserData();
    loginUserimage = userData["image"] ?? "";
  }

  void callFeeds() async {
    await Future.delayed(const Duration(milliseconds: 400)).then((v) {
      currentPage = 1;
      isLastPage = false;
      callEditProfile(context);
    });
  }

  // edit device token
  Future<void> callEditProfile(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    // get login user data
    final userData = await UserLocalStorage.getUserData();
    // fetch token locally
    String? token = await DeviceTokenStorage.getToken();
    // 🔹 Call main profile update API
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
      // return;
      // store locally
      await UserLocalStorage.saveUserData(response['data']);
      final userService = UserService();
      await userService.updateUser(FIREBASE_AUTH_UID(), {
        'image': response['data']["image"].toString(),
      });
      callNotificationCounterWB(context);
    } else {
      HapticFeedback.mediumImpact();
      await FirebaseAuth.instance.signOut();
      await UserLocalStorage.clearUserData();
      NavigationUtils.pushReplacementTo(context, LoginScreen());
    }
  }

  // PayloadNotificationCounter
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
      setState(() {});
      // return;
      callFeedsWB(context, pageNo: currentPage);
    } else {
      HapticFeedback.mediumImpact();
      await FirebaseAuth.instance.signOut();
      await UserLocalStorage.clearUserData();
      NavigationUtils.pushReplacementTo(context, LoginScreen());
    }
  }

  Future<void> loadMoreFeeds() async {
    setState(() {
      isLoadingMore = true;
    });

    await callFeedsWB(context, pageNo: currentPage);

    setState(() {
      isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        centerImageAsset: AppImage().LOGO,
        title: Localizer.get(AppText.dashboard.key),
        backgroundColor: AppColor().kNavigationColor,
        backIcon: Icons.menu,
        showBackButton: true,
        onBackPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        actions: [
          //
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
        ],
      ),
      drawer: const CustomDrawer(),
      body: screenLoader ? const SizedBox() : _UIKIT(context),
    );
  }

  Widget _UIKIT(BuildContext context) {
    // --- build the fixed top widget (customize as needed) ---
    final Widget topFixed = GestureDetector(
      onTap: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => PostScreen()),
        );

        if (result == true) {
          isRefresh = true;
          AlertsUtils.showLoaderUI(
            context: context,
            title: Localizer.get(AppText.pleaseWait.key),
          );
          callFeeds();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.white,
        child: Row(
          children: [
            SizedBox(
              height: 50,
              width: 50,
              child: CustomCacheImageForUserProfile(imageURL: loginUserimage),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText(
                    // "What's in your mind...",
                    Localizer.get(AppText.whatsInYourMind.key),
                    14,
                    context,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.image)),
          ],
        ),
      ),
    );

    // --- the scrollable feed below the fixed top ---
    final Widget feedList = ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      itemCount: arrFeeds.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == arrFeeds.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final postJson = arrFeeds[index];

        // Collect images + video together
        final List<String> feedImagePaths = [];
        if (postJson['image_1']?.toString().isNotEmpty ?? false) {
          feedImagePaths.add(postJson['image_1'].toString());
        }
        if (postJson['image_2']?.toString().isNotEmpty ?? false) {
          feedImagePaths.add(postJson['image_2'].toString());
        }
        if (postJson['video']?.toString().isNotEmpty ?? false) {
          feedImagePaths.add(postJson['video'].toString());
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: CustomFeedPostCardHorizontal(
            userName: postJson['user']?['firstName'] ?? '',
            userImagePath: postJson['user']?['profile_picture'] ?? '',
            timeAgo: postJson['created'] ?? '',
            feedImagePaths: feedImagePaths,
            totalLikes: postJson['totalLike']?.toString() ?? '0',
            totalComments: postJson['totalComment']?.toString() ?? '0',
            onLikeTap: () {
              GlobalUtils().customLog("Liked post index $index!");
              setState(() {
                int currentLikes =
                    int.tryParse(arrFeeds[index]['totalLike'].toString()) ?? 0;

                if (arrFeeds[index]['youliked'] == 1) {
                  arrFeeds[index]['youliked'] = 0;
                  if (currentLikes > 0) {
                    arrFeeds[index]['totalLike'] = (currentLikes - 1)
                        .toString();
                  }
                } else {
                  arrFeeds[index]['youliked'] = 1;
                  arrFeeds[index]['totalLike'] = (currentLikes + 1).toString();
                }
              });

              String statusToSend = arrFeeds[index]['youliked'] == 0
                  ? "2"
                  : "1";

              callLikeUnlikeWB(
                context,
                postJson['postId'].toString(),
                statusToSend,
              );
            },
            onCommentTap: () {
              NavigationUtils.pushTo(
                context,
                CommentsScreen(postDetails: postJson),
              );
            },
            onShareTap: () {
              GlobalUtils().customLog("Shared post index $index!");
              final url =
                  'https://lgbt-togo.web.app/post/${postJson['postId'].toString()}';
              if (postJson['postTitle'].toString() == "") {
                final text = 'LGBT-TOGO\n\nTap to open: $url';
                Share.share(text);
              } else {
                final text =
                    '${postJson['postTitle'].toString()}\n\nTap to open: $url';
                Share.share(text);
              }
            },
            onUserTap: () {
              NavigationUtils.pushTo(
                context,
                UserProfileScreen(profileData: postJson, isFromRequest: false),
              );
            },
            onCardTap: () =>
                GlobalUtils().customLog("Full feed tapped index $index!"),
            onMenuTap: () async {
              final userData = await UserLocalStorage.getUserData();
              if (userData['userId'].toString() ==
                  postJson['userId'].toString()) {
                AlertsUtils().showCustomBottomSheet(
                  context: context,
                  message: "Delete post",
                  buttonText: "Confirm",
                  onItemSelected: (s) {
                    if (s == "Delete post") {
                      callDeletePostWB(context, postJson['postId'].toString());
                    }
                  },
                );
              } else {
                AlertsUtils().showCustomBottomSheet(
                  context: context,
                  message: Localizer.get(AppText.reportPost.key),
                  buttonText: Localizer.get(AppText.confirm.key),
                  onItemSelected: (s) {
                    callReportWB(context, postJson['postId'].toString());
                  },
                );
              }
            },
            youLiked: postJson['youliked'] == 1,
            postTitle: postJson['postTitle'].toString(),
            type: postJson["postType"].toString(),
            ishoriz: true,
          ),
        );
      },
    );

    // --- compose final UI with fixed top + expanded scrolling list ---
    return Column(
      children: [
        // fixed top area
        topFixed,

        // divider (optional)
        const Divider(height: 1),

        // scrollable feed
        Expanded(child: feedList),
      ],
    );
  }

  // ----------------------- APIs ---------------------------
  // ====================== EDIT FIREBASE ID
  Future<void> callEditFirebaseID(context) async {
    final userData = await UserLocalStorage.getUserData();
    GlobalUtils().customLog(userData['userId'].toString());
    // dismiss keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadEditHomeProfileKeys(
        action: ApiAction().EDIT_FIREBASE_ID,
        userId: userData['userId'].toString(),
        firebase_id: FIREBASE_AUTH_UID(),
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog(response);
      // store locally
      await UserLocalStorage.saveUserData(response['data']);
      final userService = UserService();
      await userService.updateUser(FIREBASE_AUTH_UID(), {
        'image': response['data']["image"].toString(),
      });
      callFeedsWB(context, pageNo: currentPage);
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

  Future<void> callFeedsWB(BuildContext context, {required int pageNo}) async {
    final userData = await UserLocalStorage.getUserData();

    FocusScope.of(context).unfocus();
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadFeeds(
        action: ApiAction().FEEDS_OWN,
        userId: userData['userId'].toString(),
        type: "OWN",
        pageNo: pageNo,
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      List<dynamic> newFeeds = response["data"];

      setState(() {
        if (pageNo == 1) {
          arrFeeds = newFeeds;
        } else {
          arrFeeds.addAll(newFeeds);
        }
        if (newFeeds.length < 10) {
          isLastPage = true;
        }
        screenLoader = false;
      });
      if (isRefresh == true) {
        isRefresh = false;
        Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
      AlertsUtils().showExceptionPopup(
        context: context,
        message: response['msg'].toString(),
      );
    }
  }

  Future<void> callLikeUnlikeWB(context, String postId, String status) async {
    final userData = await UserLocalStorage.getUserData();
    FocusScope.of(context).unfocus();

    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadLikeUnlike(
        action: ApiAction().FEEDS_LIKE_UNLIKE,
        userId: userData['userId'].toString(),
        postId: postId,
        status: status,
      ),
    );

    if (response['status'].toString().toLowerCase() != "success") {
      AlertsUtils().showExceptionPopup(
        context: context,
        message: response['msg'].toString(),
      );
    }
  }

  Future<void> callDeletePostWB(context, String postId) async {
    AlertsUtils.showLoaderUI(
      context: context,
      title: Localizer.get(AppText.pleaseWait.key),
    );

    final userData = await UserLocalStorage.getUserData();
    FocusScope.of(context).unfocus();

    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadDeletePost(
        action: ApiAction().POST_DELETE,
        userId: userData['userId'].toString(),
        postId: postId,
      ),
    );

    Navigator.pop(context);

    if (response['status'].toString().toLowerCase() == "success") {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Deleted")));
      callFeeds();
    } else {
      AlertsUtils().showExceptionPopup(
        context: context,
        message: response['msg'].toString(),
      );
    }
  }

  // report
  Future<void> callReportWB(context, String postId) async {
    AlertsUtils.showLoaderUI(
      context: context,
      title: Localizer.get(AppText.pleaseWait.key),
    );

    final userData = await UserLocalStorage.getUserData();
    FocusScope.of(context).unfocus();

    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadDeletePost(
        action: ApiAction().REPORT_POST,
        userId: userData['userId'].toString(),
        postId: postId,
      ),
    );

    Navigator.pop(context);

    if (response['status'].toString().toLowerCase() == "success") {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response['msg'].toString())));
      callFeeds();
    } else {
      AlertsUtils().showExceptionPopup(
        context: context,
        message: response['msg'].toString(),
      );
    }
  }
}
