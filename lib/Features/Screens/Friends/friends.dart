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

  @override
  void initState() {
    super.initState();

    callInitAPI();
  }

  void callInitAPI() async {
    await Future.delayed(Duration(milliseconds: 400)).then((v) {
      callFriendsWB(context);
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
    );
  }

  Widget _UIKIT() {
    if (arrFriends.isEmpty) {
      return Center(
        child: customText(
          "No friends",
          16,
          context,
          fontWeight: FontWeight.w600,
          color: AppColor().GRAY,
        ),
      );
    } else {
      return ListView.builder(
        itemCount: arrFriends.length,
        itemBuilder: (context, index) {
          return CustomUserTile(
            leading: CustomCacheImageForUserProfile(
              imageURL: AppImage().DUMMY_1,
            ),
            title: "Rebecca smith",
            subtitle: "32 Years | Female",
          );
        },
      );
    }
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
}
