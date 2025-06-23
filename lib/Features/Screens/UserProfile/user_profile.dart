import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({
    super.key,
    this.profileData,
    required this.isFromRequest,
  });

  final profileData;
  final bool isFromRequest;

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
  String storeFriendRequestId = '';
  String storeFriendRequestSenderId = '';
  String storeFriendRequestReceiverId = '';

  String friendId = '';

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

  var arrAlbum = [];
  // scroll
  int currentPage = 1;
  bool isLastPage = false;
  bool isLoadingMore = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    GlobalUtils().customLog(widget.profileData);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !isLoadingMore &&
          !isLastPage) {
        currentPage++;
        loadMoreFeeds();
      }
    });
    // call profile
    callFeeds();
  }

  void callFeeds() async {
    userData = await UserLocalStorage.getUserData();
    await Future.delayed(Duration(milliseconds: 400)).then((v) {
      callOtherProfileWB(context);
    });
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
        title: Localizer.get(AppText.userProfile.key),
        backgroundColor: AppColor().kNavigationColor,
        backIcon: Icons.chevron_left,
        showBackButton: true,
        onBackPressed: () {
          // _scaffoldKey.currentState?.openDrawer();
          Navigator.pop(context, 'reload');
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

              callMultiImageWB(true, context, pageNo: 1);
              // setState(() {});
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
          AlertsUtils().showMatchPopup(
            context: context,
            user1Name: "You",
            user2Name: storeFriendsData["firstName"].toString(),
            user1Image: userData["image"].toString(),
            user2Image: storeFriendsData["image"].toString(),
            onStartMessage: () {
              // navigate to chat screen
            },
          );
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

          if (storeFriendStatus == "2") {
            // friends
            return;
          }

          if (storeFriendStatus == "") {
            AlertsUtils.showLoaderUI(
              context: context,
              title: Localizer.get(AppText.pleaseWait.key),
            );
            callSendRequestWB(context);
            return;
          }
          if (storeFriendRequestSenderId != userData['userId'].toString()) {
            GlobalUtils().customLog("Accept request");
            AlertsUtils().showBottomSheetWithTwoBottom(
              context: context,
              message: "Friend request",
              yesTitle: "Yes, accept",
              dismissTitle: "Decline",
              yesButtonColor: AppColor().GREEN,
              // backgroundColor: AppColor().GREEN,
              onYesTap: () async {
                GlobalUtils().customLog("HIT: Yes, accept request");
                await Future.delayed(Duration(milliseconds: 400));
                // call api
                AlertsUtils.showLoaderUI(
                  context: context,
                  title: Localizer.get(AppText.pleaseWait.key),
                );
                callAcceptRejectWB(context, "2");
              },
              onDismissTap: () async {
                GlobalUtils().customLog("HIT: Yes, Decline request");
                await Future.delayed(Duration(milliseconds: 400));
                // call api
                AlertsUtils.showLoaderUI(
                  context: context,
                  title: Localizer.get(AppText.pleaseWait.key),
                );
                callAcceptRejectWB(context, "3");
              },
            );
          } else if (storeFriendRequestSenderId !=
              userData['userId'].toString()) {
            GlobalUtils().customLog("Already sent");
          }
        },
        child: Container(
          margin: EdgeInsets.only(right: 8),
          height: 40,
          width: 80,
          decoration: BoxDecoration(
            color: storeFriendStatus == "2"
                ? AppColor().GREEN
                : storeFriendStatus == ""
                ? AppColor().PURPLE
                : Colors.orange,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (storeFriendStatus == "") ...[
                  customText(
                    "Add friend",
                    12,
                    context,
                    fontWeight: FontWeight.w600,
                    color: AppColor().kWhite,
                  ),
                ] else if (storeFriendStatus == "2") ...[
                  customText(
                    "Friends",
                    14,
                    context,
                    fontWeight: FontWeight.w600,
                    color: AppColor().kWhite,
                  ),
                ] else if (storeFriendRequestSenderId ==
                    userData['userId'].toString()) ...[
                  customText(
                    "Request sent",
                    12,
                    context,
                    fontWeight: FontWeight.w600,
                    color: AppColor().kWhite,
                  ),
                ] else if (storeFriendRequestSenderId !=
                    userData['userId'].toString()) ...[
                  customText(
                    "Request received",
                    12,
                    context,
                    fontWeight: FontWeight.w600,
                    color: AppColor().kWhite,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Feeds
  Widget _feedsViewUIKIT(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 8),
      itemCount: arrFeeds.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == arrFeeds.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final postJson = arrFeeds[index];

        // ✅ Collect images + video together
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
            onShareTap: () =>
                GlobalUtils().customLog("Shared post index $index!"),
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
                  buttonText: "Select",
                  onItemSelected: (s) {
                    if (s == "Delete post") {
                      //callDeletePostWB(context, postJson['postId'].toString());
                    }
                  },
                );
              }
            },
            youLiked: postJson['youliked'] == 1,
            postTitle: postJson['postTitle'].toString(),
            type: postJson["postType"].toString(),
          ),
        );
      },
    );
  }

  Widget _galleryViewUIKIT(context) {
    final List<String> imageUrlList = arrAlbum
        .map<String>((e) => e["image"].toString())
        .toList();

    return MasonryGridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: arrAlbum.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CustomFullScreenImageViewer(
                  imageUrls: imageUrlList, // ✅ Now it's List<String>
                  initialIndex: index,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                arrAlbum[index]["image"].toString(),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  // ====================== API ================================================
  // ====================== FRIEND'S FEED
  Future<void> callFeedsWB(BuildContext context, {required int pageNo}) async {
    final userData = await UserLocalStorage.getUserData();
    GlobalUtils().customLog(userData);
    // return;
    GlobalUtils().customLog(userData['userId'].toString());
    // dismiss keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    // manage ids
    friendId = widget.profileData["userId"].toString();
    if (widget.isFromRequest) {
      //
      GlobalUtils().customLog(widget.profileData);

      if (widget.profileData["senderId"].toString() ==
          userData['userId'].toString()) {
        friendId = widget.profileData["receiverId"].toString();
      } else {
        friendId = widget.profileData["senderId"].toString();
      }
    }

    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadFriendsFeeds(
        action: ApiAction().FEEDS_FRIENDS,
        userId: userData['userId'].toString(),
        friend_user_id: friendId.toString(),
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
    // manage ids
    friendId = widget.profileData["userId"].toString();
    if (widget.isFromRequest) {
      //
      GlobalUtils().customLog(widget.profileData);

      if (widget.profileData["senderId"].toString() ==
          userData['userId'].toString()) {
        friendId = widget.profileData["receiverId"].toString();
      } else {
        friendId = widget.profileData["senderId"].toString();
      }
    }
    // return;
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadOtherUserCheck(
        action: ApiAction().PROFILE,
        userId: userData['userId'].toString(),
        other_profile_Id: friendId.toString(),
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
      /*
      "fnd_status": {
I/flutter (14734): │ 🐛     "requestId": 7,
I/flutter (14734): │ 🐛     "status": 1,
I/flutter (14734): │ 🐛     "senderId": 20,
I/flutter (14734): │ 🐛     "receiverId": 11
I/flutter (14734): │ 🐛   }
*/
      // storeFriendStatus
      if (fndStatus != null && fndStatus is Map<String, dynamic>) {
        GlobalUtils().customLog("✅ Valid fnd_status: $fndStatus");
        storeFriendStatus = fndStatus["status"].toString();
        storeFriendRequestId = fndStatus["requestId"].toString();
        storeFriendRequestSenderId = fndStatus["senderId"].toString();
        storeFriendRequestReceiverId = fndStatus["receiverId"].toString();
      } else {
        GlobalUtils().customLog("❌ fnd_status is empty or invalid");
        storeFriendStatus = "";
      }
      GlobalUtils().customLog(storeFriendStatus);
      // return;
      callFeedsWB(context, pageNo: 1);
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

  // ====================== ACCEPT REJECT
  Future<void> callAcceptRejectWB(context, status) async {
    final userData = await UserLocalStorage.getUserData();
    GlobalUtils().customLog(userData);
    // return;
    GlobalUtils().customLog(userData['userId'].toString());
    // dismiss keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadAcceptReject(
        action: ApiAction().ACCEPT_REJECT,
        userId: userData['userId'].toString(),
        requestId: storeFriendRequestId,
        status: status.toString(), // send request
      ),
    );

    GlobalUtils().customLog("$response");
    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog("✅ POST ACCEPT REQUEST success");

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

  // call multiple images
  Future<void> callMultiImageWB(
    bool loader,
    BuildContext context, {
    required int pageNo,
  }) async {
    FocusScope.of(context).requestFocus(FocusNode());

    if (loader) {
      AlertsUtils.showLoaderUI(
        context: context,
        title: Localizer.get(AppText.pleaseWait.key),
      );
    }

    final userData = await UserLocalStorage.getUserData();
    String imageTypeIs = '';
    imageTypeIs = "1,2,3";

    if (widget.isFromRequest) {
      //
      GlobalUtils().customLog(widget.profileData);

      if (widget.profileData["senderId"].toString() ==
          userData['userId'].toString()) {
        friendId = widget.profileData["receiverId"].toString();
      } else {
        friendId = widget.profileData["senderId"].toString();
      }
    }

    FocusScope.of(context).unfocus();
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadMultiImageList(
        action: ApiAction().MULTI_IMAGE_LIST,
        userId: friendId,
        ImageType: imageTypeIs,
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      List<dynamic> newFeeds = response["data"];
      setState(() {
        if (pageNo == 1) {
          arrAlbum = newFeeds;
        } else {
          arrAlbum.addAll(newFeeds);
        }

        if (newFeeds.length < 10) {
          isLastPage = true;
        }

        screenLoader = false;
      });
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
      AlertsUtils().showExceptionPopup(
        context: context,
        message: response['msg'].toString(),
      );
    }
  }
}
