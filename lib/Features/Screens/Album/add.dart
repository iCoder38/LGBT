// import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class AddAlbumScreen extends StatefulWidget {
  const AddAlbumScreen({super.key});

  @override
  State<AddAlbumScreen> createState() => AddAlbumScreenState();
}

class AddAlbumScreenState extends State<AddAlbumScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<String> visibilityOptions = ['Public', 'Friends', 'Private'];
  String selectedOption = 'Public';
  final ImagePicker _picker = ImagePicker();
  List<XFile> selectedImages = [];

  var userData;
  @override
  void initState() {
    super.initState();

    userData = UserLocalStorage.getUserData();
  }

  Future<void> pickImages() async {
    try {
      final List<XFile> picked = await _picker.pickMultiImage(imageQuality: 80);

      if (picked.isNotEmpty) {
        if (picked.length > 5) {
          AlertsUtils.showAlertToast(
            context: context,
            message: "You can select up to 5 images at a time.",
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
        return 1;
      case 'Friends':
        return 2;
      case 'Private':
        return 3;
      default:
        return 1;
    }
  }

  Future<void> uploadImages() async {
    if (selectedImages.isEmpty) {
      AlertsUtils.showAlertToast(
        context: context,
        message: "Please select at least one image.",
      );
      return;
    }

    try {
      AlertsUtils.showAlertToast(
        context: context,
        message: "Uploading ${selectedImages.length} image(s)...",
      );

      var dio = Dio();

      // Build FormData
      var formData = FormData();

      formData.fields
        ..add(MapEntry('action', 'multiimageadd'))
        ..add(MapEntry('userId', userData["userId"].toString()))
        ..add(MapEntry('ImageType', getImageType().toString()));

      for (XFile image in selectedImages) {
        formData.files.add(
          MapEntry(
            'multiImage',
            await MultipartFile.fromFile(image.path, filename: image.name),
          ),
        );
      }

      GlobalUtils().customLog("📤 Uploading FormData: ${formData.fields}");
      GlobalUtils().customLog("📸 Uploading Files: ${formData.files.length}");

      var response = await dio.post(
        BaseURL().baseUrl, // 🔁 Replace with your API URL
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      // ✅ Decode if it's a string (common for some PHP responses)
      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      if (response.statusCode == 200 && data['status'] == 'success') {
        AlertsUtils.showAlertToast(
          context: context,
          message: "Upload successful!",
        );
        setState(() => selectedImages.clear());
      } else {
        final serverMessage = data is Map && data.containsKey('message')
            ? data['message'].toString()
            : jsonEncode(data); // fallback to full response

        AlertsUtils.showAlertToast(
          context: context,
          message: "Upload failed: $serverMessage",
        );

        GlobalUtils().customLog("❌ Server responded with: $serverMessage");
      }
    } catch (e) {
      GlobalUtils().customLog("❌ Upload error: $e");
      AlertsUtils.showAlertToast(
        context: context,
        message: "Upload failed. Please try again.",
      );
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
                "Album Visibility",
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
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: "Upload multiple images",
                color: AppColor().PRIMARY_COLOR,
                textColor: AppColor().kWhite,
                onPressed: pickImages,
              ),
              const SizedBox(height: 20),
              customText("Upload 5 multiple images at a time", 12, context),
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
                      text: "Upload",
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
