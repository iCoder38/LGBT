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
    getLoginUserData();
  }

  getLoginUserData() async {
    userData = await UserLocalStorage.getUserData();
    // call
    callMultiImageWB(true, context, pageNo: 1);
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

  Widget _UIKIT(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    currentPage = 1;
                    isLastPage = false;
                    arrAlbum.clear();
                    screenLoader = true;
                  });
                  callMultiImageWB(true, context, pageNo: 1);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (arrAlbum.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: arrAlbum.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                final item = arrAlbum[index];
                final imageUrl = item['image'] ?? '';
                final imageType = item['ImageType'] ?? 0;
                final imageId = item['multi_image_id'] ?? 0;

                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        GlobalUtils().customLog("User clicked image");
                        AlertsUtils().showCustomBottomSheet(
                          context: context,
                          isMultiple: false,
                          message: "Friends,Public,Private,Delete Photo",
                          initialSelectedText: getImageTypeLabel(imageType),
                          buttonText: Localizer.get(AppText.submit.key),
                          onItemSelected: (s) async {
                            GlobalUtils().customLog(s);
                            if (s.toString() == "Delete Photo") {
                              await Future.delayed(Duration(milliseconds: 400));
                              AlertsUtils().showBottomSheetWithTwoBottom(
                                context: context,
                                message: Localizer.get(
                                  AppText.deletePhotoMessage.key,
                                ),
                                onYesTap: () async {
                                  HapticFeedback.mediumImpact();
                                  callDeleteWB(context, imageId.toString());
                                },
                                yesTitle: 'Yes, Delete',
                              );
                            } else if (s.toString() == "Friends") {
                              callMultiImageStatusWB(
                                context,
                                imageId.toString(),
                                "2",
                              );
                            } else if (s.toString() == "Public") {
                              callMultiImageStatusWB(
                                context,
                                imageId.toString(),
                                "1",
                              );
                            } else if (s.toString() == "Private") {
                              callMultiImageStatusWB(
                                context,
                                imageId.toString(),
                                "3",
                              );
                            }
                          },
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    customText(
                      getImageTypeLabel(imageType),
                      12,
                      context,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                );
              },
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: customText(
                  "No images found.",
                  14,
                  context,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String getImageTypeLabel(int type) {
    switch (type) {
      case 1:
        return "Public";
      case 2:
        return "Friends";
      case 3:
        return "Private";
      default:
        return "Unknown";
    }
  }

  // ----------------------- APIs ---------------------------
  Future<void> callMultiImageWB(
    bool loader,
    BuildContext context, {
    required int pageNo,
  }) async {
    FocusScope.of(context).requestFocus(FocusNode());

    if (loader) {
      AlertsUtils.showLoaderUI(
        context: context,
        title: Localizer.get(AppText.pleaseWait.key),
      );
    }

    final userData = await UserLocalStorage.getUserData();

    FocusScope.of(context).unfocus();
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadMultiImageList(
        action: ApiAction().MULTI_IMAGE_LIST,
        userId: userData['userId'].toString(),
        ImageType: getImageType().toString(),
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
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
      AlertsUtils().showExceptionPopup(
        context: context,
        message: response['msg'].toString(),
      );
    }
  }

  // delete
  Future<void> callDeleteWB(BuildContext context, String multiImageId) async {
    FocusScope.of(context).requestFocus(FocusNode());
    AlertsUtils.showLoaderUI(
      context: context,
      title: Localizer.get(AppText.pleaseWait.key),
    );

    final userData = await UserLocalStorage.getUserData();

    FocusScope.of(context).unfocus();
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadDeletephoto(
        action: ApiAction().DELETE_MULTI_IMAGE,
        userId: userData['userId'].toString(),
        multi_image_id: multiImageId,
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog(response);
      // show toast
      CustomFlutterToastUtils.showToast(
        message: response['msg'].toString(),
        backgroundColor: AppColor().GREEN,
      );
      // call all images
      callMultiImageWB(false, context, pageNo: 1);
    } else {
      Navigator.pop(context);
      AlertsUtils().showExceptionPopup(
        context: context,
        message: response['msg'].toString(),
      );
    }
  }

  // change image status
  Future<void> callMultiImageStatusWB(
    BuildContext context,
    String multiImageId,
    String status,
  ) async {
    FocusScope.of(context).requestFocus(FocusNode());
    AlertsUtils.showLoaderUI(
      context: context,
      title: Localizer.get(AppText.pleaseWait.key),
    );

    final userData = await UserLocalStorage.getUserData();

    FocusScope.of(context).unfocus();
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadMultiImageStatus(
        action: ApiAction().CHANGE_MULTI_IMAGE_STATUS,
        userId: userData['userId'].toString(),
        multi_image_id: multiImageId,
        ImageType: status,
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog(response);
      // show toast
      CustomFlutterToastUtils.showToast(
        message: response['msg'].toString(),
        backgroundColor: AppColor().GREEN,
      );
      // call all images
      callMultiImageWB(false, context, pageNo: 1);
    } else {
      Navigator.pop(context);
      AlertsUtils().showExceptionPopup(
        context: context,
        message: response['msg'].toString(),
      );
    }
  }
}
