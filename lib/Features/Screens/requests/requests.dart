import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  // scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // loader
  bool screenLoader = true;

  var arrFriends = [];
  var userData;
  @override
  void initState() {
    super.initState();

    callInitAPI();
  }

  void callInitAPI() async {
    userData = await UserLocalStorage.getUserData();
    await Future.delayed(Duration(milliseconds: 400)).then((v) {
      callFriendsRequestsWB(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: Localizer.get(AppText.requests.key),
        backgroundColor: AppColor().kNavigationColor,
        backIcon: Icons.menu,
        showBackButton: true,
        onBackPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: const CustomDrawer(),
      backgroundColor: AppColor().SCREEN_BG,
      body: screenLoader
          ? SizedBox()
          : ListView.builder(
              itemCount: arrFriends.length,
              itemBuilder: (context, index) {
                var friendsData = arrFriends[index];
                if (friendsData["status"].toString() == "2") {
                  return SizedBox();
                } else {
                  if (friendsData["senderId"].toString() ==
                      userData['userId'].toString()) {
                    return CustomUserTile(
                      // sent
                      leading: CustomCacheImageForUserProfile(
                        imageURL: friendsData["Receiver"]["profile_picture"]
                            .toString(),
                      ),
                      title: friendsData["Receiver"]["firstName"].toString(),
                      subtitle:
                          "${GlobalUtils().calculateAge(friendsData["Receiver"]["dob"].toString())} || ${friendsData["Receiver"]["gender"].toString()}",
                      trailing: Container(
                        decoration: BoxDecoration(
                          color: AppColor().ORANGE,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        height: 40,
                        width: 80,
                        child: Center(
                          child: customText(
                            "Sent",
                            14,
                            context,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      onTap: () {
                        NavigationUtils.pushTo(
                          context,
                          UserProfileScreen(
                            profileData: friendsData,
                            isFromRequest: true,
                          ),
                        );
                      },
                    );

                    // customText("Sent", 12, context);
                  } else {
                    // received
                    return CustomUserTile(
                      leading: CustomCacheImageForUserProfile(
                        imageURL: friendsData["Sender"]["profile_picture"]
                            .toString(),
                      ),
                      title: friendsData["Sender"]["firstName"].toString(),
                      subtitle:
                          "${GlobalUtils().calculateAge(friendsData["Sender"]["dob"].toString())} || ${friendsData["Sender"]["gender"].toString()}",
                      trailing: Container(
                        decoration: BoxDecoration(
                          color: AppColor().PURPLE,
                          borderRadius: BorderRadius.circular(2),
                        ),

                        height: 40,
                        width: 80,
                        child: Center(
                          child: customText(
                            "Received",
                            12,
                            context,
                            fontWeight: FontWeight.w600,
                            color: AppColor().kWhite,
                          ),
                        ),
                      ),
                      onTap: () {
                        pushToUserProfile(context, friendsData);
                      },
                    );
                  }
                }
              },
            ),
    );
  }

  Future<void> pushToUserProfile(BuildContext context, friendsData) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            UserProfileScreen(profileData: friendsData, isFromRequest: true),
      ),
    );
    if (!mounted) return;
    if (result == 'reload') {
      setState(() {
        callInitAPI();
      });
    }
  }

  // ====================== API ================================================
  // ====================== FRIENDS REQUEST LIST
  Future<void> callFriendsRequestsWB(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    final userData = await UserLocalStorage.getUserData();
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadFriendsRequests(
        action: ApiAction().FRIENDS,
        userId: userData['userId'].toString(),
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog("✅ FRIENDS REQUESTS success");

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
