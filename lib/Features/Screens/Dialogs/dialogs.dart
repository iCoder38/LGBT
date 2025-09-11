import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class DialogsScreen extends StatefulWidget {
  const DialogsScreen({super.key});

  @override
  State<DialogsScreen> createState() => _DialogsScreenState();
}

class _DialogsScreenState extends State<DialogsScreen> {
  // scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: Localizer.get(AppText.chat.key),
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
              "32 ${Localizer.get(AppText.years.key)} | Female",
              12,
              context,
              color: AppColor().GRAY,
            ),
            trailing: CustomContainer(
              color: AppColor().PURPLE,
              shadow: false,
              borderRadius: 20,
              height: 40,
              width: 40,
              margin: EdgeInsets.all(0),
              child: Center(
                child: Icon(Icons.chat, color: AppColor().kWhite, size: 16),
              ),
            ),
          );
        },
      ),
    );
  }
}
