import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hexagon/hexagon.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lgbt_togo/Features/Screens/auth/facebook_sign_in.dart';
import 'package:lgbt_togo/Features/Screens/auth/google_sign_in.dart';
// import 'package:lgbt_togo/Features/Screens/web_in_app/web_in_app.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextFieldsController _controller = TextFieldsController();
  // auth
  final auth = AuthService();
  final userService = UserService();
  // check
  bool isChecked = false;

  // image
  final ImagePicker _picker = ImagePicker();
  File? selectedImageReg;

  // dio
  final Dio _dio = Dio();

  // password toggles
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Localizer.get(AppText.createAnAccount.key),
        showBackButton: true,
      ),
      body: _UIKitWithBG(context),
    );
  }

  Widget _UIKitWithBG(BuildContext context) {
    return Stack(
      children: [
        // 🔳 Background image
        Positioned.fill(child: Image.asset(AppImage().BG_1, fit: BoxFit.cover)),
        _UIKIT(context),
      ],
    );
  }

  Widget _UIKIT(BuildContext context) {
    Color getColor(Set<WidgetState> states) {
      const Set<WidgetState> interactiveStates = <WidgetState>{
        WidgetState.pressed,
        WidgetState.hovered,
        WidgetState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

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
                  SizedBox(height: 10),
                  // Image Section
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
                      width: 165, // make width = height for perfect circle
                      height: 165,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipOval(
                            child: selectedImageReg != null
                                ? Image.file(
                                    selectedImageReg!,
                                    fit: BoxFit.cover,
                                    width: 165,
                                    height: 165,
                                  )
                                : Image.asset(
                                    AppImage().LOGO,
                                    fit: BoxFit.cover,
                                    width: 165,
                                    height: 165,
                                  ),
                          ),
                          selectedImageReg != null
                              ? SizedBox()
                              : const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white70,
                                  size: 32,
                                ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // TextFields
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
                  const SizedBox(height: 8),

                  CustomTextField(
                    paddingLeft: 16,
                    paddingRight: 16,
                    hintText: Localizer.get(AppText.password.key),
                    controller: _controller.contPassword,
                    obscureText: _obscurePassword,
                    maxLines: 1,
                    // keep your validator
                    validator: (p0) => _controller.validatePassword(p0 ?? ""),
                    // tappable eye
                    suffix: IconButton(
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      splashRadius: 20,
                      tooltip: _obscurePassword
                          ? 'Show password'
                          : 'Hide password',
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  CustomTextField(
                    paddingLeft: 16,
                    paddingRight: 16,
                    hintText: Localizer.get(AppText.password.key),
                    controller: _controller.contConfirmPassword,
                    obscureText: _obscureConfirmPassword,
                    maxLines: 1,
                    // confirm password usually doesn't need validator here, you already check later
                    suffix: IconButton(
                      onPressed: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                      splashRadius: 20,
                      tooltip: _obscureConfirmPassword
                          ? 'Show password'
                          : 'Hide password',
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),

                  SizedBox(height: 6),
                  Row(
                    children: [
                      SizedBox(width: 16),
                      Checkbox(
                        checkColor: Colors.white,
                        fillColor: WidgetStateProperty.resolveWith(getColor),
                        value: isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            isChecked = value!;
                            GlobalUtils().customLog(isChecked);
                          });
                        },
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              customText(
                                Localizer.get(AppText.acceptOur.key),
                                14,
                                context,
                                color: AppColor().kWhite,
                              ),
                              SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  // GlobalUtils().customLog("Sign In tapped");
                                  NavigationUtils.pushTo(
                                    context,
                                    WebInAppScreen(
                                      URL: GlobalUtils().URL_TERMS,
                                    ),
                                  );
                                },
                                child: customText(
                                  Localizer.get(AppText.termsAnd.key),
                                  14,
                                  context,
                                  color: Color.fromARGB(255, 235, 224, 19),
                                ),
                              ),
                              SizedBox(width: 6),
                            ],
                          ),
                        ),
                      ),

                      // CustomMultiColoredText(
                      //   fontFamily: 'm',
                      //   text1: Localizer.get(AppText.acceptOur.key),
                      //   text2: " ${Localizer.get(AppText.termsAnd.key)}",
                      //   color1: AppColor().GRAY,
                      //   color2: const Color.fromARGB(255, 235, 224, 19),
                      //   fontWeight: FontWeight.w600,
                      //   fontSize: 14,
                      //   isScrollable: true,
                      //   onTap2: () {
                      //     GlobalUtils().customLog("Sign In tapped");
                      //     NavigationUtils.pushTo(
                      //       context,
                      //       WebInAppScreen(URL: GlobalUtils().URL_TERMS),
                      //     );
                      //   },
                      // ),
                    ],
                  ),
                  // SimpleCheckbox(),
                  Builder(
                    builder: (context) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: !isChecked
                          ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: CustomButton(
                                text: Localizer.get(AppText.signUp.key),
                                color: AppColor().GRAY,
                                textColor: AppColor().kWhite,
                                borderRadius: 30,
                                onPressed: () async {
                                  GlobalUtils().customLog(
                                    "Sign up gray clicked",
                                  );
                                },
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(16),
                              child: CustomButton(
                                text: Localizer.get(AppText.signUp.key),
                                color: AppColor().PRIMARY_COLOR,
                                textColor: AppColor().kWhite,
                                borderRadius: 30,
                                onPressed: () async {
                                  GlobalUtils().customLog("Sign up clicked");

                                  if (_formKey.currentState!.validate()) {
                                    if (_controller.contPassword.text
                                            .toString() !=
                                        _controller.contConfirmPassword.text
                                            .toString()) {
                                      AlertsUtils().showExceptionPopup(
                                        context: context,
                                        message: Localizer.get(
                                          AppText.passwordNotMatched.key,
                                        ),
                                      );
                                      return;
                                    }

                                    if (selectedImageReg == null) {
                                      CustomFlutterToastUtils.showToast(
                                        message:
                                            "Please upload profile picture",
                                        backgroundColor: AppColor().RED,
                                      );
                                      return;
                                    }
                                    AlertsUtils.showLoaderUI(
                                      context: context,
                                      title: Localizer.get(
                                        AppText.pleaseWait.key,
                                      ),
                                    );
                                    await Future.delayed(
                                      Duration(milliseconds: 400),
                                    );
                                    callRegistration(context);
                                  }
                                },
                              ),
                            ),
                    ),
                  ),

                  /*Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: SocialMediaButton(
                            text: "Facebook",
                            color: AppColor().FACEBOOK,
                            textColor: AppColor().kWhite,
                            icon: Icons.facebook,
                            onPressed: () async {
                              try {
                                final creds = await FirebaseAuthService.instance
                                    .signInWithFacebook();
                                debugPrint(
                                  "Signed in as: ${creds.user?.email}",
                                );
                              } catch (e) {
                                debugPrint("Error: $e");
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SocialMediaButton(
                            text: "Google",
                            color: AppColor().GOOGLE,
                            textColor: AppColor().kBlack,
                            icon: Icons
                                .g_mobiledata, // you can replace with official logo
                            onPressed: () {
                              onTapSignIn();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),*/
                  const SizedBox(height: 16),

                  CustomMultiColoredText(
                    fontFamily: 'm',
                    text1: Localizer.get(AppText.alreadyHaveAnAccount.key),
                    text2: Localizer.get(AppText.signIn.key),
                    color1: AppColor().GRAY,
                    color2: const Color(0xFF00BCD4),
                    fontWeight: FontWeight.w500,
                    onTap2: () {
                      GlobalUtils().customLog("Sign In tapped");
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onTapSignIn() async {
    final result = await GoogleAuthService.instance.signInWithGoogle();

    if (result.success) {
      final user = result.credential?.user;
      if (user != null) {
        final email = user.email; // user’s email
        final name = user.displayName; // user’s full name
        final picture = user.photoURL; // profile photo URL
        final socialId = user.providerData.isNotEmpty
            ? user.providerData.first.uid
            : user.uid; // fallback to Firebase uid

        GlobalUtils().customLog("Email: $email");
        GlobalUtils().customLog("Name: $name");
        GlobalUtils().customLog("Picture: $picture");
        GlobalUtils().customLog("SocialId: $socialId");

        callSocialLogin(
          context,
          email.toString(),
          name.toString(),
          socialId.toString(),
          "GOOGLE",
        );
      }
    } else if (result.cancelled) {
      GlobalUtils().customLog("User cancelled sign-in");
    } else {
      GlobalUtils().customLog(
        "Error: ${result.errorCode} - ${result.errorMessage}",
      );
    }
  }

  Future<void> callSocialLogin(
    context,
    String email,
    String fullName,
    String socialId,
    String socialType,
  ) async {
    // dismiss keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    Map<String, dynamic> response = await ApiService().postRequest(
      //ApiAction().SOCIAL_LOGIN,
      ApiPayloads.PayloadSocialLogin(
        action: ApiAction().SOCIAL_LOGIN,
        email: email,
        fullName: fullName,
        socialId: socialId,
        socialType: socialType,
      ),
    );
    GlobalUtils().customLog(response);
    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog("✅ SignIn success");
      GlobalUtils().customLog(response);

      return;

      // store locally
      // await UserLocalStorage.saveUserData(response['data']);

      // with firebase also
      // signedInViaFirebasE(
      //   context,
      //   _controller.contEmail.text.toString(),
      //   _controller.contPassword.text.toString(),
      // );
    } else {
      GlobalUtils().customLog("Failed to view stories: $response");
      Navigator.pop(context);
      // show error popup
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
        selectedImageReg = File(image.path);
        // loginUserimage = image.path;
      });
    }
  }

  // api
  // ====================== API ================================================
  // ====================== REGISTRATION
  Future<void> callRegistration(context) async {
    // dismiss keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadRegistration(
        action: ApiAction().REGISTRATION,
        email: _controller.contEmail.text.toString(),
        firstName: _controller.contFirstName.text.toString(),
        contactNumber: _controller.contPhoneNumber.text.toString(),
        password: _controller.contPassword.text.toString(),
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog("Signup success");
      // store locally
      await UserLocalStorage.saveUserData(response['data']);

      if (selectedImageReg != null) {
        _uploadImage(context);
      }
    } else {
      GlobalUtils().customLog("Failed to view stories: $response");
      Navigator.pop(context);
      // show error popup
      AlertsUtils().showExceptionPopup(
        context: context,
        message: response['msg'].toString(),
      );
    }
  }

  // upload image
  Future<void> _uploadImage(context) async {
    /*AlertsUtils.showLoaderUI(
      context: context,
      title: Localizer.get(AppText.pleaseWait.key),
    );*/

    String uploadUrl = BaseURL().baseUrl;

    try {
      final userData = await UserLocalStorage.getUserData();

      String fileName = selectedImageReg!.path.split('/').last;

      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          selectedImageReg!.path,
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
          //String message = data["msg"] ?? "Upload successful!";

          final data2 = response.data is String
              ? jsonDecode(response.data)
              : response.data;

          // save locally
          await UserLocalStorage.saveUserData(data2["data"]);

          //reg firebase
          // with firebase also
          registerUserInFirebase(
            _controller.contFirstName.text.toString(),
            _controller.contEmail.text.toString(),
            _controller.contPassword.text.toString(),
          );
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

  // store in firebase
  Future<String?> registerUserInFirebase(
    String name,
    String email,
    String password,
  ) async {
    final auth = AuthService();
    final (user, error) = await auth.signUp(email: email, password: password);

    if (error != null) {
      GlobalUtils().customLog('❌ Signup failed: $error');
      AlertsUtils().showExceptionPopup(context: context, message: error);
      return error;
    }

    if (user != null) {
      GlobalUtils().customLog('✅ Signup successful → UID: ${user.uid}');
      try {
        await userService.createUser(user.uid, {
          'email': email,
          'name': name,
          'uid': user.uid,
          'phone': _controller.contPhoneNumber.text.trim(),
          'first_name': _controller.contFirstName.text.trim(),
          'sign_in_via': 'email',
          'createdAt': DateTime.now().toIso8601String(),
          'levels': {
            "direct_message": 0,
            "friend_request": 0,
            "level": 1,
            "points": 0,
            'post': 0,
          },
        });
        GlobalUtils().customLog('✅ Data saved in Firestore in users data');

        await user.updateDisplayName(_controller.contFirstName.text.trim());
        _alsoUpdateSettingInFirebase();
        return null;
      } catch (e) {
        GlobalUtils().customLog('❌ Firestore write failed: $e');
        return 'Account created, but failed to save user data.';
      }
    }

    return 'Signup failed for unknown reason.';
  }

  void _alsoUpdateSettingInFirebase() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final payload = UserSettingsPayload.initialGrouped();

    await SettingsService().setSettings(uid, payload).then((_) {
      GlobalUtils().customLog('✅ Data saved in Firestore in settings also');
      GlobalUtils().customLog("All values saved");
      Navigator.pop(context);
      // push to complete profile screen
      NavigationUtils.pushTo(
        context,
        const CompleteProfileScreen(showBack: true),
      );
    });
  }
}

class SimpleCheckbox extends StatefulWidget {
  const SimpleCheckbox({super.key});

  @override
  State<SimpleCheckbox> createState() => _SimpleCheckboxState();
}

class _SimpleCheckboxState extends State<SimpleCheckbox> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isChecked = !isChecked;
        });
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isChecked ? Colors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey, width: 2),
        ),
        child: isChecked
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : null,
      ),
    );
  }
}
