import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool screenLoader = true;
  var arrNotification = [];

  @override
  void initState() {
    super.initState();

    callNotificationWB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: Localizer.get(AppText.notification.key),
        backgroundColor: AppColor().kNavigationColor,
        backIcon: Icons.menu,
        showBackButton: true,
        onBackPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: const CustomDrawer(),
      backgroundColor: AppColor().SCREEN_BG,
      body: ListView.builder(
        itemCount: arrNotification.length,
        itemBuilder: (context, index) {
          final notification = arrNotification[index];
          return ListTile(
            /*leading: CustomCacheImageForUserProfile(
              imageURL: AppImage().DUMMY_1,
            ),*/
            title: customText(
              notification["message"].toString(),
              14,
              context,
              fontWeight: FontWeight.w600,
            ),
            subtitle: customText(
              notification["created"].toString(),
              12,
              context,
              color: AppColor().GRAY,
            ),
          );
        },
      ),
    );
  }

  // ====================== API ================================================
  // ====================== FRIENDS LIST
  Future<void> callNotificationWB() async {
    // FocusScope.of(context).requestFocus(FocusNode());
    final userData = await UserLocalStorage.getUserData();
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadNotification(
        action: ApiAction().NOTIFICATION_LIST,
        userId: userData['userId'].toString(),
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog("✅ $response");
      setState(() {
        screenLoader = false;
        arrNotification = response["data"];
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
