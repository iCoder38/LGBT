import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';
import 'package:lgbt_togo/Features/Utils/custom/alerts.dart';

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
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            const Spacer(),

            // Email Field
            CustomTextField(
              paddingLeft: 16,
              paddingRight: 16,
              hintText: Localizer.get(AppText.email.key),
              controller: _controller.contEmail,
              suffixIcon: Icons.email_outlined,
            ),

            const SizedBox(height: 8),

            // Password Field
            CustomTextField(
              paddingLeft: 16,
              paddingRight: 16,
              hintText: Localizer.get(AppText.password.key),
              controller: _controller.contPassword,
              suffixIcon: Icons.lock_outline_sharp,
            ),

            // Sign In Button
            CustomButton(
              text: Localizer.get(AppText.signIn.key),
              color: AppColor().PRIMARY_COLOR,
              textColor: AppColor().kWhite,
              borderRadius: 30,
              onPressed: () {
                AlertsUtils().showExceptionPopup(
                  context: context,
                  message:
                      "message message message message message message message message message message message message message message message message message message message message message message message message message ",
                );
              },
            ),

            // Facebook & Google Buttons
            Row(
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

            // Forgot Password
            Builder(
              builder: (ctx) => TextButton(
                onPressed: () {
                  GlobalUtils().customLog("Forgot Password tapped");
                  NavigationUtils.pushTo(ctx, const RegistrationScreen());
                },
                child: customText(
                  "Forgot Password",
                  16,
                  context,
                  color: AppColor().YELLOW,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Bottom Sign Up Text
            Builder(
              builder: (context) => CustomMultiColoredText(
                fontFamily: 'm',
                text1: "Don't have an account? ",
                text2: "Sign Up",
                color1: AppColor().GRAY,
                color2: const Color(0xFF00BCD4),
                fontWeight: FontWeight.w500,
                onTap2: () {
                  GlobalUtils().customLog("Sign Up tapped");
                  NavigationUtils.pushTo(context, const RegistrationScreen());
                },
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
