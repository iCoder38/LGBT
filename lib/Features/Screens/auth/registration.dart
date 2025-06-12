import 'package:lgbt_togo/Features/Screens/web_in_app/web_in_app.dart';
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
                  // Image Section
                  CustomContainer(
                    height: 180,
                    margin: const EdgeInsets.all(4),
                    color: AppColor().PRIMARY_COLOR,
                    shadow: false,
                    child: CustomContainer(
                      color: AppColor().TEAL,
                      shadow: false,
                      height: 120,
                      width: 120,
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: AppColor().kWhite,
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
                    suffixIcon: Icons.lock_outline_sharp,
                    validator: (p0) => _controller.validatePassword(p0 ?? ""),
                  ),
                  const SizedBox(height: 8),

                  CustomTextField(
                    paddingLeft: 16,
                    paddingRight: 16,
                    hintText: Localizer.get(AppText.password.key),
                    controller: _controller.contConfirmPassword,
                    suffixIcon: Icons.lock_outline_sharp,
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
                      CustomMultiColoredText(
                        fontFamily: 'm',
                        text1: Localizer.get(AppText.acceptOur.key),

                        text2: " ${Localizer.get(AppText.termsAnd.key)}",
                        color1: AppColor().GRAY,
                        color2: const Color.fromARGB(255, 235, 224, 19),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        onTap2: () {
                          GlobalUtils().customLog("Sign In tapped");
                          NavigationUtils.pushTo(
                            context,
                            WebInAppScreen(URL: GlobalUtils().URL_TERMS),
                          );
                        },
                      ),
                    ],
                  ),
                  // SimpleCheckbox(),
                  Builder(
                    builder: (context) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: !isChecked
                          ? CustomButton(
                              text: Localizer.get(AppText.signUp.key),
                              color: AppColor().GRAY,
                              textColor: AppColor().kWhite,
                              borderRadius: 30,
                              onPressed: () async {
                                GlobalUtils().customLog("Sign up gray clicked");
                              },
                            )
                          : CustomButton(
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

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            height: 50,
                            text: Localizer.get(AppText.facebook.key),
                            color: AppColor().FACEBOOK,
                            textColor: AppColor().kWhite,
                            borderRadius: 30,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomButton(
                            height: 50,
                            text: Localizer.get(AppText.google.key),
                            color: AppColor().GOOGLE,
                            textColor: AppColor().kBlack,
                            borderRadius: 30,
                          ),
                        ),
                      ],
                    ),
                  ),

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

      // with firebase also
      registerUserInFirebase(
        _controller.contFirstName.text.toString(),
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
      NavigationUtils.pushTo(context, const CompleteProfileScreen());
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
