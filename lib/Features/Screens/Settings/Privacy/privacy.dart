import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  //
  String storePrivacyProfile = 'Friends';
  String storePrivacyPost = 'Friends';
  String storePrivacyFriends = 'Friends';
  String storePrivacyPicture = 'Friends';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title:
            "${Localizer.get(AppText.privacy.key)} ${Localizer.get(AppText.setting.key)}",
        backgroundColor: AppColor().kNavigationColor,
        backIcon: Icons.chevron_left,
        showBackButton: true,
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Column(
        children: [
          CustomPrivacyTile(
            title: Localizer.get(AppText.privacyProfile.key),
            selectedOption: storePrivacyProfile,
            onUpdate: (val) => setState(() => storePrivacyProfile = val),
          ),
          CustomPrivacyTile(
            title: Localizer.get(AppText.privacyPost.key),
            selectedOption: storePrivacyPost,
            onUpdate: (val) => setState(() => storePrivacyPost = val),
          ),
          CustomPrivacyTile(
            title: Localizer.get(AppText.privacyFriend.key),
            selectedOption: storePrivacyFriends,
            onUpdate: (val) => setState(() => storePrivacyFriends = val),
          ),
          CustomPrivacyTile(
            title: Localizer.get(AppText.privacyPicture.key),
            selectedOption: storePrivacyPicture,
            onUpdate: (val) => setState(() => storePrivacyPicture = val),
          ),
        ],
      ),
    );
  }
}
