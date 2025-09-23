import 'package:lgbt_togo/Features/Screens/Dashboard/post_details.dart';
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

  bool isLoaderShow = false;
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
      body: _UIKIT(),
    );
  }

  ListView _UIKIT() {
    return ListView.separated(
      itemCount: arrNotification.length,
      itemBuilder: (context, index) {
        final notification = arrNotification[index];
        return ListTile(
          title: customText(
            notification["message"].toString(),
            14,
            context,
            fontWeight: notification["read_status"].toString() == "0"
                ? FontWeight.w600
                : FontWeight.w400,
          ),
          subtitle: customText(
            GlobalUtils().formatTimeAgoFromServer(
              notification["created"].toString(),
            ),
            12,
            context,
            color: AppColor().GRAY,
          ),
          trailing: notification["read_status"].toString() != "0"
              ? SizedBox()
              : Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: AppColor().RED,
                  ),
                ),
          onTap: () async {
            FocusScope.of(context).requestFocus(FocusNode());
            AlertsUtils.showLoaderUI(
              context: context,
              title: Localizer.get(AppText.pleaseWait.key),
            );
            await Future.delayed(Duration(milliseconds: 400));
            callNotificationReadWB(
              notificationId: notification["notificationId"].toString(),
              postId: notification["postId"].toString(),
              typeOf: notification["type_of"].toString(),
            );
          },
        );
      },
      separatorBuilder: (context, index) => Divider(),
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
      if (isLoaderShow == true) {
        Navigator.pop(context);
        isLoaderShow = false;
      }
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

  Future<void> callNotificationReadWB({
    required String notificationId,
    required String postId,
    required String typeOf,
  }) async {
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadNotificationRead(
        action: ApiAction().NOTIFICATION_UPDATE,
        notificationId: notificationId,
      ),
    );
    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog("✅ $response");
      // return;
      Navigator.pop(context);
      final result;
      if (typeOf == "Like") {
        result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(postId: postId),
          ),
        );
      } else {
        result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FriendsScreen()),
        );
      }

      if (result == true) {
        isLoaderShow = true;
        AlertsUtils.showLoaderUI(
          context: context,
          title: Localizer.get(AppText.pleaseWait.key),
        );
        callNotificationWB();
      }
    } else {
      Navigator.pop(context);
    }
  }
}
