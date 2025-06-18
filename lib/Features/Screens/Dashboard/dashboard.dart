import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool screenLoader = true;

  var arrFeeds = [];

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

  void callFeeds() async {
    await Future.delayed(const Duration(milliseconds: 400)).then((v) {
      currentPage = 1;
      isLastPage = false;
      callFeedsWB(context, pageNo: currentPage);
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
            icon: const Icon(Icons.add),
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
      body: screenLoader ? const SizedBox() : _UIKIT(context),
    );
  }

  Widget _UIKIT(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
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
                      callDeletePostWB(context, postJson['postId'].toString());
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

  // ----------------------- APIs ---------------------------

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
}
