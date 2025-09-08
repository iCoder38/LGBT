// lib/services/google_auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

/// Result wrapper for Google sign-in attempts.
class SignInResult {
  final bool success;
  final bool cancelled;
  final UserCredential? credential;
  final String? errorCode;
  final String? errorMessage;

  const SignInResult._({
    required this.success,
    required this.cancelled,
    this.credential,
    this.errorCode,
    this.errorMessage,
  });

  factory SignInResult.success(UserCredential cred) =>
      SignInResult._(success: true, cancelled: false, credential: cred);

  factory SignInResult.cancelled() => const SignInResult._(
    success: false,
    cancelled: true,
    credential: null,
    errorCode: null,
    errorMessage: 'Sign-in cancelled by user.',
  );

  factory SignInResult.error({String? code, String? message}) => SignInResult._(
    success: false,
    cancelled: false,
    credential: null,
    errorCode: code,
    errorMessage: message,
  );
}

/// Google sign-in service (google_sign_in v7+ compatible).
class GoogleAuthService {
  GoogleAuthService._();

  static final GoogleAuthService instance = GoogleAuthService._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool _initialized = false;
  final List<String> _scopes = <String>['email', 'profile', 'openid'];

  /// Initialize google_sign_in (call once, e.g. in main).
  Future<void> initialize({String? clientId, String? serverClientId}) async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(
      clientId: clientId,
      serverClientId: serverClientId,
    );
    _initialized = true;
  }

  /// Interactive sign-in then Firebase authentication.
  Future<SignInResult> signInWithGoogle() async {
    try {
      if (!_initialized) await initialize();

      // interactive authenticate (v7+)
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate(scopeHint: _scopes);

      final GoogleSignInAuthentication auth = await googleUser.authentication;
      final idToken = auth.idToken;

      if (idToken == null || idToken.isEmpty) {
        return SignInResult.error(
          code: 'NO_ID_TOKEN',
          message: 'No ID token returned by Google sign-in.',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCred = await _firebaseAuth.signInWithCredential(credential);
      return SignInResult.success(userCred);
    } on GoogleSignInException catch (gse) {
      // Log everything to console for debugging
      final String code = gse.code.name;
      final String? details = gse.details?.toString();
      // print debug info (or use your logger)
      GlobalUtils().customLog(
        'GoogleSignInException -> code: $code, details: $details',
      );

      if (gse.code == GoogleSignInExceptionCode.canceled) {
        return SignInResult.cancelled();
      }

      return SignInResult.error(
        code: code,
        message: details ?? 'GoogleSignInException',
      );
    } on FirebaseAuthException catch (fae) {
      print(
        'FirebaseAuthException -> code: ${fae.code}, message: ${fae.message}',
      );
      return SignInResult.error(code: fae.code, message: fae.message);
    } catch (e, st) {
      print('Unknown sign-in error: $e\n$st');
      return SignInResult.error(code: 'UNKNOWN', message: e.toString());
    }
  }

  /// Throws on failure — alternative API.
  Future<UserCredential> signInWithGoogleOrThrow() async {
    final result = await signInWithGoogle();
    if (result.success && result.credential != null) {
      return result.credential!;
    }
    if (result.cancelled) throw Exception('Sign-in cancelled by user.');
    throw Exception(
      'Sign-in failed: ${result.errorCode} - ${result.errorMessage}',
    );
  }

  /// Sign out from Google and Firebase.
  Future<bool> signOut() async {
    try {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
      await _firebaseAuth.signOut();
      return true;
    } catch (_) {
      return false;
    }
  }

  User? get currentUser => _firebaseAuth.currentUser;
  bool get isSignedIn => currentUser != null;
}
