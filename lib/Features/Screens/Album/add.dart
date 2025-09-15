// import 'package:flutter/material.dart';
// import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
// import 'package:dio/dio.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class AddAlbumScreen extends StatefulWidget {
  const AddAlbumScreen({super.key});

  @override
  State<AddAlbumScreen> createState() => AddAlbumScreenState();
}

class AddAlbumScreenState extends State<AddAlbumScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<String> visibilityOptions = [
    'Public',
    Localizer.get(AppText.private.key),
  ];
  String selectedOption = 'Public';
  final ImagePicker _picker = ImagePicker();
  List<XFile> selectedImages = [];

  var userData;
  @override
  void initState() {
    super.initState();

    getLoginUserData();
  }

  getLoginUserData() async {
    userData = await UserLocalStorage.getUserData();
    // call
    // callMultiImageWB(context, pageNo: 1);
    setState(() {});
  }

  Future<void> pickImages() async {
    try {
      final List<XFile> picked = await _picker.pickMultiImage(imageQuality: 80);

      if (picked.isNotEmpty) {
        if (picked.length > 5) {
          AlertsUtils.showAlertToast(
            context: context,
            message: Localizer.get(AppText.uploadFiveImages.key),
          );
        }

        setState(() {
          selectedImages = picked.take(5).toList();
        });
      }
    } catch (e) {
      GlobalUtils().customLog("❌ Error picking images: $e");
    }
  }

  int getImageType() {
    switch (selectedOption) {
      case 'Public':
        return 3;
      case 'Private':
        return 2;
      default:
        return 1;
    }
  }

  Future<void> uploadImages() async {
    // GlobalUtils().customLog(getImageType().toString());
    // return;
    if (selectedImages.isEmpty) {
      AlertsUtils.showAlertToast(
        context: context,
        message: Localizer.get(AppText.selectAtLeastOneImage.key),
      );
      return;
    }

    try {
      FocusScope.of(context).requestFocus(FocusNode());
      AlertsUtils.showLoaderUI(
        context: context,
        title: Localizer.get(AppText.pleaseWait.key),
      );

      final uri = Uri.parse(BaseURL().baseUrl);
      final request = http.MultipartRequest('POST', uri);

      // 🧠 Add numbered image fields: multiImage[0], multiImage[1], ...
      for (int i = 0; i < selectedImages.length; i++) {
        final file = File(selectedImages[i].path);
        request.files.add(
          await http.MultipartFile.fromPath('multiImage[$i]', file.path),
        );
      }

      // 🔧 Add other form fields
      request.fields["action"] = "multiimageadd";
      request.fields["userId"] = userData['userId'].toString();
      request.fields["ImageType"] = getImageType().toString();

      final response = await request.send();
      Navigator.of(context, rootNavigator: true).pop(); // dismiss loader

      if (response.statusCode == 200) {
        AlertsUtils.showAlertToast(
          context: context,
          message: "Upload successful!",
        );
        setState(() => selectedImages.clear());
      } else {
        AlertsUtils.showAlertToast(
          context: context,
          message: "Upload failed: ${response.statusCode}",
        );
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop(); // dismiss loader
      GlobalUtils().customLog("❌ Upload error: $e");
      // showExceptionPopup(context: context, message: e.toString());
      GlobalUtils().customLog(e.toString());
    } finally {
      // customLog('✅ Upload completed');
      GlobalUtils().customLog("Upload complete");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: Localizer.get(AppText.addAlbum.key),
        backgroundColor: AppColor().kNavigationColor,
        backIcon: Icons.chevron_left,
        showBackButton: true,
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customText(
                Localizer.get(AppText.albumVisibility.key),
                14,
                context,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
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
                      GlobalUtils().customLog("User select: $selectedOption");
                      GlobalUtils().customLog(
                        "User select: ${getImageType().toString()}",
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: Localizer.get(AppText.uploadMultipleImages.key),
                color: AppColor().PRIMARY_COLOR,
                textColor: AppColor().kWhite,
                onPressed: pickImages,
              ),
              const SizedBox(height: 20),
              customText(
                Localizer.get(AppText.uploadFiveImages.key),
                12,
                context,
              ),
              const SizedBox(height: 16),
              if (selectedImages.isNotEmpty)
                Column(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: selectedImages.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(selectedImages[index].path),
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: Localizer.get(AppText.uploadImage.key),
                      color: AppColor().PRIMARY_COLOR,
                      textColor: AppColor().kWhite,
                      onPressed: uploadImages,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
