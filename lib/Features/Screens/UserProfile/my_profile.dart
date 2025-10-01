// File: widgets/profile_fullscreen_sheet.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lgbt_togo/Features/Screens/Subscription/revenueCat/helper.dart';
import 'package:lgbt_togo/Features/Screens/UserProfile/widgets/add_sent_friend_request_button.dart';
import 'package:lgbt_togo/Features/Screens/UserProfile/widgets/new_request_button.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';
import 'package:lgbt_togo/Features/Screens/UserProfile/widgets/widgets.dart';
import 'package:lgbt_togo/Features/Screens/UserProfile/widgets/image_grid.dart';
import 'package:lgbt_togo/Features/Screens/Chat/chat.dart';
import 'package:lgbt_togo/Features/Screens/Dashboard/home_page.dart';

/// Usage:
/// await showProfileFullScreenSheet(context, friendId);
Future<void> showProfileFullScreenSheet(BuildContext context, String friendId) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.95,
      child: ProfileFullScreenSheet(friendId: friendId),
    ),
  );
}

class ProfileFullScreenSheet extends StatefulWidget {
  final String friendId;
  const ProfileFullScreenSheet({Key? key, required this.friendId})
    : super(key: key);

  @override
  _ProfileFullScreenSheetState createState() => _ProfileFullScreenSheetState();
}

class _ProfileFullScreenSheetState extends State<ProfileFullScreenSheet> {
  // Keep variable names & defaults aligned with your UserProfileScreen
  bool screenLoader = true;
  var arrFeeds = [];
  var arrAlbum = [];
  bool isLoadingMore = false;
  bool isLastPage = false;
  int currentPage = 1;
  int selectedTabIndex = 0;

  // from API response
  var storeFriendsData = <String, dynamic>{};
  var userData = <String, dynamic>{};

  bool isProfileLikedByMe = false;
  bool isProfileLikedByOther = false;

  String storeFriendStatus = '';
  String storeFriendRequestId = '';
  String storeFriendRequestSenderId = '';
  String storeFriendRequestReceiverId = '';

  String storeWhyAreYourHere = '';
  String storeStory = '';
  String storeYourBelief = '';
  String storeBio = '';

  bool itsMe = false;

  bool _isPremium = false;

  ScrollController _scrollController = ScrollController();

  String level = '';
  String points = '';

  @override
  void initState() {
    super.initState();
    _init();
    _scrollController.addListener(() {
      // optional: load more if needed (mirrors your existing scroll logic)
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !isLoadingMore &&
          !isLastPage) {
        currentPage++;
        _loadMoreFeeds();
      }
    });
  }

  Future<void> _init() async {
    userData = await UserLocalStorage.getUserData();
    await Future.delayed(Duration(milliseconds: 200));
    await _checkSubscription();
    await _callOtherProfileWB(widget.friendId);
    await _callFeedsWB(pageNo: 1);
    await _callMultiImageWB(pageNo: 1);
    final user = await UserService().getUser(FIREBASE_AUTH_UID());
    GlobalUtils().customLog(user!["levels"]["level"]);
    GlobalUtils().customLog(user["levels"]["points"]);
    level = user["levels"]["level"].toString();
    points = user["levels"]["points"].toString();
    setState(() {
      screenLoader = false;
    });
  }

  Future<void> _checkSubscription() async {
    final status = await SubscriptionHelper.checkPremiumStatus();
    _isPremium = status["isActive"] ?? false;
  }

  Future<void> _callOtherProfileWB(String friendId) async {
    setState(() {
      screenLoader = true;
    });
    try {
      final userLocal = await UserLocalStorage.getUserData();
      Map<String, dynamic> response = await ApiService().postRequest(
        ApiPayloads.PayloadOtherUserCheck(
          action: ApiAction().PROFILE,
          userId: userLocal['userId'].toString(),
          other_profile_Id: friendId.toString(),
        ),
      );

      if (response['status'].toString().toLowerCase() == "success") {
        storeFriendsData = response["data"];
        storeWhyAreYourHere =
            storeFriendsData["why_are_u_here"]?.toString() ?? '';
        storeStory = storeFriendsData["story"]?.toString() ?? '';
        storeBio = storeFriendsData["bio"]?.toString() ?? '';
        storeYourBelief = storeFriendsData["your_belife"]?.toString() ?? '';

        if (storeFriendsData["you_liked_profile"]?.toString() == "1") {
          isProfileLikedByMe = true;
        } else {
          isProfileLikedByMe = false;
        }
        if (storeFriendsData["he_liked_profile"]?.toString() == "1") {
          isProfileLikedByOther = true;
        } else {
          isProfileLikedByOther = false;
        }

        final fndStatus = storeFriendsData['fnd_status'];
        if (fndStatus != null && fndStatus is Map<String, dynamic>) {
          storeFriendStatus = fndStatus["status"]?.toString() ?? '';
          storeFriendRequestId = fndStatus["requestId"]?.toString() ?? '';
          storeFriendRequestSenderId = fndStatus["senderId"]?.toString() ?? '';
          storeFriendRequestReceiverId =
              fndStatus["receiverId"]?.toString() ?? '';
        } else {
          storeFriendStatus = "";
        }

        // check if it's me
        if (storeFriendsData["userId"]?.toString() ==
            userLocal['userId'].toString()) {
          itsMe = true;
        } else {
          itsMe = false;
        }
      } else {
        AlertsUtils().showExceptionPopup(
          context: context,
          message: response['msg'].toString(),
        );
      }
    } catch (e) {
      GlobalUtils().customLog("callOtherProfileWB error: $e");
    } finally {
      setState(() {
        screenLoader = false;
      });
    }
  }

  Future<void> _callFeedsWB({required int pageNo}) async {
    try {
      final userLocal = await UserLocalStorage.getUserData();

      Map<String, dynamic> response = await ApiService().postRequest(
        ApiPayloads.PayloadFriendsFeeds(
          action: ApiAction().FEEDS_FRIENDS,
          userId: userLocal['userId'].toString(),
          friend_user_id: widget.friendId.toString(),
          pageNo: pageNo,
        ),
      );

      if (response['status'].toString().toLowerCase() == "success") {
        if (pageNo == 1) {
          arrFeeds = response["data"];
        } else {
          arrFeeds.addAll(response["data"]);
        }
      } else {
        GlobalUtils().customLog("Failed to get feeds: $response");
      }
    } catch (e) {
      GlobalUtils().customLog("callFeedsWB error: $e");
    }
  }

  Future<void> _loadMoreFeeds() async {
    setState(() => isLoadingMore = true);
    await _callFeedsWB(pageNo: currentPage);
    setState(() => isLoadingMore = false);
  }

  Future<void> _callMultiImageWB({required int pageNo}) async {
    try {
      final userLocal = await UserLocalStorage.getUserData();

      String imageTypeIs = '';
      if (storeFriendStatus == "2") {
        imageTypeIs = "1,2,3";
      } else {
        // if public
        imageTypeIs = "1,2,3";
      }

      Map<String, dynamic> response = await ApiService().postRequest(
        ApiPayloads.PayloadMultiImageList(
          action: ApiAction().MULTI_IMAGE_LIST,
          userId: widget.friendId,
          ImageType: imageTypeIs,
        ),
      );

      if (response['status'].toString().toLowerCase() == "success") {
        List<dynamic> newFeeds = response["data"];
        if (pageNo == 1) {
          arrAlbum = newFeeds;
        } else {
          arrAlbum.addAll(newFeeds);
        }
        if (newFeeds.length < 10) isLastPage = true;
      } else {
        GlobalUtils().customLog("Failed to multiimage: $response");
      }
    } catch (e) {
      GlobalUtils().customLog("_callMultiImageWB error: $e");
    }
  }

  // Mirror your _buildTitle/_buildSubTitle helpers
  Widget _buildTitle(String text) {
    return customText(text, 16, context, fontWeight: FontWeight.w600);
  }

  Widget _buildSubTitle(String text) {
    return ReadMoreText(
      text,
      trimMode: TrimMode.Line,
      trimLines: 3,
      trimLength: 240,
      style: const TextStyle(color: Colors.black),
      colorClickableText: Colors.pink,
      trimCollapsedText: '...Show more',
      trimExpandedText: ' show less',
    );
  }

  // PUBLIC / PRIVATE UI (same stream path)
  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>
  _realTimePrivacySettingUIKit() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .doc(
            "LGBT_TOGO_PLUS/USERS/${storeFriendsData["firebase_id"]?.toString() ?? widget.friendId}/SETTINGS",
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox();
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _privateAccountWidget();
        }

        final data = snapshot.data!.data();
        final profilePrivacy = data?['privacy']?['profile']?.toString().trim();

        if (profilePrivacy == "3") {
          return _publicAccountWidget();
        } else {
          if (storeFriendStatus == "2") {
            return _publicAccountWidget();
          }
          return _privateAccountWidget();
        }
      },
    );
  }

  Widget _publicAccountWidget() {
    return Column(
      children: [
        CustomUserProfileThreeButtonTile(
          selectedIndex: selectedTabIndex,
          onMenuTap: () {
            setState(() => selectedTabIndex = 0);
          },
          onImageTap: () {
            setState(() => selectedTabIndex = 1);
            _callMultiImageWB(pageNo: 1);
          },
          onVideoTap: () {
            setState(() => selectedTabIndex = 2);
          },
        ),
        const SizedBox(height: 8),
        if (selectedTabIndex == 0) _feedsViewUIKIT(),
        if (selectedTabIndex == 1) _galleryViewUIKIT(),
      ],
    );
  }

  Widget _privateAccountWidget() {
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

  Widget _feedsViewUIKIT() {
    return Column(
      children: [
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
                    ProfileFullScreenSheet(
                      friendId: postJson['userId'].toString(),
                    ),
                  );
                },
                onCardTap: () =>
                    GlobalUtils().customLog("Full feed tapped index $index!"),
                onMenuTap: () async {
                  final userLocal = await UserLocalStorage.getUserData();
                  if (userLocal['userId'].toString() ==
                      postJson['userId'].toString()) {
                    AlertsUtils().showCustomBottomSheet(
                      context: context,
                      message: "Delete post",
                      buttonText: "Select",
                      onItemSelected: (s) {
                        if (s == "Delete post") {
                          // implement delete if needed
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

  Widget _galleryViewUIKIT() {
    return CustomImageGrid(
      friendStatusDefault: int.tryParse(storeFriendStatus) ?? 1,
      isPremiumDefault: _isPremium,
      items: arrAlbum,
      crossAxisCount: 3,
      onItemTap: (index, item) {
        // open full screen viewer if you want
      },
    );
  }

  // Like/unlike API (reused)
  Future<void> callLikeUnlikeWB(context, String postId, String status) async {
    final userLocal = await UserLocalStorage.getUserData();
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadLikeUnlike(
        action: ApiAction().FEEDS_LIKE_UNLIKE,
        userId: userLocal['userId'].toString(),
        postId: postId,
        status: status,
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
  }

  Widget _headerWidget() {
    final image = storeFriendsData["image"]?.toString() ?? '';
    final bannerImage = storeFriendsData["BImage"]?.toString() ?? '';
    final name = FIREBASE_AUTH_NAME();
    //storeFriendsData["firstName"]?.toString() ?? '';
    final dob = storeFriendsData["dob"]?.toString() ?? '';
    final city = storeFriendsData["cityname"]?.toString() ?? '';
    final gender =
        genderReverseMap[storeFriendsData["gender"]?.toString()] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: (bannerImage.isNotEmpty)
              ? NetworkImage(bannerImage)
              : AssetImage(AppImage().BG_1) as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: CustomCacheImageForUserProfile(imageURL: image),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText(
                    "$name • ${GlobalUtils().calculateAge(dob)}",
                    12,
                    context,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                  const SizedBox(height: 2),
                  customText(
                    "$city • $gender",
                    12,
                    context,
                    color: const Color(0xFFE6D200),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _countsBar() {
    return CustomContainer(
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
                  storeFriendsData["total_Post"]?.toString() ?? '0',
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
                  storeFriendsData["total_fnd"]?.toString() ?? '0',
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
                if (storeFriendsData["userId"]?.toString() ==
                    userData['userId']?.toString()) ...[
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
                  _widgetAddFriendButtonUIKit(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _widgetAddFriendButtonUIKit() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // you already have callSendRequestWB etc. use them if needed
        },
        child: storeFriendStatus == "2"
            ? FriendStatusButton(
                padding: EdgeInsets.all(12),
                title: "Friends",
                textColor: AppColor().GREEN,
              )
            : storeFriendStatus == ""
            ? AddSentFriendButton(receiverId: widget.friendId)
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
                receiverId: widget.friendId,
              )
            : SizedBox(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: screenLoader
          ? SizedBox(
              height: MediaQuery.of(context).size.height * 0.9,
              child: const Center(child: CircularProgressIndicator()),
            )
          : Column(
              children: [
                // drag handle
                const SizedBox(height: 8),
                Container(
                  height: 4,
                  width: 60,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _headerWidget(),
                        _countsBar(),
                        ListTile(
                          title: _buildTitle("Level || Points"),
                          subtitle: customText(
                            "${level.toString()} || ${points.toString()}",
                            14,
                            context,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        ListTile(
                          title: _buildTitle("My Story"),
                          subtitle: _buildSubTitle(storeStory),
                        ),
                        ListTile(
                          title: _buildTitle("Why are you here?"),
                          subtitle: _buildSubTitle(storeWhyAreYourHere),
                        ),
                        ListTile(
                          title: _buildTitle("What do you like?"),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 0),
                            child: Wrap(
                              spacing: 4,
                              runSpacing: 2,
                              children:
                                  storeFriendsData["interests"]
                                      ?.toString()
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
                                            color: Colors.green.withOpacity(
                                              0.08,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
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
                                      .toList() ??
                                  [],
                            ),
                          ),
                        ),
                        ListTile(
                          title: _buildTitle("Your Belief"),
                          subtitle: _buildSubTitle(storeYourBelief),
                        ),
                        ListTile(
                          title: _buildTitle("Bio"),
                          subtitle: _buildSubTitle(storeBio),
                        ),
                        itsMe
                            ? _publicAccountWidget()
                            : _realTimePrivacySettingUIKit(),
                      ],
                    ),
                  ),
                ),
                // optional floating bottom area placeholder (keeps same look)
                const SizedBox(height: 8),
              ],
            ),
    );
  }
}
