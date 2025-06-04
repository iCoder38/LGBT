import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<FriendCard> friends = [
    FriendCard(
      name: "Aberash Ada",
      age: 32,
      gender: "Female",
      imageUrl: AppImage().DUMMY_1,
    ),
    FriendCard(
      name: "Donnie Mclurrink",
      age: 39,
      gender: "Male",
      imageUrl: AppImage().DUMMY_1,
    ),
  ];

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
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 8),
          _suggestedFriendsUIKit(),
          SizedBox(height: 12),
          _feedsUIKit(),
        ],
      ),
    );
  }

  // Feeds
  ListView _feedsUIKit() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Padding(
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
            onUserTap: () {
              GlobalUtils().customLog("User profile tapped!");
              NavigationUtils.pushTo(context, UserProfileScreen());
            },
            onCardTap: () => GlobalUtils().customLog("Full feed tapped!"),
            onMenuTap: () => GlobalUtils().customLog("Menu tapped!"),
          ),
        );
      },
    );
  }

  Widget _suggestedFriendsUIKit() {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: friends.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          final friend = friends[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FriendCardWidget(friend: friend),
          );
        },
      ),
    );
  }
}
