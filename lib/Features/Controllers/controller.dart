import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class TextFieldsController {
  final TextEditingController contEmail = TextEditingController();
  final TextEditingController contPassword = TextEditingController();
  final TextEditingController contConfirmPassword = TextEditingController();
  final TextEditingController contFirstName = TextEditingController();
  final TextEditingController contPhoneNumber = TextEditingController();

  // ====================== FIRST NAME =========================================
  // ===========================================================================

  String? validateFirstName(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return "First name cannot be empty.";
    }
    if (value.length < 3) {
      return "First name must be at least 3 characters.";
    }
    if (!RegExp(r"^[a-zA-Z]+$").hasMatch(value)) {
      return "First name can only contain alphabets.";
    }
    return null;
  }

  // ====================== PHONE NUMBER =======================================
  // ===========================================================================

  String? validatePhoneNumber(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return "Phone number cannot be empty.";
    }
    return null;
  }

  // ====================== EMAIL ==============================================
  // ===========================================================================
  String? validateEmail(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return "Email cannot be empty.";
    }

    String emailPattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";

    if (!RegExp(emailPattern).hasMatch(value)) {
      return "Enter a valid email address.";
    }

    return null;
  }

  // ====================== PASSWORD ===========================================
  // ===========================================================================

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
  // ====================== CONFIRM PASSWORD ===================================
  // ===========================================================================

  String? validateConfirmPassword(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return "Confirm password cannot be empty.";
    }
    return null;
  }

  // Dispose method to clean up resources
  void dispose() {
    contEmail.dispose();
    contPassword.dispose();
    contPhoneNumber.dispose();
    contFirstName.dispose();
    contConfirmPassword.dispose();
  }
}
