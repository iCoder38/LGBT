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
      body: screenLoader
          ? SizedBox()
          : widgetFriendTile(
              context,
              '2',
              arrFriends,
              userData,
              onTapReturn: (selectedFriend, {bool isFromIcon = false}) {
                if (isFromIcon) {
                  // Show bottom sheet, menu, etc.
                  GlobalUtils().customLog(selectedFriend);
                  _openAlert(selectedFriend["requestId"].toString());
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
            ),
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

  _openAlert(requestId) {
    AlertsUtils().showCustomBottomSheet(
      context: context,
      message: "Block",
      buttonText: 'Submit',
      onItemSelected: (selectedItem) {
        //  _controller.contGender.text = selectedItem;
        if (selectedItem == "Block") {
          GlobalUtils().customLog(requestId);
          callBlockFriendWB(context, requestId.toString());
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

  Future<void> callBlockFriendWB(BuildContext context, requestId) async {
    FocusScope.of(context).requestFocus(FocusNode());
    AlertsUtils.showLoaderUI(
      context: context,
      title: Localizer.get(AppText.pleaseWait.key),
    );

    final userData = await UserLocalStorage.getUserData();
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadAcceptReject(
        action: ApiAction().ACCEPT_REJECT,
        userId: userData['userId'].toString(),
        requestId: requestId,
        status: "4",
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
