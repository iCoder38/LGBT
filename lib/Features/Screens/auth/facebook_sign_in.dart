// firebase_auth_service.dart
// Reusable Facebook Sign-in with Firebase for Flutter
//
// Make sure pubspec.yaml has:
//   firebase_core: ^2.x
//   firebase_auth: ^4.x
//   flutter_facebook_auth: ^6.x
//
// Setup steps (Android/iOS/Firebase/Facebook) are the same as before.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

/// Singleton service for Firebase authentication (Facebook)
class FirebaseAuthService {
  FirebaseAuthService._privateConstructor();
  static final FirebaseAuthService instance =
      FirebaseAuthService._privateConstructor();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign in with Facebook and Firebase
  /// Returns UserCredential on success.
  /// Throws exceptions on failure.
  Future<UserCredential> signInWithFacebook({
    List<String> permissions = const ['email', 'public_profile'],
  }) async {
    try {
      // Trigger the Facebook sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: permissions,
      );

      switch (loginResult.status) {
        case LoginStatus.success:
          final AccessToken accessToken = loginResult.accessToken!;
          // NOTE: use tokenString (not .token) with latest flutter_facebook_auth versions
          final String token = accessToken.tokenString;

          final OAuthCredential facebookAuthCredential =
              FacebookAuthProvider.credential(token);

          // Sign in to Firebase with the Facebook credential
          final UserCredential userCredential = await _auth
              .signInWithCredential(facebookAuthCredential);

          return userCredential;

        case LoginStatus.cancelled:
          throw FirebaseAuthException(
            code: 'ERROR_ABORTED_BY_USER',
            message: 'Sign in aborted by user',
          );

        case LoginStatus.failed:
          throw FirebaseAuthException(
            code: 'ERROR_FACEBOOK_LOGIN_FAILED',
            message: loginResult.message ?? 'Facebook login failed',
          );

        case LoginStatus.operationInProgress:
          throw FirebaseAuthException(
            code: 'ERROR_OPERATION_IN_PROGRESS',
            message: 'Facebook login already in progress',
          );
      }
    } on FirebaseAuthException catch (e) {
      // Common helpful handling: account exists with different credential
      if (e.code == 'account-exists-with-different-credential' ||
          e.code == 'account-exists-with-different-credential') {
        // The email is already used by another provider. We can help the caller by returning
        // the available sign-in methods for that email so the UI can ask the user to sign in
        // with the other provider and then link accounts.
        // The original Firebase exception doesn't always include the email; the caller may
        // need to inspect the exception or prompt the user.
        debugPrint('Account exists with different credential: ${e.message}');
      } else {
        debugPrint(
          'FirebaseAuthException during Facebook sign-in: ${e.code} ${e.message}',
        );
      }
      rethrow;
    } catch (e) {
      debugPrint('Exception during Facebook sign-in: $e');
      rethrow;
    }
    // unreachable, but Dart requires a return type
    throw Exception('Unknown Facebook login error');
  }

  /// If you hit an \"account-exists-with-different-credential\" error, use this helper
  /// to fetch the sign-in methods for the email so your UI can guide the user.
  Future<List<String>> fetchSignInMethodsForEmail(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods;
    } catch (e) {
      debugPrint('Error fetching sign-in methods for $email: $e');
      rethrow;
    }
  }

  /// Link current Firebase user with Facebook (if already signed-in with other provider)
  Future<UserCredential> linkFacebookToCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null)
      throw Exception('No signed-in Firebase user to link with Facebook');

    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status != LoginStatus.success) {
      throw Exception('Facebook login failed or cancelled');
    }

    final AccessToken accessToken = result.accessToken!;
    final fbCred = FacebookAuthProvider.credential(accessToken.tokenString);

    return await user.linkWithCredential(fbCred);
  }

  /// Sign out from Facebook and Firebase
  Future<void> signOut() async {
    try {
      await FacebookAuth.instance.logOut(); // best effort
    } catch (e) {
      debugPrint('Facebook logout error: $e');
    }
    await _auth.signOut();
  }

  /// Returns current Firebase user (nullable)
  User? get currentUser => _auth.currentUser;

  /// Auth state changes stream
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Utility: read facebook profile data after login (optional)
  Future<Map<String, dynamic>?> getFacebookUserData({
    String fields = 'name,email,picture',
  }) async {
    try {
      final userData = await FacebookAuth.instance.getUserData(fields: fields);
      return userData;
    } catch (e) {
      debugPrint('Failed to get Facebook user data: $e');
      return null;
    }
  }
}

/// A small reusable Facebook sign-in button widget that calls the service
class FacebookSignInButton extends StatefulWidget {
  final void Function(UserCredential credential)? onSuccess;
  final void Function(Object error)? onError;
  final String label;

  const FacebookSignInButton({
    Key? key,
    this.onSuccess,
    this.onError,
    this.label = 'Continue with Facebook',
  }) : super(key: key);

  @override
  State<FacebookSignInButton> createState() => _FacebookSignInButtonState();
}

class _FacebookSignInButtonState extends State<FacebookSignInButton> {
  bool _loading = false;

  Future<void> _handleSignIn() async {
    setState(() => _loading = true);
    try {
      final credential = await FirebaseAuthService.instance
          .signInWithFacebook();
      widget.onSuccess?.call(credential);
    } catch (e) {
      widget.onError?.call(e);
      final snack = SnackBar(
        content: Text('Sign in failed: ${_friendlyErrorMessage(e)}'),
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(snack);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyErrorMessage(Object e) {
    if (e is FirebaseAuthException) return e.message ?? e.code;
    return e.toString();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _loading ? null : _handleSignIn,
      icon: const Icon(Icons.facebook),
      label: _loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(widget.label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }
}

/// Example widget (use in your app to listen to auth changes)
class AuthListenerExample extends StatelessWidget {
  const AuthListenerExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuthService.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const CircularProgressIndicator();
        final user = snapshot.data;
        if (user == null) {
          return Center(
            child: FacebookSignInButton(
              onSuccess: (creds) {
                debugPrint('Signed in: ${creds.user?.uid}');
              },
              onError: (err) => debugPrint('Sign-in error: $err'),
            ),
          );
        }
        return Center(
          child: Text('Hello, ${user.displayName ?? user.email ?? 'User'}'),
        );
      },
    );
  }
}
