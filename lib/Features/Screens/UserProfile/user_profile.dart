import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // clicked tab
  int selectedTabIndex = 0;

  final List<String> imageUrls = [
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
    AppImage().DUMMY_1,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: Localizer.get(AppText.userProfile.key),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImage().BG_1),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        AppImage().BG_1,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        customText(
                          "Katherien Smith",
                          14,
                          context,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(height: 2),
                        customText(
                          "@katheriensmith",
                          12,
                          context,
                          color: Color(0xFFE6D200),
                        ), // yellow tag
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          CustomContainer(
            margin: EdgeInsets.all(0),
            borderRadius: 0,
            color: AppColor().kWhite,
            shadow: false,
            height: 60,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      customText(
                        "231",
                        16,
                        context,
                        fontWeight: FontWeight.w600,
                      ),
                      customText("Posts", 14, context, color: AppColor().GRAY),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      customText(
                        "2000",
                        16,
                        context,
                        fontWeight: FontWeight.w600,
                      ),
                      customText(
                        "Friends",
                        14,
                        context,
                        color: AppColor().GRAY,
                      ),
                    ],
                  ),
                ),
                Expanded(child: SizedBox()),
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        color: AppColor().kWhite,
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.thumb_up_alt_rounded),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: 8),
                          height: 40,
                          width: 80,
                          decoration: BoxDecoration(
                            color: AppColor().PURPLE,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: customText(
                              "ADD FRIEND",
                              14,
                              context,
                              fontWeight: FontWeight.w600,
                              color: AppColor().kWhite,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          CustomUserProfileThreeButtonTile(
            selectedIndex: selectedTabIndex,
            onMenuTap: () {
              selectedTabIndex = 0;
              GlobalUtils().customLog("Menu tapped");
              setState(() {});
            },
            onImageTap: () {
              selectedTabIndex = 1;
              GlobalUtils().customLog("Image tapped");
              setState(() {});
            },
            onVideoTap: () {
              selectedTabIndex = 2;
              GlobalUtils().customLog("Video tapped");
              setState(() {});
            },
          ),
          SizedBox(height: 8),
          if (selectedTabIndex == 0) ...[
            _feedsViewUIKIT(context),
          ] else if (selectedTabIndex == 1) ...[
            _galleryViewUIKIT(context),
          ],
        ],
      ),
    );
  }

  Widget _feedsViewUIKIT(context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 10, // Example count
      itemBuilder: (context, index) {
        // Simulate postJson for now (in real app → use postList[index])
        final Map<String, dynamic> postJson = {
          "image_1": "",
          "image_2": "https://via.placeholder.com/300",
          "image_3": "https://via.placeholder.com/300",
          "image_4": "",
          "image_5": "",
        };

        List<String> prepareFeedImagePaths(Map<String, dynamic> postJson) {
          return [
            postJson['image_1'] ?? '',
            postJson['image_2'] ?? '',
            postJson['image_3'] ?? '',
            postJson['image_4'] ?? '',
            postJson['image_5'] ?? '',
          ].map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
        }

        List<String> feedImagePaths = prepareFeedImagePaths(postJson);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: CustomFeedPostCardHorizontal(
                userName: "Dishant Rajput",
                userImagePath: AppImage().BG_1,
                timeAgo: "23 days ago",
                feedImagePaths: feedImagePaths,
                totalLikes: "100",
                totalComments: "12",
                onLikeTap: () => GlobalUtils().customLog("Liked!"),
                onCommentTap: () => GlobalUtils().customLog("Comment tapped!"),
                onShareTap: () => GlobalUtils().customLog("Shared!"),
                onUserTap: () =>
                    GlobalUtils().customLog("User profile tapped!"),
                onCardTap: () => GlobalUtils().customLog("Full feed tapped!"),
                onMenuTap: () => GlobalUtils().customLog("Menu tapped!"),
                youLiked: true,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _galleryViewUIKIT(context) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: imageUrls.length,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1, // Ensures square images
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CustomFullScreenImageViewer(
                  imageUrls: imageUrls,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(imageUrls[index], fit: BoxFit.cover),
          ),
        );
      },
    );
  }
}
