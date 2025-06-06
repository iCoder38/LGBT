import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class SearchFriendsScreen extends StatefulWidget {
  const SearchFriendsScreen({super.key});

  @override
  State<SearchFriendsScreen> createState() => _SearchFriendsScreenState();
}

class _SearchFriendsScreenState extends State<SearchFriendsScreen> {
  // scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: Localizer.get(AppText.searchFriend.key),
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
          return CustomUserTile(
            leading: CustomCacheImageForUserProfile(
              imageURL: AppImage().DUMMY_1,
            ),
            title: "Rebecca smith",
            subtitle: "32 Years | Female",
            trailing: CustomContainer(
              color: AppColor().PURPLE,
              shadow: false,
              borderRadius: 20,
              height: 40,
              width: 100,
              margin: EdgeInsets.zero,
              child: Center(
                child: customText(
                  "View",
                  12,
                  context,
                  color: AppColor().kWhite,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
