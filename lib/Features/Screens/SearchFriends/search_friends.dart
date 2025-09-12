import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class SearchFriendsScreen extends StatefulWidget {
  const SearchFriendsScreen({super.key});

  @override
  State<SearchFriendsScreen> createState() => _SearchFriendsScreenState();
}

class _SearchFriendsScreenState extends State<SearchFriendsScreen> {
  // scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool screenLoader = true;
  var arrFriends = [];

  var userData;
  @override
  void initState() {
    super.initState();

    // callInitAPI();
  }

  void callInitAPI() async {
    userData = await UserLocalStorage.getUserData();
    await Future.delayed(Duration(milliseconds: 400)).then((v) {
      callFriendsWB(context);
    });
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
                  // call api
                  AlertsUtils.showLoaderUI(
                    context: context,
                    title: Localizer.get(AppText.pleaseWait.key),
                  );
                  callSearchFriendsWB(context, inputText.toString());
                },
              );
            },
            icon: Icon(Icons.search, color: AppColor().kWhite),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      backgroundColor: AppColor().SCREEN_BG,
      body: screenLoader == true
          ? SizedBox()
          : ListView.builder(
              itemCount: arrFriends.length,
              itemBuilder: (context, index) {
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
                      ),
                    );
                  },
                );
              },
            ),
      //widgetFriendTile(context, arrFriends, userData),
    );
  }

  // ====================== API ================================================
  // ====================== FRIENDS LIST
  Future<void> callFriendsWB(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    final userData = await UserLocalStorage.getUserData();
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadFriends(
        action: ApiAction().FRIENDS,
        userId: userData['userId'].toString(),
        status: '2',
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog("✅ FRIENDS success");

      setState(() {
        screenLoader = false;
        arrFriends = response["data"];
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

  Future<void> callSearchFriendsWB(
    BuildContext context,
    String searchedtEXT,
  ) async {
    FocusScope.of(context).requestFocus(FocusNode());
    //clear old array
    arrFriends.clear();
    final userData = await UserLocalStorage.getUserData();
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadSearchFriends(
        action: ApiAction().USER_LIST,
        userId: userData['userId'].toString(),
        keyword: searchedtEXT,
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog("✅ SEARCH FRIENDS success");
      Navigator.pop(context);
      setState(() {
        screenLoader = false;
        arrFriends = response["data"];
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
}
