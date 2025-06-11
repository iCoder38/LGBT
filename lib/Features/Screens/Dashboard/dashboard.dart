import 'package:lgbt_togo/Features/Screens/Post/post.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool screenLoader = true;

  var arrFeeds = [];

  // pagination
  int currentPage = 1;
  bool isLastPage = false;
  bool isLoadingMore = false;
  ScrollController _scrollController = ScrollController();

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

    // pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        // Reached near bottom
        if (!isLoadingMore && !isLastPage) {
          currentPage++;
          loadMoreFeeds();
        }
      }
    });

    callFeeds();
  }

  void callFeeds() async {
    await Future.delayed(Duration(milliseconds: 400)).then((v) {
      currentPage = 1;
      isLastPage = false;
      callFeedsWB(context, pageNo: currentPage);
    });
  }

  // load more
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
        title: Localizer.get(AppText.dashboard.key),
        backgroundColor: AppColor().kNavigationColor,
        backIcon: Icons.menu,
        showBackButton: true,
        onBackPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        actions: [
          IconButton(
            onPressed: () {
              NavigationUtils.pushTo(context, PostScreen());
            },
            icon: Icon(Icons.add),
          ),
          IconButton(
            onPressed: () {
              callFeeds();
            },
            icon: Icon(Icons.refresh, color: AppColor().kWhite),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: screenLoader == true ? SizedBox() : _UIKIT(context),
    );
  }

  Widget _UIKIT(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8),
      itemCount: arrFeeds.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == arrFeeds.length) {
          // Loader at bottom
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

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

              String statusToSend = arrFeeds[index]['youliked'] == 0
                  ? "2"
                  : "1";

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
            onMenuTap: () {
              GlobalUtils().customLog("Menu tapped index $index!");

              AlertsUtils().showCustomBottomSheet(
                context: context,
                message: "Delete post",
                buttonText: "Select",
                onItemSelected: (s) {
                  GlobalUtils().customLog(s);
                  if (s == "Delete post") {
                    callDeletePostWB(context, postJson['postId'].toString());
                  }
                },
              );
            },

            youLiked: postJson['youliked'] == 1,
            postTitle: postJson['postTitle'].toString(),
          ),
        );
      },
    );
  }

  // Feeds
  /*Widget _feedsViewUIKIT(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          controller: _scrollController,
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
        ),
        if (isLoadingMore)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }*/

  Widget _suggestedFriendsUIKit() {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: friends.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          final friend = friends[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FriendCardWidget(friend: friend),
          );
        },
      ),
    );
  }

  // ====================== API ================================================
  // ====================== DASHBOARD
  Future<void> callFeedsWB(BuildContext context, {required int pageNo}) async {
    final userData = await UserLocalStorage.getUserData();

    FocusScope.of(context).requestFocus(FocusNode());
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadFeeds(
        action: ApiAction().FEEDS,
        userId: userData['userId'].toString(),
        type: "OWN",
        pageNo: pageNo,
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog("✅ DASHBOARD success");

      List<dynamic> newFeeds = response["data"];

      setState(() {
        if (pageNo == 1) {
          arrFeeds = newFeeds;
        } else {
          arrFeeds.addAll(newFeeds);
        }

        // If less than a certain number of items, assume last page (example: 10 per page)
        if (newFeeds.length < 10) {
          isLastPage = true;
        }

        screenLoader = false;
      });
    } else {
      GlobalUtils().customLog("Failed to view stories: $response");
      Navigator.pop(context);
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

  // ====================== DELETE POST
  Future<void> callDeletePostWB(context, String postId) async {
    // loader
    AlertsUtils.showLoaderUI(
      context: context,
      title: Localizer.get(AppText.pleaseWait.key),
    );

    final userData = await UserLocalStorage.getUserData();
    GlobalUtils().customLog(userData);
    // return;
    GlobalUtils().customLog(userData['userId'].toString());
    // dismiss keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadDeletePost(
        action: ApiAction().POST_DELETE,
        userId: userData['userId'].toString(),
        postId: postId,
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog("✅ POST DELETE success");

      callFeeds();
    } else {
      GlobalUtils().customLog("Failed to DELETE POST: $response");
      Navigator.pop(context);
      // show error popup
      AlertsUtils().showExceptionPopup(
        context: context,
        message: response['msg'].toString(),
      );
    }
  }
}
