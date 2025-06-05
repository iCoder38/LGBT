import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class AuthHelper {
  static Future<bool> isUserLoggedIn() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      return user != null;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking auth state: $e');
      }
      return false;
    }
  }

  static Stream<bool> userAuthStateChanges() {
    return FirebaseAuth.instance.authStateChanges().map((User? user) {
      return user != null;
    });
  }
}
