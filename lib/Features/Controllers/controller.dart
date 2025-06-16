import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class TextFieldsController {
  final TextEditingController contEmail = TextEditingController();
  final TextEditingController contPassword = TextEditingController();
  final TextEditingController contConfirmPassword = TextEditingController();
  final TextEditingController contFirstName = TextEditingController();
  final TextEditingController contPhoneNumber = TextEditingController();

  final TextEditingController contWhatsYourStory = TextEditingController();
  final TextEditingController contWhyAreYouHere = TextEditingController();
  final TextEditingController contWhatDoYouLike = TextEditingController();
  final TextEditingController contYourBiography = TextEditingController();
  final TextEditingController contThoughtOfTheDay = TextEditingController();
  final TextEditingController contCurrentCity = TextEditingController();
  final TextEditingController contIAM = TextEditingController();
  final TextEditingController yourBelief = TextEditingController();
  final TextEditingController contDOB = TextEditingController();
  final TextEditingController contGender = TextEditingController();
  final TextEditingController contSexOrientation = TextEditingController();
  final TextEditingController contLocation = TextEditingController();
  final TextEditingController contInterestIn = TextEditingController();
  final TextEditingController contAboutYourself = TextEditingController();

  // ====================== YOUR BELIEF =======================================
  // ===========================================================================

  String? validateYourBelief(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return "Your belief cannot be empty.";
    }
    return null;
  }

  // ====================== I AM =======================================
  // ===========================================================================

  String? validateIAM(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return "I AM cannot be empty.";
    }
    return null;
  }

  // ====================== THOUGHT =======================================
  // ===========================================================================

  String? validateCurrentCity(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return "Current city cannot be empty.";
    }
    return null;
  }

  // ====================== THOUGHT =======================================
  // ===========================================================================

  String? validateThoughtOfTheDay(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return "Thought of the day cannot be empty.";
    }
    return null;
  }

  // ====================== BIOGRAPHY =======================================
  // ===========================================================================

  String? validateBiography(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return "Biography cannot be empty.";
    }
    return null;
  }

  // ====================== Whats your story =======================================
  // ===========================================================================

  String? validateWhatsYourStory(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return "Whats your story cannot be empty.";
    }
    return null;
  }
  // ====================== Whats your story =======================================
  // ===========================================================================

  String? validateWhyAreYourHere(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return "Why are you here cannot be empty.";
    }
    return null;
  }
  // ====================== Whats your story =======================================
  // ===========================================================================

  String? validateWhatYouLike(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return "What you like cannot be empty.";
    }
    return null;
  }
  // ====================== DOB =======================================
  // ===========================================================================

  String? validatedob(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return "DOB cannot be empty.";
    }
    return null;
  }

  // ====================== GENDER =======================================
  // ===========================================================================

  String? validateGender(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return "Gender cannot be empty.";
    }
    return null;
  }

  // ====================== SEX =======================================
  // ===========================================================================

  String? validateSexOrientation(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return "Sex orientation cannot be empty.";
    }
    return null;
  }
  // ====================== LOCATION =======================================
  // ===========================================================================

  String? validateLocation(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return "Location cannot be empty.";
    }
    return null;
  }

  // ====================== INTEREST IN =======================================
  // ===========================================================================

  String? validateInterestIn(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return "Interest in cannot be empty.";
    }
    return null;
  }

  // ====================== ABOUT YOURSELF =======================================
  // ===========================================================================

  String? validateAboutYourself(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return "About yourself cannot be empty.";
    }
    return null;
  }
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
    contWhatsYourStory.dispose();
    contWhyAreYouHere.dispose();
    contWhatDoYouLike.dispose();
    contWhatDoYouLike.dispose();
    contThoughtOfTheDay.dispose();
    contCurrentCity.dispose();
    yourBelief.dispose();
    contIAM.dispose();
    contEmail.dispose();
    contPassword.dispose();
    contPhoneNumber.dispose();
    contFirstName.dispose();
    contConfirmPassword.dispose();
  }
}
