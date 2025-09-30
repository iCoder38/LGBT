import 'package:flutter/material.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

/// Reset Password Screen
/// - Screen name / Title: "Reset Password"
/// - Fields: OTP, Email (optional pre-filled), New Password, Confirm Password
/// - Simple validation, show/hide password, clear UI, reusable component ready to plug into your app.

class ResetPasswordScreen extends StatefulWidget {
  /// Optional pre-filled email passed from previous screen
  final String? prefilledEmail;

  const ResetPasswordScreen({Key? key, this.prefilledEmail}) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _otpController = TextEditingController();
  // final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledEmail != null) {
      // _emailController.text = widget.prefilledEmail!;
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    // _emailController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Example submission flow. Replace with your API call.
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isSubmitting = false);

    // Optionally pop or navigate to login
    // Navigator.of(context).pop();
    callResetPassword(context);
  }

  String? _validateOTP(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter the OTP';
    if (v.trim().length < 4) return 'OTP looks too short';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final email = v.trim();
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$");
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email';
    return null;
  }

  String? _validateNewPassword(String? v) {
    if (v == null || v.isEmpty) return 'Enter new password';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirmPassword(String? v) {
    if (v == null || v.isEmpty) return 'Confirm your password';
    if (v != _newPassController.text) return 'Passwords do not match';
    return null;
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscure,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '', // hide length counter if not needed
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: mq.width > 600 ? 520 : mq.width,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Enter the OTP sent to your email, then choose a new password.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // OTP
                  _buildTextField(
                    label: 'OTP',
                    hint: 'Enter code',
                    controller: _otpController,
                    validator: _validateOTP,
                    // keyboardType: TextInputType,
                    maxLength: 6,
                  ),
                  const SizedBox(height: 12),

                  // Email
                  // _buildTextField(
                  //   label: 'Email',
                  //   hint: 'you@example.com',
                  //   controller: _emailController,
                  //   validator: _validateEmail,
                  //   keyboardType: TextInputType.emailAddress,
                  // ),
                  // const SizedBox(height: 12),

                  // New Password
                  _buildTextField(
                    label: 'New Password',
                    hint: 'At least 6 characters',
                    controller: _newPassController,
                    validator: _validateNewPassword,
                    obscure: _obscureNew,
                    suffix: IconButton(
                      onPressed: () =>
                          setState(() => _obscureNew = !_obscureNew),
                      icon: Icon(
                        _obscureNew ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Confirm Password
                  _buildTextField(
                    label: 'Confirm Password',
                    hint: 'Re-type your new password',
                    controller: _confirmPassController,
                    validator: _validateConfirmPassword,
                    obscure: _obscureConfirm,
                    suffix: IconButton(
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      // Expanded(
                      //   child: OutlinedButton(
                      //     onPressed: () {
                      //       // TODO: wire this to resend OTP API
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //         const SnackBar(
                      //           content: Text('OTP resent (mock)'),
                      //         ),
                      //       );
                      //     },
                      //     child: const Padding(
                      //       padding: EdgeInsets.symmetric(vertical: 14.0),
                      //       child: Text('Resend OTP'),
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Reset Password'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // TextButton(
                  //   onPressed: () {
                  //     // go back to login
                  //     Navigator.of(context).maybePop();
                  //   },
                  //   child: const Text('Back to Sign in'),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> callResetPassword(context) async {
    // dismiss keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    AlertsUtils.showLoaderUI(
      context: context,
      title: Localizer.get(AppText.pleaseWait.key),
    );
    await Future.delayed(Duration(milliseconds: 400));
    Map<String, dynamic> response = await ApiService().postRequest(
      //ApiAction().SOCIAL_LOGIN,
      ApiPayloads.PayloadResetPassword(
        email: widget.prefilledEmail.toString(),
        otp: _otpController.text.toString(),
        newPassword: _newPassController.text.toString(),
      ),
    );
    GlobalUtils().customLog(response);
    if (response['status'].toString().toLowerCase() == "success") {
      GlobalUtils().customLog("✅ FORGOT PASSWORD success");
      GlobalUtils().customLog(response);
      // On success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset successful')),
      );
      Navigator.pop(context);
      Navigator.pop(context);
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
}
