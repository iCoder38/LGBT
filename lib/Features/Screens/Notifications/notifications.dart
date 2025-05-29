import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CustomCacheImageForUserProfile(
              imageURL: AppImage().DUMMY_1,
            ),
            title: customText(
              '"Rebecca smith" followed you',
              14,
              context,
              fontWeight: FontWeight.w600,
            ),
            subtitle: customText(
              "2 hrs ago",
              12,
              context,
              color: AppColor().GRAY,
            ),
          );
        },
      ),
    );
  }
}
