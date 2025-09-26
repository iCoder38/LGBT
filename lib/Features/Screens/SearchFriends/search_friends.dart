import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class SearchFriendsScreen extends StatefulWidget {
  const SearchFriendsScreen({super.key});

  @override
  State<SearchFriendsScreen> createState() => _SearchFriendsScreenState();
}

class _SearchFriendsScreenState extends State<SearchFriendsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  bool screenLoader = true;
  bool isLoadingMore = false;
  bool isRequestInProgress = false; // prevent concurrent requests
  int currentPage = 1;
  bool hasMore = true;

  List<dynamic> arrFriends = [];
  var userData;

  @override
  void initState() {
    super.initState();
    callInitAPI();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 150 &&
          !isLoadingMore &&
          hasMore &&
          !isRequestInProgress) {
        loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void callInitAPI() async {
    userData = await UserLocalStorage.getUserData();
    await Future.delayed(const Duration(milliseconds: 400));
    // Show loader before first page
    AlertsUtils.showLoaderUI(
      context: context,
      title: Localizer.get(AppText.pleaseWait.key),
    );
    await callSearchFriendsWB(
      context,
      "",
      page: 1,
      clear: true,
      showLoader: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: Localizer.get(AppText.searchFriend.key),
        backgroundColor: AppColor().kNavigationColor,
        backIcon: Icons.menu,
        showBackButton: true,
        onBackPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        actions: [
          IconButton(
            onPressed: () {
              AlertsUtils().showCustomAlertWithTextfield(
                context: context,
                title:
                    "${Localizer.get(AppText.searchFriend.key)} ${Localizer.get(AppText.friend.key)}",
                buttonText: Localizer.get(AppText.searchFriend.key),
                onConfirm: (inputText) {
                  GlobalUtils().customLog('User entered: $inputText');
                  AlertsUtils.showLoaderUI(
                    context: context,
                    title: Localizer.get(AppText.pleaseWait.key),
                  );
                  callSearchFriendsWB(
                    context,
                    inputText.toString(),
                    page: 1,
                    clear: true,
                    showLoader: true,
                  );
                },
              );
            },
            icon: Icon(Icons.search, color: AppColor().kWhite),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      backgroundColor: AppColor().SCREEN_BG,
      body: screenLoader
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                // Pull to refresh resets to page 1
                await callSearchFriendsWB(
                  context,
                  "",
                  page: 1,
                  clear: true,
                  showLoader: false,
                );
              },
              child: _UIKIT(),
            ),
    );
  }

  Widget _UIKIT() {
    if (arrFriends.isEmpty) {
      return ListView(
        // ListView so RefreshIndicator works when empty
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(child: customText("No data found", 14, context)),
          ),
        ],
      );
    }

    return ListView.separated(
      controller: _scrollController,
      itemCount: arrFriends.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == arrFriends.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        var friendsData = arrFriends[index];
        return CustomUserTile(
          leading: CustomCacheImageForUserProfile(
            imageURL: friendsData["profile_picture"].toString(),
          ),
          title: friendsData["firstName"].toString(),
          subtitle:
              "${GlobalUtils().calculateAge(friendsData["dob"].toString())} | ${friendsData["gender"].toString()}",
          onTap: () {
            NavigationUtils.pushTo(
              context,
              UserProfileScreen(
                profileData: friendsData,
                isFromRequest: false,
                isFromLoginDirect: false,
              ),
            );
          },
        );
      },
      separatorBuilder: (context, index) => Divider(),
    );
  }

  // ====================== API ======================
  /// Call search friends. If [showLoader] is true, this method will POP the loader dialog it showed.
  Future<void> callSearchFriendsWB(
    BuildContext context,
    String searchedText, {
    required int page,
    bool clear = false,
    bool showLoader = false, // only pop dialog when this is true
  }) async {
    if (isRequestInProgress) return;
    isRequestInProgress = true;

    FocusScope.of(context).requestFocus(FocusNode());
    final userDataLocal = await UserLocalStorage.getUserData();

    try {
      Map<String, dynamic> response = await ApiService().postRequest(
        ApiPayloads.PayloadSearchFriends(
          action: ApiAction().USER_LIST,
          userId: userDataLocal['userId'].toString(),
          keyword: searchedText,
          pageNo: page,
        ),
      );

      if (showLoader && Navigator.canPop(context)) {
        // pop the loader we showed earlier
        Navigator.pop(context);
      }

      if (!mounted) return;

      if (response['status'].toString().toLowerCase() == "success") {
        GlobalUtils().customLog("✅ SEARCH FRIENDS success");

        setState(() {
          screenLoader = false;
          currentPage = page;
          if (clear) {
            arrFriends = List<dynamic>.from(response["data"] ?? []);
            hasMore = (response["data"] as List).isNotEmpty;
          } else {
            final newData = List<dynamic>.from(response["data"] ?? []);
            arrFriends.addAll(newData);
            hasMore = newData.isNotEmpty;
          }
        });
      } else {
        GlobalUtils().customLog("Failed: $response");
        if (showLoader && Navigator.canPop(context)) Navigator.pop(context);
        AlertsUtils().showExceptionPopup(
          context: context,
          message: response['msg'].toString(),
        );
      }
    } catch (e, st) {
      GlobalUtils().customLog("Exception in callSearchFriendsWB: $e\n$st");
      if (showLoader && Navigator.canPop(context)) Navigator.pop(context);
      AlertsUtils().showExceptionPopup(context: context, message: e.toString());
    } finally {
      isRequestInProgress = false;
    }
  }

  void loadMore() {
    if (!hasMore) return;
    setState(() => isLoadingMore = true);
    // When loading more we DON'T show loader dialog, so pass showLoader: false
    callSearchFriendsWB(
      context,
      "",
      page: currentPage + 1,
      clear: false,
      showLoader: false,
    ).whenComplete(() {
      if (mounted) setState(() => isLoadingMore = false);
    });
  }
}
