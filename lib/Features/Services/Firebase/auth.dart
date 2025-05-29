import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔐 Sign in with email and password
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw e; // You can map error codes here if needed
    } catch (e) {
      rethrow;
    }
  }

  // 🆕 Sign up
  Future<(User?, String?)> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return (result.user, null);
    } on FirebaseAuthException catch (e) {
      return (null, _mapErrorCode(e.code));
    } catch (e) {
      return (null, "Unexpected error occurred");
    }
  }

  // 🚪 Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 👤 Current user getter
  User? get currentUser => _auth.currentUser;

  // 🔁 Stream of auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  String _mapErrorCode(String code) {
    switch (code) {
      case 'email-already-in-use':
        return "This email is already in use.";
      case 'invalid-email':
        return "The email address is not valid.";
      case 'user-not-found':
        return "No user found for this email.";
      case 'wrong-password':
        return "Incorrect password.";
      case 'weak-password':
        return "The password is too weak.";
      default:
        return "Authentication failed: $code";
    }
  }
}

// You can add a helper method here later like:
// Future<String?> signInAndReturnMessage(...) => for unified error handling
