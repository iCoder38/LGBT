// import 'package:flutter/material.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class BlockedScreen extends StatefulWidget {
  const BlockedScreen({super.key});

  @override
  State<BlockedScreen> createState() => _BlockedScreenState();
}

class _BlockedScreenState extends State<BlockedScreen> {
  bool screenLoader = true;
  var arrFriends = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var userData;

  @override
  void initState() {
    super.initState();
    callInitAPI(false);
  }

  callInitAPI(bool showloader) async {
    userData = await UserLocalStorage.getUserData();
    await Future.delayed(Duration(milliseconds: 400)).then((v) {
      callBlockedListWB(showloader, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: Localizer.get(AppText.blocked.key),
        backgroundColor: AppColor().kNavigationColor,
        backIcon: Icons.menu,
        showBackButton: true,
        onBackPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: const CustomDrawer(),
      backgroundColor: AppColor().SCREEN_BG,
      body: screenLoader == true
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
                  // _openAlert(selectedFriend["requestId"].toString());
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
    );
  }

  // ====================== API ================================================
  // ====================== FRIENDS LIST
  Future<void> callBlockedListWB(loader, BuildContext context) async {
    final userData = await UserLocalStorage.getUserData();
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadBlockedList(
        action: ApiAction().BLOCKED_LIST,
        userId: userData['userId'].toString(),
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
}
