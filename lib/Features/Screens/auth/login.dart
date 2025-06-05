import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextFieldsController _controller = TextFieldsController();

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
                                  suffixIcon: Icons.lock_outline_sharp,
                                  validator: (value) =>
                                      _controller.validatePassword(value ?? ""),
                                ),

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

                                // Facebook & Google
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomButton(
                                        height: 50,
                                        text: Localizer.get(
                                          AppText.facebook.key,
                                        ),
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

                                // Forgot Password
                                TextButton(
                                  onPressed: () {
                                    NavigationUtils.pushTo(
                                      context,
                                      const RegistrationScreen(),
                                    );
                                  },
                                  child: customText(
                                    "Forgot Password",
                                    16,
                                    context,
                                    color: AppColor().YELLOW,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                // Sign Up
                                CustomMultiColoredText(
                                  fontFamily: 'm',
                                  text1: "Don't have an account? ",
                                  text2: "Sign Up",
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

  // ====================== API ================================================
  // ====================== REGISTRATION
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
