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
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Spacer(),
            CustomTextField(
              hintText: Localizer.get(AppText.email.key),
              controller: _controller.contEmail,
            ),
            CustomTextField(
              hintText: Localizer.get(AppText.password.key),
              controller: _controller.contPassword,
            ),
            SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
