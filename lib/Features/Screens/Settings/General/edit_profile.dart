// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hexagon/hexagon.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lgbt_togo/Features/Screens/Block/blocked.dart';
import 'package:lgbt_togo/Features/Screens/Settings/General/edit_complete_profile.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';
import 'package:path/path.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.isEdit});

  final bool isEdit;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextFieldsController _controller = TextFieldsController();

  final auth = AuthService();
  final userService = UserService();

  var userData;
  String loginUserimage = '';

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    callInitAPI();
  }

  void callInitAPI() async {
    userData = await UserLocalStorage.getUserData();
    _controller.contFirstName.text = FIREBASE_AUTH_NAME();
    _controller.contEmail.text = FIREBASE_AUTH_EMAIL();
    _controller.contPhoneNumber.text = userData["contactNumber"].toString();
    loginUserimage = userData["image"] ?? "";
    GlobalUtils().customLog(loginUserimage);
    setState(() {});
  }

  Future<void> pickImage(BuildContext context) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
        loginUserimage = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Localizer.get(AppText.editProfile.key),

        showBackButton: true,
      ),
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

  Widget _UIKIT(BuildContext context) {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hexagonal Profile Image
                  GestureDetector(
                    onTap: () {
                      AlertsUtils().showBottomSheetWithTwoBottom(
                        context: context,
                        message: "Upload image",
                        yesTitle: "Camera",
                        yesButtonColor: AppColor().PRIMARY_COLOR,
                        dismissTitle: "Gallery",
                        dismissButtonColor: AppColor().PRIMARY_COLOR,
                        onYesTap: () {
                          pickImageFromSource(ImageSource.camera);
                        }, //camera
                        onDismissTap: () {
                          pickImageFromSource(ImageSource.gallery);
                        }, //gallery
                      );
                    },
                    child: SizedBox(
                      width: 160,
                      height: 160,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipOval(
                            child: selectedImage != null
                                ? Image.file(selectedImage!, fit: BoxFit.cover)
                                : CustomCacheImageForUserProfile(
                                    imageURL: loginUserimage,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  CustomTextField(
                    paddingLeft: 16,
                    paddingRight: 16,
                    hintText: Localizer.get(AppText.firstName.key),
                    controller: _controller.contFirstName,
                    suffixIcon: Icons.person_outline_sharp,
                    validator: (p0) => _controller.validateFirstName(p0 ?? ""),
                  ),
                  const SizedBox(height: 8),

                  CustomTextField(
                    readOnly: true,
                    paddingLeft: 16,
                    paddingRight: 16,
                    keyboardType: TextInputType.emailAddress,
                    hintText: Localizer.get(AppText.email.key),
                    controller: _controller.contEmail,
                    suffixIcon: Icons.email_outlined,
                    validator: (p0) => _controller.validateEmail(p0 ?? ""),
                  ),
                  const SizedBox(height: 8),

                  CustomTextField(
                    paddingLeft: 16,
                    paddingRight: 16,
                    keyboardType: TextInputType.number,
                    hintText: Localizer.get(AppText.phone.key),
                    controller: _controller.contPhoneNumber,
                    suffixIcon: Icons.phone_outlined,
                    validator: (p0) =>
                        _controller.validatePhoneNumber(p0 ?? ""),
                  ),

                  Builder(
                    builder: (context) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: CustomButton(
                          text: Localizer.get(AppText.updated.key),
                          color: AppColor().PRIMARY_COLOR,
                          textColor: AppColor().kWhite,
                          borderRadius: 30,
                          onPressed: () async {
                            GlobalUtils().customLog("Sign up clicked");

                            if (_formKey.currentState!.validate()) {
                              AlertsUtils.showLoaderUI(
                                context: context,
                                title: Localizer.get(AppText.pleaseWait.key),
                              );
                              await Future.delayed(
                                const Duration(milliseconds: 400),
                              );
                              await callEditProfile(context);
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                  Builder(
                    builder: (context) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: CustomButton(
                          text: Localizer.get(AppText.editProfile.key),
                          color: AppColor().PRIMARY_COLOR,
                          textColor: AppColor().kWhite,
                          borderRadius: 30,
                          onPressed: () async {
                            GlobalUtils().customLog("Sign up clicked");

                            NavigationUtils.pushTo(
                              context,
                              EditCompleteProfileScreen(),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  Builder(
                    builder: (context) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: CustomButton(
                          text: Localizer.get(AppText.blocked.key),
                          color: AppColor().YELLOW,
                          textColor: AppColor().kBlack,
                          borderRadius: 30,
                          onPressed: () async {
                            GlobalUtils().customLog("Sign up clicked");
                            NavigationUtils.pushTo(context, BlockedScreen());
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> callEditProfile(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());

    await FirebaseAuth.instance.currentUser!.updateDisplayName(
      _controller.contFirstName.text.trim(),
    );

    await userService.updateUser(FIREBASE_AUTH_UID(), {
      'email': _controller.contEmail.text,
      'name': _controller.contFirstName.text,
      'uid': FIREBASE_AUTH_UID(),
      'phone': _controller.contPhoneNumber.text.trim(),
      'sign_in_via': 'email',
      'updatedAt': DateTime.now().toIso8601String(),
    });

    // 🔹 Call main profile update API
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadEditProfile(
        action: ApiAction().EDIT_PROFILE,
        userId: userData["userId"].toString(),
        firstName: _controller.contFirstName.text,
        contactNumber: _controller.contPhoneNumber.text,
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      await UserLocalStorage.saveUserData(response['data']);

      // ✅ If image was selected → upload it
      if (selectedImage != null) {
        _uploadImage(context);
      } else {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['msg'].toString()),
          backgroundColor: AppColor().GREEN,
        ),
      );
      // if image not selected
      // Navigator.pop(context, 'reload');
    } else {
      Navigator.pop(context);
      AlertsUtils().showExceptionPopup(
        context: context,
        message: response['msg'].toString(),
      );
    }
  }

  Future<void> pickImageFromSource(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
        // loginUserimage = image.path;
      });
    }
  }

  Future<void> _uploadImage(context) async {
    /*AlertsUtils.showLoaderUI(
      context: context,
      title: Localizer.get(AppText.pleaseWait.key),
    );*/

    String uploadUrl = BaseURL().baseUrl;

    try {
      final userData = await UserLocalStorage.getUserData();

      String fileName = selectedImage!.path.split('/').last;

      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          selectedImage!.path,
          filename: fileName,
        ),
        'action': ApiAction().EDIT_PROFILE,
        'userId': userData['userId'].toString(),
      });

      Response response = await _dio.post(uploadUrl, data: formData);

      GlobalUtils().customLog(response);

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      if (response.statusCode == 200) {
        GlobalUtils().customLog(response);
        // return;
        if (data["status"] == "success") {
          String message = data["msg"] ?? "Upload successful!";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: AppColor().GREEN),
          );

          final data2 = response.data is String
              ? jsonDecode(response.data)
              : response.data;

          GlobalUtils().customLog(data2);
          // return;

          // save locally
          await UserLocalStorage.saveUserData(data2["data"]);
          Navigator.pop(context);
          // CustomFlutterToastUtils.showToast(
          //   message: response['status'],
          //   backgroundColor: AppColor().GREEN,
          // );
        } else {
          Navigator.pop(context);
          String error = data["msg"] ?? "Upload failed.";
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
        }
      } else {
        GlobalUtils().customLog(response);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${response.statusMessage}')),
        );
      }
    } catch (e) {
      GlobalUtils().customLog(e);
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // void _alsoUpdateSettingInFirebase() async {
  //   final uid = FirebaseAuth.instance.currentUser?.uid;
  //   if (uid == null) return;

  //   final payload = UserSettingsPayload.initialGrouped();

  //   await SettingsService().setSettings(uid, payload);
  //   NavigationUtils.pushTo(context, const CompleteProfileScreen());
  // }
}

/*Future<void> uploadImageWithDio({
  required File imageFile,
  required String uploadUrl,
  required String action,
  required String userId,
}) async {
  try {
    String fileName = basename(imageFile.path);

    GlobalUtils().customLog("action$action,userId:$userId");
    // return;
    FormData formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      "action": action,
      "userId": userId,
    });

    Dio dio = Dio();

    Response response = await dio.post(
      uploadUrl,
      data: formData,
      options: Options(
        headers: {
          "Content-Type": "multipart/form-data",
          // "Authorization": "Bearer your-token", // if needed
        },
      ),
    );

    if (response.statusCode == 200) {
      GlobalUtils().customLog("✅ Upload success: ${response.data}");
      // await UserLocalStorage.saveUserData(response['data']);
    } else {
      GlobalUtils().customLog("❌ Upload failed: ${response.statusCode}");
    }
  } catch (e) {
    GlobalUtils().customLog("🚫 Upload error: $e");
  }
}*/
