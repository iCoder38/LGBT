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
      body: screenLoader == true ? SizedBox() : _UIKIT(),
    );
  }

  Widget _UIKIT() {
    if (arrFriends.isEmpty) {
      return Center(
        child: customText(
          Localizer.get(AppText.blockedMessage.key),
          12,
          context,
        ),
      );
    }

    return ListView.builder(
      itemCount: arrFriends.length,
      itemBuilder: (context, index) {
        var friendsData = arrFriends[index];

        bool isSender =
            friendsData["senderId"].toString() == userData['userId'].toString();
        var profileData = isSender
            ? friendsData["Receiver"]
            : friendsData["Sender"];

        return CustomUserTile(
          leading: CustomCacheImageForUserProfile(
            imageURL: profileData["profile_picture"].toString(),
          ),
          title: profileData["firstName"].toString(),
          subtitle:
              "${GlobalUtils().calculateAge(profileData["dob"].toString())} | ${profileData["gender"].toString()}",
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _openAlert(friendsData["requestId"].toString());
            },
          ),
          onTap: () {
            // onTapReturn(friendsData, isFromIcon: false);
          },
        );
      },
    );
  }

  _openAlert(data) {
    AlertsUtils().showCustomBottomSheet(
      context: context,
      message: "Unblock",
      buttonText: 'Submit',
      onItemSelected: (selectedItem) {
        //  _controller.contGender.text = selectedItem;
        if (selectedItem == "Unblock") {
          // GlobalUtils().customLog(data);
          callUnBlockFriendWB(context, data);
        }
      },
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

  Future<void> callUnBlockFriendWB(
    BuildContext context,
    String requestId,
  ) async {
    final userData = await UserLocalStorage.getUserData();

    // return;
    FocusScope.of(context).requestFocus(FocusNode());
    AlertsUtils.showLoaderUI(
      context: context,
      title: Localizer.get(AppText.pleaseWait.key),
    );

    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadBlockFriend(
        action: ApiAction().UN_BLOCK,
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
