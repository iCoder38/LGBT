// import 'dart:convert';
// import 'dart:io';
// import 'package:dio/dio.dart';
import 'package:lgbt_togo/Features/Screens/Album/add.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> visibilityOptions = ['Public', 'Friends', 'Private'];
  String selectedOption = 'Public';

  var userData;

  bool screenLoader = true;
  var arrAlbum = [];

  // pagination
  int currentPage = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();

    userData = UserLocalStorage.getUserData();

    // call
    callMultiImageWB(context, pageNo: 1);
  }

  int getImageType() {
    switch (selectedOption) {
      case 'Public':
        return 1;
      case 'Friends':
        return 2;
      case 'Private':
        return 3;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: Localizer.get(AppText.album.key),
        backgroundColor: AppColor().kNavigationColor,
        backIcon: Icons.menu,
        showBackButton: true,
        onBackPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        actions: [
          IconButton(
            onPressed: () {
              NavigationUtils.pushTo(context, AddAlbumScreen());
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: _UIKIT(context),
    );
  }

  Padding _UIKIT(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          customText(
            "Album Visibility",
            14,
            context,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: AppColor().GRAY, width: 1),
              borderRadius: BorderRadius.circular(12),
              color: AppColor().kWhite,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedOption,
                icon: const Icon(Icons.arrow_drop_down),
                isExpanded: true,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColor().kBlack,
                ),
                items: visibilityOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: customText(
                      value,
                      14,
                      context,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedOption = newValue!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------- APIs ---------------------------

  Future<void> callMultiImageWB(
    BuildContext context, {
    required int pageNo,
  }) async {
    final userData = await UserLocalStorage.getUserData();

    FocusScope.of(context).unfocus();
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadMultiImageList(
        action: ApiAction().MULTI_IMAGE_LIST,
        userId: userData['userId'].toString(),
        ImageType: "1",
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      List<dynamic> newFeeds = response["data"];
      setState(() {
        if (pageNo == 1) {
          arrAlbum = newFeeds;
        } else {
          arrAlbum.addAll(newFeeds);
        }

        if (newFeeds.length < 10) {
          isLastPage = true;
        }

        screenLoader = false;
      });
    } else {
      Navigator.pop(context);
      AlertsUtils().showExceptionPopup(
        context: context,
        message: response['msg'].toString(),
      );
    }
  }
}
