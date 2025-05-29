import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: Localizer.get(AppText.dashboard.key),
        backgroundColor: AppColor().kNavigationColor,
        backIcon: Icons.menu,
        showBackButton: true,
        onBackPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: const CustomDrawer(),
      body: _UIKIT(context),
    );
  }

  Widget _UIKIT(context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(0),
              child: CustomFeedPostCard(
                userName: "Dishant Rajput",
                userImagePath: AppImage().BG_1, // or network url
                timeAgo: "23 days ago",
                feedImagePath: AppImage().BG_4, // or network url
                totalLikes: "100",
                totalComments: "",
                onLikeTap: () => GlobalUtils().customLog("Liked!"),
                onCommentTap: () => GlobalUtils().customLog("Comment tapped!"),
                onShareTap: () => GlobalUtils().customLog("Shared!"),
                onUserTap: () =>
                    GlobalUtils().customLog("User profile tapped!"),
                onCardTap: () => GlobalUtils().customLog("Full feed tapped!"),
                onMenuTap: () => GlobalUtils().customLog("Menu tapped!"),
              ),
            ),
          ],
        );
      },
    );
  }
}
