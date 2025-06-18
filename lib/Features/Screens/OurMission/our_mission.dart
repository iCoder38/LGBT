import 'package:flutter_html/flutter_html.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class OurMissionScreen extends StatefulWidget {
  const OurMissionScreen({super.key, required this.isOurMission});
  final bool isOurMission;
  @override
  State<OurMissionScreen> createState() => _OurMissionScreenState();
}

class _OurMissionScreenState extends State<OurMissionScreen> {
  // scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // HTML data
  String htmlData = '';

  bool screenLoader = true;

  @override
  void initState() {
    super.initState();
    callFeeds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: widget.isOurMission
            ? Localizer.get(AppText.ourMission.key)
            : Localizer.get(AppText.aboutLGBT.key),
        backgroundColor: AppColor().kNavigationColor,
        backIcon: Icons.menu,
        showBackButton: true,
        onBackPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: const CustomDrawer(),
      body: screenLoader
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Html(
                data: htmlData,
                style: {
                  "body": Style(
                    fontSize: FontSize(14.0),
                    color: AppColor().kBlack,
                  ),
                  "p": Style(margin: Margins.only(bottom: 8)),

                  "li": Style(
                    fontSize: FontSize(14.0),
                    color: AppColor().kBlack,
                  ),
                },
              ),
            ),
    );
  }

  void callFeeds() async {
    await Future.delayed(Duration(milliseconds: 400)).then((v) {
      callOurMissionWB(context);
    });
  }

  // ====================== API ================================================
  // ====================== OUR MISSION
  Future<void> callOurMissionWB(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadOurMission(
        action: widget.isOurMission
            ? ApiAction().OUR_MISSION
            : ApiAction().ABOUT_US,
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog("✅ OUR MISSION success");

      setState(() {
        htmlData = response["msg"].toString();
        screenLoader = false;
      });
    } else {
      GlobalUtils().customLog("Failed to view stories: $response");

      Navigator.pop(context);
      AlertsUtils().showExceptionPopup(
        context: context,
        message: response['msg'].toString(),
      );
    }
  }
}
