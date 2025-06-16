import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key, this.profileData});

  final profileData;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // clicked tab
  int selectedTabIndex = 0;
  // loader
  bool screenLoader = true;
  //
  var arrFeeds = [];

  var storeFriendsData;

  bool isProfileLiked = false;

  // login user data get
  var userData;

  String storeFriendStatus = '';

  List<String> images = [
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSZcaNJcoE9hJ20j1K8H7Ml6872NyPN5zaJjQ&s',
    'https://images.unsplash.com/photo-1472396961693-142e6e269027?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8bmF0dXJlfGVufDB8fDB8fHwy',
    'https://images.unsplash.com/photo-1615729947596-a598e5de0ab3?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjB8fG5hdHVyZXxlbnwwfHwwfHx8Mg%3D%3D',
    'https://images.unsplash.com/photo-1469474968028-56623f02e42e?q=80&w=2948&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://images.unsplash.com/photo-1540206395-68808572332f?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MzV8fG5hdHVyZXxlbnwwfHwwfHx8Mg%3D%3D',
    'https://images.unsplash.com/photo-1586348943529-beaae6c28db9?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MzZ8fG5hdHVyZXxlbnwwfHwwfHx8Mg%3D%3D',
  ];

  final List<String> imageUrls = [
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
  ];

  @override
  void initState() {
    super.initState();
    GlobalUtils().customLog(widget.profileData);

    // call profile
    callFeeds();
  }

  void callFeeds() async {
    userData = await UserLocalStorage.getUserData();
    await Future.delayed(Duration(milliseconds: 400)).then((v) {
      callOtherProfileWB(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: Localizer.get(AppText.userProfile.key),
        backgroundColor: AppColor().kNavigationColor,
        backIcon: Icons.chevron_left,
        showBackButton: true,
        onBackPressed: () {
          // _scaffoldKey.currentState?.openDrawer();
          Navigator.pop(context);
        },
      ),
      drawer: const CustomDrawer(),
      body: screenLoader ? SizedBox() : _UIKIT(context),
    );
  }

  Widget _UIKIT(context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImage().BG_1),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: CustomCacheImageForUserProfile(
                          imageURL: storeFriendsData["image"].toString(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        customText(
                          storeFriendsData["firstName"].toString(),
                          14,
                          context,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(height: 2),
                        customText(
                          storeFriendsData["email"].toString(),
                          12,
                          context,
                          color: Color(0xFFE6D200),
                        ), // yellow tag
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          CustomContainer(
            margin: EdgeInsets.all(0),
            borderRadius: 0,
            color: AppColor().kWhite,
            shadow: false,
            height: 60,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      customText(
                        storeFriendsData["total_Post"].toString(),
                        16,
                        context,
                        fontWeight: FontWeight.w600,
                      ),
                      customText("Posts", 14, context, color: AppColor().GRAY),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      customText(
                        storeFriendsData["total_fnd"].toString(),
                        16,
                        context,
                        fontWeight: FontWeight.w600,
                      ),
                      customText(
                        "Friends",
                        14,
                        context,
                        color: AppColor().GRAY,
                      ),
                    ],
                  ),
                ),
                Expanded(child: SizedBox()),
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      _widgetThumbsUpUIKit(context),
                      if (storeFriendsData["userId"].toString() ==
                          userData['userId'].toString()) ...[
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: 8),
                            height: 40,
                            width: 80,
                            decoration: BoxDecoration(
                              color: AppColor().kNavigationColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: customText(
                                Localizer.get(AppText.setting.key),
                                14,
                                context,
                                fontWeight: FontWeight.w600,
                                color: AppColor().kWhite,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // different
                        _widgetAddFriendButtonUIKit(context),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          CustomUserProfileThreeButtonTile(
            selectedIndex: selectedTabIndex,
            onMenuTap: () {
              selectedTabIndex = 0;
              GlobalUtils().customLog("Menu tapped");
              setState(() {});
            },
            onImageTap: () {
              selectedTabIndex = 1;
              GlobalUtils().customLog("Image tapped");
              setState(() {});
            },
            onVideoTap: () {
              selectedTabIndex = 2;
              GlobalUtils().customLog("Video tapped");
              setState(() {});
            },
          ),
          SizedBox(height: 8),
          if (selectedTabIndex == 0) ...[
            _feedsViewUIKIT(context),
          ] else if (selectedTabIndex == 1) ...[
            _galleryViewUIKIT(context),
          ],
        ],
      ),
    );
  }

  Container _widgetThumbsUpUIKit(context) {
    return Container(
      height: 40,
      width: 40,
      color: AppColor().kWhite,
      child: IconButton(
        onPressed: () {
          /*GlobalUtils().customLog("Thumbs up");
                          GlobalUtils().customLog(isProfileLiked);*/
          if (isProfileLiked == false) {
            setState(() {
              isProfileLiked = true;
            });
            // call api for true handle
            callProfileLikeWB(context);
          }
        },
        icon: !isProfileLiked
            ? Icon(Icons.thumb_up_alt_rounded)
            : Icon(Icons.thumb_up_alt_rounded, color: AppColor().RED),
      ),
    );
  }

  Widget _widgetAddFriendButtonUIKit(context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          GlobalUtils().customLog("Hit: Add friend");
          GlobalUtils().customLog(storeFriendsData);

          // return;
          // if (storeFriendsData["fnd_status"].toString() == "") {
          GlobalUtils().customLog("Empty send request to this user");
          AlertsUtils.showLoaderUI(
            context: context,
            title: Localizer.get(AppText.pleaseWait.key),
          );
          callSendRequestWB(context);
          //}
        },
        child: Container(
          margin: EdgeInsets.only(right: 8),
          height: 40,
          width: 80,
          decoration: BoxDecoration(
            color: storeFriendStatus == "1" ? Colors.orange : AppColor().PURPLE,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: customText(
              storeFriendStatus == "1" ? "Request sent" : "ADD FRIEND",
              storeFriendStatus == "1" ? 12 : 14,
              context,
              fontWeight: FontWeight.w600,
              color: AppColor().kWhite,
            ),
          ),
        ),
      ),
    );
  }

  // Feeds
  Widget _feedsViewUIKIT(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: arrFeeds.length,
      itemBuilder: (context, index) {
        final postJson = arrFeeds[index];
        final feedImagePaths = FeedUtils.prepareFeedImagePaths(postJson);

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
              String statusToSend;
              if (arrFeeds[index]['youliked'] == 0) {
                statusToSend = "2";
              } else {
                statusToSend = "1";
              }

              // call api
              callLikeUnlikeWB(
                context,
                postJson['postId'].toString(),
                statusToSend.toString(),
              );
            },
            onCommentTap: () {
              GlobalUtils().customLog("Comment tapped index $index!");
              NavigationUtils.pushTo(
                context,
                CommentsScreen(postDetails: postJson),
              );
            },

            onShareTap: () =>
                GlobalUtils().customLog("Shared post index $index!"),
            onUserTap: () {
              GlobalUtils().customLog("User profile tapped index $index!");
              NavigationUtils.pushTo(
                context,
                UserProfileScreen(profileData: postJson),
              );
            },

            onCardTap: () =>
                GlobalUtils().customLog("Full feed tapped index $index!"),
            onMenuTap: () =>
                GlobalUtils().customLog("Menu tapped index $index!"),
            // ✅ You must also pass "youLiked" to CustomFeedPostCardHorizontal
            youLiked: postJson['youliked'] == 1,
            postTitle: postJson['postTitle'].toString(),
          ),
        );
      },
    );
  }

  Widget _galleryViewUIKIT(context) {
    return MasonryGridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CustomFullScreenImageViewer(
                  imageUrls: images,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(images[index], fit: BoxFit.cover),
            ),
          ),
        );
      },
    );
    /*GridView.builder(
      shrinkWrap: true,
      itemCount: imageUrls.length,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CustomFullScreenImageViewer(
                  imageUrls: imageUrls,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(imageUrls[index], fit: BoxFit.cover),
          ),
        );
      },
    );*/
  }

  // ====================== API ================================================
  // ====================== FRIEND'S FEED
  Future<void> callFeedsWB(context) async {
    final userData = await UserLocalStorage.getUserData();
    GlobalUtils().customLog(userData);
    // return;
    GlobalUtils().customLog(userData['userId'].toString());
    // dismiss keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadFeeds(
        action: ApiAction().FEEDS,
        userId: widget.profileData["userId"].toString(),
        type: "",
        pageNo: 1,
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog("✅ Friends profile success");

      setState(() {
        arrFeeds = response["data"];
        screenLoader = false;
      });
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

  // ====================== LIKE UNLIKE
  Future<void> callLikeUnlikeWB(context, String postId, String status) async {
    final userData = await UserLocalStorage.getUserData();
    GlobalUtils().customLog(userData);
    // return;
    GlobalUtils().customLog(userData['userId'].toString());
    // dismiss keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadLikeUnlike(
        action: ApiAction().FEEDS_LIKE_UNLIKE,
        userId: userData['userId'].toString(),
        postId: postId,
        status: status,
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog("✅ POST ${response['msg'].toString()} success");
    } else {
      GlobalUtils().customLog("Failed to LIKE: $response");
      // Navigator.pop(context);
      // show error popup
      AlertsUtils().showExceptionPopup(
        context: context,
        message: response['msg'].toString(),
      );
    }
  }

  // ====================== OTHER USER PROFILE
  Future<void> callOtherProfileWB(context) async {
    final userData = await UserLocalStorage.getUserData();
    GlobalUtils().customLog(userData);
    // return;
    GlobalUtils().customLog(userData['userId'].toString());
    // dismiss keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadOtherUserCheck(
        action: ApiAction().PROFILE,
        userId: userData['userId'].toString(),
        other_profile_Id: widget.profileData["userId"]
            .toString(), // friend's userId
      ),
    );

    GlobalUtils().customLog("$response");
    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog("✅ POST $response success");
      storeFriendsData = response["data"];
      GlobalUtils().customLog(storeFriendsData);

      if (storeFriendsData["you_liked_profile"].toString() == "1") {
        isProfileLiked = true;
      }
      GlobalUtils().customLog(isProfileLiked);

      final fndStatus = storeFriendsData['fnd_status'];
      // storeFriendStatus
      if (fndStatus != null && fndStatus is Map<String, dynamic>) {
        GlobalUtils().customLog("✅ Valid fnd_status: $fndStatus");
        storeFriendStatus = fndStatus["status"].toString();
      } else {
        GlobalUtils().customLog("❌ fnd_status is empty or invalid");
        storeFriendStatus = "";
      }
      GlobalUtils().customLog(storeFriendStatus);
      // return;
      callFeedsWB(context);
    } else {
      GlobalUtils().customLog("Failed to LIKE: $response");
      // Navigator.pop(context);
      // show error popup
      AlertsUtils().showExceptionPopup(
        context: context,
        message: response['msg'].toString(),
      );
    }
  }

  // ====================== PROFILE LIKE
  Future<void> callProfileLikeWB(context) async {
    final userData = await UserLocalStorage.getUserData();
    GlobalUtils().customLog(userData);
    // return;
    GlobalUtils().customLog(userData['userId'].toString());
    // dismiss keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadProfileLike(
        action: ApiAction().LIKE_PROFILE,
        userId: userData['userId'].toString(),
        profileId: widget.profileData["userId"].toString(), // friend's userId
        status: '1',
      ),
    );

    GlobalUtils().customLog("$response");
    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog("✅ POST PROFILE LIKE success");

      CustomFlutterToastUtils.showToast(
        message: response['msg'],
        backgroundColor: AppColor().GREEN,
      );
      callOtherProfileWB(context);
    } else {
      GlobalUtils().customLog("Failed to PROFILE LIKE: $response");
      // Navigator.pop(context);
      // show error popup
      AlertsUtils().showExceptionPopup(
        context: context,
        message: response['msg'].toString(),
      );
    }
  }

  // ====================== SEND REQUEST
  Future<void> callSendRequestWB(context) async {
    /*
      Payload: {action: frinedrequest, senderId: 15, receiverId: 19, status: 1}
    */

    final userData = await UserLocalStorage.getUserData();
    GlobalUtils().customLog(userData);
    // return;
    GlobalUtils().customLog(userData['userId'].toString());
    // dismiss keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadSendRequest(
        action: ApiAction().FRIEND_REQUEST,
        senderId: userData['userId'].toString(),
        receiverId: widget.profileData["userId"].toString(),
        status: '1', // send request
      ),
    );

    GlobalUtils().customLog("$response");
    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog("✅ POST PROFILE LIKE success");

      CustomFlutterToastUtils.showToast(
        message: response['msg'],
        backgroundColor: AppColor().GREEN,
      );
      Navigator.pop(context);
      callOtherProfileWB(context);
    } else {
      GlobalUtils().customLog("Failed to PROFILE LIKE: $response");
      Navigator.pop(context);
      // show error popup
      AlertsUtils().showExceptionPopup(
        context: context,
        message: response['msg'].toString(),
      );
    }
  }
}
