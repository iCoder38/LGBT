import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lgbt_togo/Features/Screens/auth/facebook_sign_in.dart';
import 'package:lgbt_togo/Features/Screens/auth/google_sign_in.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextFieldsController _controller = TextFieldsController();

  /// FACEBOOK
  final FacebookAuthServiceFixed _fbService = FacebookAuthServiceFixed();
  bool _loading = false;
  String? _error;
  User? _user;
  String _status = '';

  bool isProfileComplete = false;

  var userData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Localizer.get(AppText.login.key),
        showBackButton: false,
      ),
      body: _UIKit(context),
    );
  }

  Widget _UIKit(BuildContext context) {
    return Stack(
      children: [
        // 🔳 Background image
        Positioned.fill(child: Image.asset(AppImage().BG_1, fit: BoxFit.cover)),

        Positioned.fill(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // 🖼️ Top Image
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Image.asset(
                              AppImage().LOGO_TRANSPARENT,
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const Spacer(),

                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                CustomTextField(
                                  keyboardType: TextInputType.emailAddress,
                                  hintText: Localizer.get(AppText.email.key),
                                  controller: _controller.contEmail,
                                  suffixIcon: Icons.email_outlined,
                                  validator: (value) =>
                                      _controller.validateEmail(value ?? ""),
                                ),
                                const SizedBox(height: 8),

                                CustomTextField(
                                  hintText: Localizer.get(AppText.password.key),
                                  controller: _controller.contPassword,
                                  obscureText: true,
                                  maxLines: 1,
                                  suffixIcon: Icons.lock_outline_sharp,
                                  validator: (value) =>
                                      _controller.validatePassword(value ?? ""),
                                ),
                                SizedBox(height: 8),
                                CustomButton(
                                  text: Localizer.get(AppText.signIn.key),
                                  color: AppColor().PRIMARY_COLOR,
                                  textColor: AppColor().kWhite,
                                  borderRadius: 30,
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      // dismiss keyboard
                                      FocusScope.of(
                                        context,
                                      ).requestFocus(FocusNode());
                                      AlertsUtils.showLoaderUI(
                                        context: context,
                                        title: Localizer.get(
                                          AppText.pleaseWait.key,
                                        ),
                                      );
                                      await Future.delayed(
                                        Duration(milliseconds: 400),
                                      );
                                      callLogin(context);
                                    }
                                  },
                                ),
                                SizedBox(height: 8),
                                // Facebook & Google
                                Row(
                                  children: [
                                    Expanded(
                                      child: SocialMediaButton(
                                        text: "Facebook",
                                        color: AppColor().FACEBOOK,
                                        textColor: AppColor().kWhite,
                                        icon: Icons.facebook,
                                        onPressed: () async {
                                          GlobalUtils().customLog(
                                            "Clicked: Facebook",
                                          );
                                          _handleLogin();
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: SocialMediaButton(
                                        text: "Google",
                                        color: AppColor().GOOGLE,
                                        textColor: AppColor().kBlack,
                                        icon: Icons.g_mobiledata,
                                        onPressed: () {
                                          onTapSignIn();
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                // Forgot Password
                                TextButton(
                                  onPressed: () {
                                    AlertsUtils().CustomInputSheet(
                                      context: context,
                                      title: Localizer.get(
                                        AppText.forgotPassword.key,
                                      ),
                                      buttonText: Localizer.get(
                                        AppText.submit.key,
                                      ),
                                      imageAsset: AppImage().LOGO_TRANSPARENT,
                                      onSubmit: (s) async {
                                        GlobalUtils().customLog(s);

                                        await Future.delayed(
                                          Duration(milliseconds: 600),
                                        ).then((v) {
                                          AlertsUtils.showLoaderUI(
                                            context: context,
                                            title: Localizer.get(
                                              AppText.pleaseWait.key,
                                            ),
                                          );
                                        });
                                        callForgotPasswordWB(
                                          context,
                                          s.toString(),
                                        );
                                      },
                                    );
                                  },
                                  child: customText(
                                    Localizer.get(AppText.forgotPassword.key),
                                    16,
                                    context,
                                    color: AppColor().YELLOW,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                // Sign Up
                                CustomMultiColoredText(
                                  fontFamily: 'm',
                                  text1: Localizer.get(
                                    AppText.dntHaveAnAccount.key,
                                  ),
                                  text2:
                                      " ${Localizer.get(AppText.signUp.key)}",
                                  color1: AppColor().GRAY,
                                  color2: const Color(0xFF00BCD4),
                                  fontWeight: FontWeight.w500,
                                  onTap2: () {
                                    NavigationUtils.pushTo(
                                      context,
                                      const RegistrationScreen(),
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // Future<void> _handleSignOut() async {
  //   setState(() {
  //     _loading = true;
  //     _error = null;
  //   });
  //   try {
  //     await _fbService.signOut();
  //     setState(() => _user = null);
  //   } catch (e) {
  //     setState(() => _error = e.toString());
  //   } finally {
  //     if (mounted) setState(() => _loading = false);
  //   }
  // }

  Future<void> _handleLogin() async {
    setState(() {
      _loading = true;
      _status = 'Starting login...';
    });

    final outcome = await _fbService.signInWithFacebook();

    setState(() {
      _loading = false;
      _status = outcome.toString();
    });

    if (outcome.success) {
      final user = outcome.userCredential?.user;
      debugPrint('✅ Logged in as: ${user?.displayName} (${user?.email})');
    } else {
      debugPrint('❌ Login failed: ${outcome.code} ${outcome.message}');
      if (outcome.code == 'ACCOUNT_EXISTS' &&
          outcome.pendingCredential != null) {
        // This means user already has an account with another provider.
        // You can now ask them to log in with that provider and then link:
        // await existingUser.linkWithCredential(outcome.pendingCredential!);
      }
    }
  }

  // Example usage in a button handler (async)
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

        /*GlobalUtils().customLog("Email: $email");
        GlobalUtils().customLog("Name: $name");
        GlobalUtils().customLog("Picture: $picture");
        GlobalUtils().customLog("SocialId: $socialId");
        GlobalUtils().customLog(FirebaseAuth.instance.currentUser!.displayName);*/
        // return;

        callSocialLogin(
          context,
          email.toString(),
          // FirebaseAuth.instance.currentUser!.displayName.toString(),
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

  /*
  
  */

  // ====================== API ================================================
  Future<void> callSocialLogin(
    context,
    String email,
    String fullName,
    String socialId,
    String socialType,
  ) async {
    // dismiss keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    AlertsUtils.showLoaderUI(
      context: context,
      title: Localizer.get(AppText.pleaseWait.key),
    );
    await Future.delayed(Duration(milliseconds: 400));
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

      // store locally
      await UserLocalStorage.saveUserData(response['data']);
      // now reg in firebase
      await _createSocialLoginDataInFirebase(email, fullName, socialType);
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

  _createSocialLoginDataInFirebase(
    String email,
    String name,
    String type,
  ) async {
    await UserService()
        .createUser(FirebaseAuth.instance.currentUser!.uid, {
          'email': email,
          'name': name,
          'uid': FirebaseAuth.instance.currentUser!.uid,
          'phone': "".trim(),
          'first_name': name,
          'sign_in_via': type,
          'createdAt': DateTime.now().toIso8601String(),
        })
        .then((v) {
          GlobalUtils().customLog("Update firebase setting.");
          _alsoUpdateSettingInFirebase();
        });
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
      // check is profile comeplete
      // isProfileComplete
      _checkIsProfileCompleteAfterSocialLogin();
    });
  }

  _checkIsProfileCompleteAfterSocialLogin() async {
    userData = await UserLocalStorage.getUserData();
    GlobalUtils().customLog(userData);
    if (userData["bio"].toString() == "" &&
        userData["thought_of_day"].toString() == "") {
      NavigationUtils.pushTo(context, const CompleteProfileScreen());
    } else {
      NavigationUtils.pushTo(context, const DashboardScreen());
    }
    return;
  }

  // ====================== LOGIN
  Future<void> callLogin(context) async {
    // dismiss keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadLogin(
        action: ApiAction().LOGIN,
        email: _controller.contEmail.text.toString(),
        password: _controller.contPassword.text.toString(),
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog("✅ SignIn success");
      GlobalUtils().customLog(response);

      // store locally
      await UserLocalStorage.saveUserData(response['data']);

      // with firebase also
      signedInViaFirebasE(
        context,
        _controller.contEmail.text.toString(),
        _controller.contPassword.text.toString(),
      );
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

  // ====================== FORGOT PASSWORD
  Future<void> callForgotPasswordWB(context, String email) async {
    // dismiss keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    Map<String, dynamic> response = await ApiService().postRequest(
      ApiPayloads.PayloadForgotPassword(
        action: ApiAction().FORGOT_PASSWORD,
        email: email,
      ),
    );

    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog("✅ Forgot password success");
      GlobalUtils().customLog(response);
      // dismiss alert
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['msg'].toString()),
          backgroundColor: AppColor().GREEN,
        ),
      );
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

  // login
  Future<String?> signedInViaFirebasE(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final auth = AuthService();
      await auth.signIn(email: email, password: password);
      GlobalUtils().customLog("✅ SignIn");

      await FirebaseFirestore.instance
          .collection('LGBT_TOGO_PLUS/ONLINE_STATUS/STATUS')
          .doc(FIREBASE_AUTH_UID())
          .set({
            'isOnline': true,
            'lastSeen': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      NavigationUtils.pushTo(context, DashboardScreen());
      return null; // Success
    } on FirebaseAuthException catch (e) {
      final errorMessage = e.message ?? 'Authentication failed.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));

      return errorMessage;
    } catch (e) {
      const fallbackMessage = 'An unknown error occurred.';
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(fallbackMessage)));

      return fallbackMessage;
    }
  }
}
