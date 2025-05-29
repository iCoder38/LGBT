import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class UnblockFriendsScreen extends StatefulWidget {
  const UnblockFriendsScreen({super.key});

  @override
  State<UnblockFriendsScreen> createState() => _UnblockFriendsScreenState();
}

class _UnblockFriendsScreenState extends State<UnblockFriendsScreen> {
  // scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: Localizer.get(AppText.unblockFriend.key),
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
                title: "Search friend",
                buttonText: "Search",
                onConfirm: (inputText) {
                  GlobalUtils().customLog('User entered: $inputText');
                },
              );
            },
            icon: Icon(Icons.search, color: AppColor().kWhite),
          ),
        ],
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
              "Rebecca smith",
              16,
              context,
              fontWeight: FontWeight.w600,
            ),
            subtitle: customText(
              "New york, USA",
              12,
              context,
              color: AppColor().GRAY,
            ),
            trailing: CustomContainer(
              color: AppColor().GREEN,
              shadow: false,
              borderRadius: 12,
              height: 34,
              width: 100,
              margin: EdgeInsets.all(0),
              child: Center(
                child: customText(
                  "Unblock",
                  12,
                  context,
                  color: AppColor().kWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
