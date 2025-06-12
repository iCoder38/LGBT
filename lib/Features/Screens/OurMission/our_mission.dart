import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class OurMissionScreen extends StatefulWidget {
  const OurMissionScreen({super.key});

  @override
  State<OurMissionScreen> createState() => _OurMissionScreenState();
}

class _OurMissionScreenState extends State<OurMissionScreen> {
  // scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
        title: Localizer.get(AppText.ourMission.key),
        showBackButton: true,
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
      ApiPayloads.PayloadOurMission(action: ApiAction().OUR_MISSION),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog("✅ OUR MISSION success");

      //List<dynamic> newFeeds = response["data"];
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
