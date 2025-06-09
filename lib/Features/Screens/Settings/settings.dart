import 'package:lgbt_togo/Features/Screens/Settings/Email/email.dart';
import 'package:lgbt_togo/Features/Screens/Settings/Notification/notifications.dart';
import 'package:lgbt_togo/Features/Screens/Settings/Privacy/privacy.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

void main() {
  runApp(const MaterialApp(home: AccountSettingsScreen()));
}

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
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
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppImage().BG_3),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: 280,
                width: double.infinity,
                color: Colors.black.withOpacity(0.5),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 12),
                          customText(
                            "",
                            14,
                            context,
                            color: AppColor().kWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Donnie McClurrink",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      customText(
                        "32 Year | Male",
                        16,
                        context,
                        color: AppColor().TEAL,
                      ),
                      const SizedBox(height: 12),
                      customText(
                        "Donniemccluttink@yahoo.com",
                        14,
                        context,
                        color: AppColor().kWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: 0,
                right: 0,
                child: Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage(AppImage().BG_2),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          const Divider(height: 1),
          buildTile(context, "General Settings"),
          buildTile(context, "Privacy Settings"),
          buildTile(context, "Notification Settings"),
          buildTile(context, "Email Settings"),
          buildTile(context, "Languages"),
          buildTile(context, "Delete Account", isDestructive: true),
        ],
      ),
    );
  }

  Widget buildTile(context, String title, {bool isDestructive = false}) {
    return Column(
      children: [
        ListTile(
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (title == "Privacy Settings") ...[
                Icon(
                  Icons.privacy_tip,
                  size: 18,
                  color: AppColor().PRIMARY_COLOR,
                ),
              ] else if (title == "Notification Settings") ...[
                Icon(
                  Icons.notifications,
                  size: 18,
                  color: AppColor().PRIMARY_COLOR,
                ),
              ] else if (title == "Email Settings") ...[
                Icon(Icons.email, size: 18, color: AppColor().PRIMARY_COLOR),
              ] else if (title == "General Settings") ...[
                Icon(Icons.person, size: 18, color: AppColor().PRIMARY_COLOR),
              ] else if (title == "Languages") ...[
                Icon(Icons.language, size: 18, color: AppColor().PRIMARY_COLOR),
              ] else if (title == "Delete Account") ...[
                Icon(Icons.delete, size: 18, color: AppColor().RED),
              ],
            ],
          ),
          title: customText(
            title,
            14,
            context,
            color: isDestructive ? AppColor().RED : AppColor().kBlack,
            fontWeight: isDestructive ? FontWeight.w600 : FontWeight.w400,
          ),

          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            if (title == "Privacy Settings") {
              NavigationUtils.pushTo(context, PrivacyScreen());
            }
            if (title == "Notification Settings") {
              NavigationUtils.pushTo(context, NotificationsScreen());
            }
            if (title == "Email Settings") {
              NavigationUtils.pushTo(context, EmailScreen());
            }
          },
        ),
        const Divider(height: 1),
      ],
    );
  }
}
