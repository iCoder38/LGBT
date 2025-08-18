import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  // scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int userSelectMembership = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: Localizer.get(AppText.membership.key),
        backgroundColor: AppColor().kNavigationColor,
        backIcon: Icons.menu,
        showBackButton: true,
        onBackPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: const CustomDrawer(),
      backgroundColor: AppColor().SCREEN_BG,
      body: _UIKitWithBG(context),
    );
  }

  Widget _UIKitWithBG(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Image.asset(AppImage().BG_1, fit: BoxFit.cover)),
        _UIKIT(context),
      ],
    );
  }

  Widget _UIKIT(context) {
    return SafeArea(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                userSelectMembership = 1;
              });
            },
            child: CustomContainer(
              height: 150,
              color: AppColor().kWhite,
              shadow: true,
              borderColor: userSelectMembership == 1
                  ? AppColor().kNavigationColor
                  : Colors.transparent,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: customText(
                      "Free Trial Membership",
                      22,
                      context,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Divider(),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.check, color: AppColor().GREEN, size: 16),
                      SizedBox(width: 4),
                      customText("Search and view basic details", 12, context),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.check, color: AppColor().GREEN, size: 16),
                      SizedBox(width: 4),
                      customText("Access to limited content", 12, context),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.check, color: AppColor().GREEN, size: 16),
                      SizedBox(width: 4),
                      customText("Access to limited content", 12, context),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.check, color: AppColor().GREEN, size: 16),
                      SizedBox(width: 4),
                      customText("Basic Support", 12, context),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 2
          GestureDetector(
            onTap: () {
              setState(() {
                userSelectMembership = 2;
              });
            },
            child: CustomContainer(
              height: 180,
              color: AppColor().kWhite,
              shadow: true,
              borderColor: userSelectMembership == 2
                  ? AppColor().kNavigationColor
                  : Colors.transparent,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: customText(
                      "Premium Monthly Plan: Monthly: \$9",
                      22,
                      context,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Divider(),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.check, color: AppColor().GREEN, size: 16),
                      SizedBox(width: 4),
                      customText("View full profile and Photos", 12, context),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.check, color: AppColor().GREEN, size: 16),
                      SizedBox(width: 4),
                      customText("Access to unlimited content", 12, context),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.check, color: AppColor().GREEN, size: 16),
                      SizedBox(width: 4),
                      customText("Access to the premium content", 12, context),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.check, color: AppColor().GREEN, size: 16),
                      SizedBox(width: 4),
                      customText("Priority Support", 12, context),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 3
          GestureDetector(
            onTap: () {
              setState(() {
                userSelectMembership = 3;
              });
            },
            child: CustomContainer(
              height: 200,
              color: AppColor().kWhite,
              shadow: true,
              borderColor: userSelectMembership == 3
                  ? AppColor().kNavigationColor
                  : Colors.transparent,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: customText(
                      "Premium Yearly Plan: Yearly: \$99",
                      22,
                      context,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Divider(),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.check, color: AppColor().GREEN, size: 16),
                      SizedBox(width: 4),
                      customText("View full profile and Photos", 12, context),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.check, color: AppColor().GREEN, size: 16),
                      SizedBox(width: 4),
                      customText("Access to unlimited content", 12, context),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.check, color: AppColor().GREEN, size: 16),
                      SizedBox(width: 4),
                      customText("Access to limited content", 12, context),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.check, color: AppColor().GREEN, size: 16),
                      SizedBox(width: 4),
                      customText("Priority Support", 12, context),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.check, color: AppColor().GREEN, size: 16),
                      SizedBox(width: 4),
                      customText("Early access to new features", 12, context),
                    ],
                  ),
                ],
              ),
            ),
          ),
          userSelectMembership != 1
              ? CustomButton(
                  text: "Subscribe",
                  textColor: AppColor().kWhite,
                  color: AppColor().kNavigationColor,
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
