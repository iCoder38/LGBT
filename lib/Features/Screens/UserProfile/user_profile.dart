import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lgbt_togo/Features/Screens/Chat/chat.dart';
import 'package:lgbt_togo/Features/Screens/Subscription/revenueCat/helper.dart';
import 'package:lgbt_togo/Features/Screens/UserProfile/widgets/add_sent_friend_request_button.dart';
import 'package:lgbt_togo/Features/Screens/UserProfile/widgets/image_grid.dart';
import 'package:lgbt_togo/Features/Screens/UserProfile/widgets/new_request_button.dart';
import 'package:lgbt_togo/Features/Screens/UserProfile/widgets/widgets.dart';
import 'package:lgbt_togo/Features/Screens/change_password/change_password.dart';
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

  bool isSuggestedFriendLoad = false;
  var arrSuggestedFriend = [];

  var storeFriendsData;

  bool isProfileLikedByMe = false;
  bool isProfileLikedByOther = false;

  // login user data get
  var userData;

  String storeFriendStatus = '';
  String storeFriendRequestId = '';
  String storeFriendRequestSenderId = '';
  String storeFriendRequestReceiverId = '';

  String friendId = '';
  String friendName = '';

  /// SUBSCRIPTION CHECK
  bool _isPremium = false;
  bool _willRenew = false;
  String? _expiryDate;
  Map<String, dynamic>? _remaining;
  String? _plan;
  String? _price;

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

  // settings
  String storePrivacyProfile = '3';
  String storePrivacyPost = '3';
  String storePrivacyFriends = '3';
  String storePrivacyPicture = '3';

  bool itsMe = false;

  @override
  void initState() {
    super.initState();
    GlobalUtils().customLog(widget.profileData);

    // _scrollController.addListener(() {
    //   if (_scrollController.position.pixels >=
    //           _scrollController.position.maxScrollExtent - 300 &&
    //       !isLoadingMore &&
    //       !isLastPage) {
    //     currentPage++;
    //     loadMoreFeeds();
    //   }
    // });
    // call profile
    callFeeds();
  }

  void callFeeds() async {
    userData = await UserLocalStorage.getUserData();
    await Future.delayed(Duration(milliseconds: 400)).then((v) {
      _checkSubscription();
    });
  }

  Future<void> _checkSubscription() async {
    final status = await SubscriptionHelper.checkPremiumStatus();

    // setState(() {
    _isPremium = status["isActive"] ?? false;
    _willRenew = status["willRenew"] ?? false;
    _expiryDate = status["expiryDateTime"];
    _remaining = status["remainingTime"];
    _plan = status["plan"];
    _price = status["price"];
    // });

    GlobalUtils().customLog("Subscription status: $status");
    callOtherProfileWB(context);
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
        actions: [
          if (storeFriendStatus == "2") ...[
            IconButton(
              onPressed: () {
                GlobalUtils().customLog(storeFriendsData);
                GlobalUtils().customLog(userData);
                // return;
                NavigationUtils.pushTo(
                  context,
                  FriendlyChatScreen(
                    friendId: storeFriendsData["firebase_id"].toString(),
                    // friendId,
                    friendName: storeFriendsData["firstName"].toString(),
                    senderImage: userData["image"].toString(),
                    receiverImage: storeFriendsData["image"].toString(),
                  ),
                );
              },
              icon: Icon(Icons.chat, color: AppColor().kWhite),
            ),
          ],
        ],
      ),
      drawer: const CustomDrawer(),
      body: screenLoader ? SizedBox() : _UIKIT(context),
      // Add FAB:
      floatingActionButton: ThumbsUpFab(
        initialIsLikedByMe: isProfileLikedByMe,
        isLikedByOther: isProfileLikedByOther,
        friendData: storeFriendsData,
        userData: userData,
        onApiCall: (ctx) => callProfileLikeWB(ctx), // 🔥 API bg mein
        onStartMessage: () {
          // NavigationUtils.pushTo(
          //   context,
          //   FriendlyChatScreen(
          //     friendId: storeFriendsData["firebase_id"].toString(),
          //     friendName: storeFriendsData["firstName"].toString(),
          //     senderImage: userData["image"].toString(),
          //     receiverImage: storeFriendsData["image"].toString(),
          //   ),
          // );
        },
      ),

      // optionally choose location:
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _UIKIT(BuildContext context) {
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
                          "${storeFriendsData["firstName"]} • ${GlobalUtils().calculateAge(storeFriendsData["dob"])}",
                          12,
                          context,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                        const SizedBox(height: 2),
                        customText(
                          storeFriendsData["cityname"].toString(),
                          12,
                          context,
                          color: const Color(0xFFE6D200),
                        ),
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
                      customText(
                        Localizer.get(AppText.post.key),
                        10,
                        context,
                        color: AppColor().GRAY,
                      ),
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
                        Localizer.get(AppText.friends.key),
                        10,
                        context,
                        color: AppColor().GRAY,
                      ),
                    ],
                  ),
                ),
                Expanded(child: SizedBox()),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      /*itsMe == true
                          ? SizedBox()
                          : _widgetThumbsUpUIKit(context),*/
                      if (storeFriendsData["userId"].toString() ==
                          userData['userId'].toString()) ...[
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              NavigationUtils.pushTo(
                                context,
                                AccountSettingsScreen(),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
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
                        ),
                      ] else ...[
                        _widgetAddFriendButtonUIKit(context),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          /*ListTile(
            title: _buildTitle("My Story"),
            subtitle: _buildSubTitle(storeFriendsData["story"].toString()),
          ),
          ListTile(
            title: _buildTitle("Why are you here?"),
            subtitle: _buildSubTitle(storeFriendsData["story"].toString()),
          ),
          ListTile(
            title: _buildTitle("Current City"),
            subtitle: _buildSubTitle(storeFriendsData["city"].toString()),
          ),
          ListTile(
            title: _buildTitle("What do you like?"),
            subtitle: _buildSubTitle(storeFriendsData["city"].toString()),
          ),
          ListTile(
            title: _buildTitle("Bio"),
            subtitle: _buildSubTitle(storeFriendsData["bio"].toString()),
          ),*/
          itsMe
              ? _publicAccountWidget(context)
              :
                /* customText(
                  "LGBT_TOGO_PLUS/USERS/${storeFriendsData["firebase_id"].toString()}/SETTINGS",
                  12,
                  context,
                ),*/
                _realTimePrivacySettingUIKit(),
          //
        ],
      ),
    );
  }

  _buildTitle(String text) {
    return customText(text, 16, context);
  }

  _buildSubTitle(String text) {
    return ReadMoreText(
      storeFriendsData["story"].toString(),
      trimMode: TrimMode.Line,
      trimLines: 3,
      trimLength: 240,
      style: const TextStyle(color: Colors.black),
      colorClickableText: Colors.pink,
      trimCollapsedText: '...Show more',
      trimExpandedText: ' show less',
    );
  }

  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>
  _realTimePrivacySettingUIKit() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .doc(
            "LGBT_TOGO_PLUS/USERS/${storeFriendsData["firebase_id"].toString()}/SETTINGS",
          )
          .snapshots(),
      builder: (context, snapshot) {
        GlobalUtils().customLog("FIREBASE WAITING");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox();
          // const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          GlobalUtils().customLog("FIREBASE NOT EXIST");
          return _privateAccountWidget(context);
        }

        GlobalUtils().customLog("FIREBASE EXIST 2");

        final data = snapshot.data!.data();
        final profilePrivacy = data?['privacy']?['profile']?.toString().trim();

        if (profilePrivacy == "3") {
          return _publicAccountWidget(context);
        } else {
          GlobalUtils().customLog("PRIVATE PROFILE");
          if (storeFriendStatus == "2") {
            return _publicAccountWidget(context);
          }
          return _privateAccountWidget(context);
        }
      },
    );
  }

  Widget _publicAccountWidget(BuildContext context) {
    return Column(
      children: [
        CustomUserProfileThreeButtonTile(
          selectedIndex: selectedTabIndex,
          onMenuTap: () {
            setState(() => selectedTabIndex = 0);
          },
          onImageTap: () {
            setState(() => selectedTabIndex = 1);
            callMultiImageWB(true, context, pageNo: 1);
          },
          onVideoTap: () {
            setState(() => selectedTabIndex = 2);
          },
        ),
        const SizedBox(height: 8),
        if (selectedTabIndex == 0) _feedsViewUIKIT(context),
        if (selectedTabIndex == 1) _galleryViewUIKIT(context),
      ],
    );
  }

  Widget _privateAccountWidget(BuildContext context) {
    return CustomContainer(
      color: AppColor().kNavigationColor,
      shadow: true,
      height: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock, size: 30, color: Colors.white),
          const SizedBox(height: 20),
          customText(
            "This account is Private",
            20,
            context,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  /*Container _widgetThumbsUpUIKit(context) {
    return Container(
      height: 40,
      width: 40,
      color: AppColor().kWhite,
      child: IconButton(
        onPressed: () {
          GlobalUtils().customLog("Hit: Like profile");
          // CHECK IS OTHER USER ALREADY LIKED YOU ?

          if (isProfileLikedByOther == true) {
            GlobalUtils().customLog("Yes, Other already liked you");
            AlertsUtils().showMatchPopup(
              context: context,
              user1Name: "You",
              user2Name: storeFriendsData["firstName"].toString(),
              user1Image: userData["image"].toString(),
              user2Image: storeFriendsData["image"].toString(),
              onStartMessage: () {
                GlobalUtils().customLog(storeFriendsData);
                NavigationUtils.pushTo(
                  context,
                  FriendlyChatScreen(
                    friendId: storeFriendsData["firebase_id"].toString(),
                    // friendId,
                    friendName: storeFriendsData["firstName"].toString(),
                    senderImage: userData["image"].toString(),
                    receiverImage: storeFriendsData["image"].toString(),
                  ),
                );
              },
            );
            if (isProfileLikedByMe == false) {
              setState(() {
                isProfileLikedByMe = true;
              });

              // call api for true handle
              callProfileLikeWB(context);
            }
          } else {
            GlobalUtils().customLog("No, Other not liked you yet.");
            if (isProfileLikedByMe == false) {
              setState(() {
                isProfileLikedByMe = true;
              });
              // call api for true handle
              callProfileLikeWB(context);
            }
          }
        },
        icon: !isProfileLikedByMe
            ? Icon(Icons.thumb_up_alt_rounded)
            : Icon(Icons.thumb_up_alt_rounded, color: AppColor().RED),
      ),
    );
  }*/

  Widget _widgetAddFriendButtonUIKit(context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          /*GlobalUtils().customLog("Hit: Add friend");
          if (storeFriendStatus == "2") {
            return;
          }
          GlobalUtils().customLog(storeFriendsData);

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
          }*/
        },
        child: storeFriendStatus == "2"
            ? FriendStatusButton(
                padding: EdgeInsets.all(12),
                title: "Friends",
                textColor: AppColor().GREEN,
              )
            : storeFriendStatus == ""
            ? AddSentFriendButton(
                receiverId: widget.profileData["userId"].toString(),
              )
            : storeFriendRequestSenderId == userData['userId'].toString()
            ? FriendStatusButton(
                padding: EdgeInsets.all(12),
                title: "Request Sent",
                textColor: AppColor().ORANGE,
              )
            : storeFriendRequestSenderId != userData['userId'].toString()
            ? NewRequestButton(
                padding: EdgeInsets.all(8),
                requestId: storeFriendRequestId,
                receiverId: widget.profileData["userId"].toString(),
              )
            /*FriendStatusButton(
                padding: EdgeInsets.all(12),
                title: "New Request",
                textColor: Colors.amber,
                backgroundColor: AppColor().PURPLE,
              )*/
            : SizedBox(),
        /*Container(
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
                      if (storeFriendRequestSenderId ==
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
              ),*/
      ),
    );
  }

  // Feeds
  Widget _feedsViewUIKIT(BuildContext context) {
    return Column(
      children: [
        !isSuggestedFriendLoad ? SizedBox() : _suggestedFriendUIKIT(),

        ListView.builder(
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
                        int.tryParse(arrFeeds[index]['totalLike'].toString()) ??
                        0;

                    if (arrFeeds[index]['youliked'] == 1) {
                      arrFeeds[index]['youliked'] = 0;
                      if (currentLikes > 0) {
                        arrFeeds[index]['totalLike'] = (currentLikes - 1)
                            .toString();
                      }
                    } else {
                      arrFeeds[index]['youliked'] = 1;
                      arrFeeds[index]['totalLike'] = (currentLikes + 1)
                          .toString();
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
                    UserProfileScreen(
                      profileData: postJson,
                      isFromRequest: false,
                    ),
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
                ishoriz: true,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _suggestedFriendUIKIT() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < arrSuggestedFriend.length; i++) ...[
            CustomContainer(
              color: AppColor().kWhite,
              shadow: true,
              height: 180,
              width: 180,
              child: Column(
                children: [
                  SizedBox(
                    height: 130,
                    width: 180,
                    child: GestureDetector(
                      onTap: () {
                        NavigationUtils.pushTo(
                          context,
                          UserProfileScreen(
                            profileData: arrSuggestedFriend[i],
                            isFromRequest: false,
                          ),
                        );
                      },
                      child: CachedNetworkImage(
                        imageUrl: arrSuggestedFriend[i]["profile_picture"]
                            .toString(),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      NavigationUtils.pushTo(
                        context,
                        UserProfileScreen(
                          profileData: arrSuggestedFriend[i],
                          isFromRequest: false,
                        ),
                      );
                    },
                    child: Container(
                      color: Colors.transparent,

                      // height: 34,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          customText(
                            arrSuggestedFriend[i]["firstName"].toString(),
                            16,
                            context,
                            fontWeight: FontWeight.w600,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              customText(
                                "${GlobalUtils().calculateAge(arrSuggestedFriend[i]["dob"].toString())} || ${arrSuggestedFriend[i]["gender"].toString()}",
                                10,
                                context,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _galleryViewUIKIT(BuildContext context) {
    return CustomImageGrid(
      friendStatusDefault: int.tryParse(storeFriendStatus) ?? 1,
      isPremiumDefault: _isPremium,
      items: arrAlbum,
      crossAxisCount: 3,
      onItemTap: (index, item) {
        // final imageUrls = arrAlbum.map((e) => e["image"].toString()).toList();
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => CustomFullScreenImageViewer(
        //       imageUrls: imageUrls,
        //       initialIndex: index,
        //     ),
        //   ),
        // );
      },
    );
  }

  // ====================== API ================================================
  // ====================== FRIEND'S FEED
  Future<void> callFeedsWB(BuildContext context, {required int pageNo}) async {
    final userData = await UserLocalStorage.getUserData();

    GlobalUtils().customLog(userData);

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
      arrFeeds = response["data"];
      setState(() {
        // isSuggestedFriendLoad = true;
        // arrSuggestedFriend = response["data"];
        screenLoader = false;
      });
      // call suggested friends
      // callSuggestedFriendsWB(userData["cityname"].toString());
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

    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadOtherUserCheck(
        action: ApiAction().PROFILE,
        userId: userData['userId'].toString(),
        other_profile_Id: friendId.toString(),
      ),
    );

    GlobalUtils().customLog("$response");
    // return;
    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog("✅ POST $response success");
      storeFriendsData = response["data"];
      /*GlobalUtils().customLog("""
My id: ${userData['userId'].toString()}
Friend Id: ${storeFriendsData["userId"].toString()}
""");*/
      // return;
      // check is it me or not
      if (storeFriendsData["userId"].toString() ==
          userData['userId'].toString()) {
        itsMe = true;
      } else {
        itsMe = false;
      }

      GlobalUtils().customLog(storeFriendsData);
      // return;

      // CHECK: IS LOGIN USER LIKED THIS USER'S PROFILE
      if (storeFriendsData["you_liked_profile"].toString() == "1") {
        isProfileLikedByMe = true;
      }

      // CHECK: IS OTHER USER LIKED MY PROFILE
      if (storeFriendsData["he_liked_profile"].toString() == "1") {
        isProfileLikedByOther = true;
      }

      // CHECK: FRIEND STATUS [ 2 = FRIENDS ]
      final fndStatus = storeFriendsData['fnd_status'];

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
      GlobalUtils().customLog("Friend Status: $storeFriendStatus");
      // return;
      callGetSettings(context);
      // callFeedsWB(context, pageNo: 1);
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
  Future<void> callProfileLikeWB(BuildContext context) async {
    // GlobalUtils().customLog("🔥 Like API started");
    // await Future.delayed(Duration(seconds: 2));
    // GlobalUtils().customLog("✅ Like API done");
    // return;
    try {
      final userData = await UserLocalStorage.getUserData();

      // fire-and-forget request, but UI not blocked
      final response = await ApiService().postRequest(
        ApiPayloads.PayloadProfileLike(
          action: ApiAction().LIKE_PROFILE,
          userId: userData['userId'].toString(),
          profileId: widget.profileData["userId"].toString(),
          status: '1',
        ),
      );

      if (response['status'].toString().toLowerCase() == "success") {
        CustomFlutterToastUtils.showToast(
          message: response['msg'],
          backgroundColor: AppColor().GREEN,
        );
      } else {
        AlertsUtils().showExceptionPopup(
          context: context,
          message: response['msg'].toString(),
        );
      }
    } catch (e) {
      GlobalUtils().customLog("Like API error: $e");
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
  /*Future<void> callAcceptRejectWB(context, status) async {
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
  }*/

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
    /*
    /*
  int getImageType() {
    switch (selectedOption) {
      case 'Public':
        return 1;
      case 'Friends':
        return 2;
      case 'Private':
        return 3;
      default:
        return 1;
    }
  }

  public = 3
      private = 2
   */
   */
    GlobalUtils().customLog('''
        PROFILE: $storePrivacyProfile
        ARE WE FRIENDS: $storeFriendStatus
      ''');

    if (storeFriendStatus == "2") {
      // we are friends
      GlobalUtils().customLog('''We are friends''');
      imageTypeIs = "1,2,3";
    } else {
      if (storeFriendStatus == "" && storePrivacyProfile == "3") {
        // friend status is empty and profile is public
        GlobalUtils().customLog('''FRIEND STATUS: $storeFriendStatus
        PROFILE SETTING: $storePrivacyProfile''');
        imageTypeIs = "1,2,3";
      }
    }

    GlobalUtils().customLog('''IMAGE TYPE: $imageTypeIs''');

    // return;

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

  // settings
  // ----------------------- APIs ---------------------------
  Future<void> callGetSettings(context) async {
    final userData = await UserLocalStorage.getUserData();
    GlobalUtils().customLog(userData['userId'].toString());
    // dismiss keyboard
    FocusScope.of(context).requestFocus(FocusNode());

    //GlobalUtils().customLog(widget.isFromRequest);
    // GlobalUtils().customLog(widget.profileData);

    if (widget.isFromRequest) {
      //
      // GlobalUtils().customLog(widget.profileData);

      if (widget.profileData["senderId"].toString() ==
          userData['userId'].toString()) {
        friendId = widget.profileData["receiverId"].toString();
      } else {
        friendId = widget.profileData["senderId"].toString();
      }
    }

    // GlobalUtils().customLog(friendId);

    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadGetSettings(
        action: ApiAction().GET_SETTINGS,
        userId: friendId,
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog(response);
      // return;
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
    final data = response["data"];

    // ✅ Handle empty string data (new user case)
    if (data is String && data.isEmpty) {
      GlobalUtils().customLog("👤 New user: applying default privacy settings");
      // return;
      setState(() {
        storePrivacyProfile = '3';
        storePrivacyPost = '3';
        storePrivacyFriends = '3';
        storePrivacyPicture = '3';
        screenLoader = false;
      });
      // return;
      callFeedsWB(context, pageNo: 1);
      return;
    }

    // ✅ If data is present and has keys
    storePrivacyProfile = data["P_S_Profile"]?.toString() ?? '3';
    storePrivacyPost = data["P_S_Post"]?.toString() ?? '3';
    storePrivacyFriends = data["P_S_Friends"]?.toString() ?? '3';
    storePrivacyPicture = data["P_S_Profile_picture"]?.toString() ?? '3';
    GlobalUtils().customLog('''
        PROFILE: $storePrivacyProfile
        ARE WE FRIENDS: $storeFriendStatus
      ''');
    // return;
    callFeedsWB(context, pageNo: 1);
  }

  Future<void> callSuggestedFriendsWB(String keyword) async {
    final userData = await UserLocalStorage.getUserData();
    var payload = {
      "action": "userlist",
      "userId": userData['userId'].toString(),
      "keyword": keyword,
    };
    GlobalUtils().customLog(payload);

    try {
      final response = await callCommonNetwordApi(payload);

      GlobalUtils().customLog(response);
      if (response['status'].toString().toLowerCase() == "success") {
        setState(() {
          isSuggestedFriendLoad = true;
          arrSuggestedFriend = response["data"];
          // screenLoader = false;
        });
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
}
