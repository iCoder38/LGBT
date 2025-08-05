import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class ChangePasswordFormController {
  // Controllers
  final TextEditingController contOldPassword = TextEditingController();
  final TextEditingController contPassword = TextEditingController();
  final TextEditingController contConfirmPassword = TextEditingController();

  // validate old password
  String? validateOldPassword(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return "Confirm Password cannot be empty.";
    }

    return null;
  }

  // validate password
  String? validatePassword(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return "Password cannot be empty.";
    }
    if (value.length < 8) {
      return "Password must be at least 8 characters long.";
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
      return "Password must contain at least one letter.";
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return "Password must contain at least one number.";
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return "Password must contain at least one special character.";
    }

    return null;
  }

  // validate confirm password
  String? validateConfirmPassword(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return "Confirm Password cannot be empty.";
    }

    return null;
  }

  // Dispose method to clean up resources
  void dispose() {
    contPassword.dispose();
    contConfirmPassword.dispose();
  }
}
