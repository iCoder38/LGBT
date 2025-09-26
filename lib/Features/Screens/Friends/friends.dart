import 'package:lgbt_togo/Features/Screens/Dashboard/home_page.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  // final postDetails;

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  // scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // loader
  bool screenLoader = true;

  var arrFriends = [];
  var userData;
  @override
  void initState() {
    super.initState();

    callInitAPI(false);
  }

  callInitAPI(bool showloader) async {
    userData = await UserLocalStorage.getUserData();
    await Future.delayed(Duration(milliseconds: 400)).then((v) {
      callFriendsWB(showloader, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: Localizer.get(AppText.friend.key),
        backgroundColor: AppColor().kNavigationColor,
        backIcon: Icons.menu,
        showBackButton: true,
        onBackPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        /*actions: [
          IconButton(
            onPressed: () {
              AlertsUtils().showCustomAlertWithTextfield(
                context: context,
                title: "Search friend",
                buttonText: "Search",
                onConfirm: (inputText) {
                  GlobalUtils().customLog('User entered: $inputText');
                },
              );
            },
            icon: Icon(Icons.search, color: AppColor().kWhite),
          ),
        ],*/
      ),
      drawer: const CustomDrawer(),
      backgroundColor: AppColor().SCREEN_BG,
      body: screenLoader ? SizedBox() : _UIKIT(),
      /*widgetFriendTile(
              context,
              '2',
              arrFriends,
              userData,
              onTapReturn: (selectedFriend, {bool isFromIcon = false}) {
                if (isFromIcon) {
                  // Show bottom sheet, menu, etc.
                  GlobalUtils().customLog(selectedFriend);
                  _openAlert(selectedFriend);
                } else {
                  // Navigate to profile
                  NavigationUtils.pushTo(
                    context,
                    UserProfileScreen(
                      profileData: selectedFriend,
                      isFromRequest: true,
                    ),
                  );
                }
              },
            ),*/
      /*widgetFriendTile(
              context,
              "2",
              arrFriends,
              userData,
              onTapReturn: (s) {
                AlertsUtils().showCustomBottomSheet(
                  context: context,
                  message: "Report",
                  buttonText: 'Dismiss',
                  onItemSelected: (selectedItem) {
                    //  _controller.contGender.text = selectedItem;
                  },
                );
              },
            ),*/
    );
  }

  Widget _UIKIT() {
    if (arrFriends.isEmpty) {
      return emptyArrayAlert(
        context,
        Localizer.get(AppText.youDntHaveAnyFriend.key),
      );
    }
    return ListView.builder(
      itemCount: arrFriends.length,
      itemBuilder: (context, index) {
        var friendsData = arrFriends[index];
        if (friendsData["status"].toString() != "2") return SizedBox();

        bool isSender =
            friendsData["senderId"].toString() == userData['userId'].toString();
        var profileData = isSender
            ? friendsData["Receiver"]
            : friendsData["Sender"];

        return friendsData["block_by_sender"].toString() == "1" ||
                friendsData["block_by_receiver"].toString() == "1"
            ? SizedBox()
            : CustomUserTile(
                leading: CustomCacheImageForUserProfile(
                  imageURL: profileData["profile_picture"].toString(),
                ),
                title: profileData["firstName"].toString(),
                subtitle:
                    "${GlobalUtils().calculateAge(profileData["dob"].toString())} | ${genderReverseMap["gender"] ?? "N.A."}",
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    GlobalUtils().customLog(
                      friendsData["requestId"].toString(),
                    );
                    // return;
                    _openAlert(friendsData["requestId"].toString());
                  },
                ),
                onTap: () {
                  GlobalUtils().customLog("Two");
                  // onTapReturn(friendsData, isFromIcon: false);
                  NavigationUtils.pushTo(
                    context,
                    UserProfileScreen(
                      profileData: friendsData,
                      isFromRequest: true,
                      isFromLoginDirect: false,
                    ),
                  );
                },
              );
      },
    );
  }

  _openAlert(data) {
    AlertsUtils().showCustomBottomSheet(
      context: context,
      message: Localizer.get(AppText.blocked.key),
      buttonText: Localizer.get(AppText.submit.key),
      onItemSelected: (selectedItem) {
        //  _controller.contGender.text = selectedItem;
        if (selectedItem == "Block" || selectedItem == "Bloqué") {
          // GlobalUtils().customLog(data);
          callBlockFriendWB(context, data);
        }
      },
    );
  }

  // ====================== API ================================================
  // ====================== FRIENDS LIST
  Future<void> callFriendsWB(loader, BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    final userData = await UserLocalStorage.getUserData();
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadFriends(
        action: ApiAction().FRIENDS,
        userId: userData['userId'].toString(),
        status: "2",
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog("✅ FRIENDS success");
      if (loader) {
        Navigator.pop(context);
      }
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

  Future<void> callBlockFriendWB(BuildContext context, String requestId) async {
    final userData = await UserLocalStorage.getUserData();

    // return;
    FocusScope.of(context).requestFocus(FocusNode());
    AlertsUtils.showLoaderUI(
      context: context,
      title: Localizer.get(AppText.pleaseWait.key),
    );

    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadBlockFriend(
        action: ApiAction().BLOCK,
        userId: userData['userId'].toString(),
        firendId: requestId,
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog("✅ $response");
      callInitAPI(true);
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
