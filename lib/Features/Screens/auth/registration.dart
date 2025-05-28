import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextFieldsController _controller = TextFieldsController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Localizer.get(AppText.createAnAccount.key),
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Spacer(),
            CustomTextField(
              paddingLeft: 16,
              paddingRight: 16,
              hintText: Localizer.get(AppText.firstName.key),
              controller: _controller.contEmail,
              suffixIcon: Icons.person_outline_sharp,
            ),
            SizedBox(height: 4),
            CustomTextField(
              paddingLeft: 16,
              paddingRight: 16,
              hintText: Localizer.get(AppText.email.key),
              controller: _controller.contEmail,
              suffixIcon: Icons.email_outlined,
            ),
            SizedBox(height: 4),
            CustomTextField(
              paddingLeft: 16,
              paddingRight: 16,
              hintText: Localizer.get(AppText.phone.key),
              controller: _controller.contPhoneNumber,
              suffixIcon: Icons.phone_outlined,
            ),
            SizedBox(height: 4),
            CustomTextField(
              paddingLeft: 16,
              paddingRight: 16,
              hintText: Localizer.get(AppText.password.key),
              controller: _controller.contPassword,
              suffixIcon: Icons.lock_outline_sharp,
            ),
            SizedBox(height: 4),
            CustomTextField(
              paddingLeft: 16,
              paddingRight: 16,
              hintText: Localizer.get(AppText.password.key),
              controller: _controller.contConfirmPassword,
              suffixIcon: Icons.lock_outline_sharp,
            ),
            CustomButton(
              text: Localizer.get(AppText.signUp.key),
              color: AppColor().PRIMARY_COLOR,
              textColor: AppColor().kWhite,
              borderRadius: 30,
            ),
            SizedBox(height: 4),

            SizedBox(height: 4),

            SizedBox(height: 4),
            CustomMultiColoredText(
              fontFamily: 'm',
              text1: "Already have an account? ",
              text2: "Sign In",
              color1: AppColor().GRAY,
              color2: Color(0xFF00BCD4),
              fontWeight: FontWeight.w500,
              onTap2: () {
                GlobalUtils().customLog("Sign Up tapped");
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // local widgets
}
