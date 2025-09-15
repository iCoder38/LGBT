// facebook_auth_service_fixed.dart
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FacebookAuthOutcome {
  final bool success;
  final String code;
  final String? message;
  final UserCredential? userCredential;
  final AuthCredential? pendingCredential;
  FacebookAuthOutcome({
    required this.success,
    required this.code,
    this.message,
    this.userCredential,
    this.pendingCredential,
  });

  @override
  String toString() =>
      'FacebookAuthOutcome(success:$success, code:$code, message:$message, user:${userCredential?.user?.uid}, pending:${pendingCredential != null})';
}

class FacebookAuthServiceFixed {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Signs in with Facebook (web + mobile). Returns a verbose outcome.
  Future<FacebookAuthOutcome> signInWithFacebook() async {
    developer.log(
      'fb_fixed: signInWithFacebook() called',
      name: 'facebook_auth_fixed',
    );

    try {
      if (kIsWeb) {
        developer.log(
          'fb_fixed: using web popup flow',
          name: 'facebook_auth_fixed',
        );
        final provider = FacebookAuthProvider();
        provider.addScope('email');

        try {
          final uc = await _auth.signInWithPopup(provider);
          developer.log(
            'fb_fixed: web signInWithPopup success uid=${uc.user?.uid}',
            name: 'facebook_auth_fixed',
          );
          return FacebookAuthOutcome(
            success: true,
            code: 'SUCCESS',
            userCredential: uc,
          );
        } catch (e, st) {
          developer.log(
            'fb_fixed: web popup error: $e\n$st',
            name: 'facebook_auth_fixed',
            level: 1000,
          );
          return FacebookAuthOutcome(
            success: false,
            code: 'ERROR',
            message: e.toString(),
          );
        }
      }

      // Mobile flow
      developer.log(
        'fb_fixed: mobile flow - calling FacebookAuth.instance.login()',
        name: 'facebook_auth_fixed',
      );
      final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      developer.log(
        'fb_fixed: LoginResult.status=${loginResult.status} message=${loginResult.message}',
        name: 'facebook_auth_fixed',
      );

      if (loginResult.status == LoginStatus.cancelled) {
        return FacebookAuthOutcome(
          success: false,
          code: 'CANCELLED',
          message: loginResult.message,
        );
      }
      if (loginResult.status != LoginStatus.success) {
        return FacebookAuthOutcome(
          success: false,
          code: 'LOGIN_FAILED',
          message: loginResult.message,
        );
      }

      final AccessToken accessToken = loginResult.accessToken!;
      // NOTE: AccessToken is abstract (has tokenString & type). Concrete subtypes
      // (ClassicToken, LimitedToken) expose additional fields like `expires`.
      // Always use tokenString for the credential. See package docs. :contentReference[oaicite:1]{index=1}
      developer.log(
        'fb_fixed: tokenString.len=${accessToken.tokenString.length} type=${accessToken.type}',
        name: 'facebook_auth_fixed',
      );

      // Safely inspect subtype-specific fields:
      if (accessToken is ClassicToken) {
        developer.log(
          'fb_fixed: ClassicToken detected — expires=${accessToken.expires.toIso8601String()} '
          'appId=${accessToken.applicationId} userId=${accessToken.userId}',
          name: 'facebook_auth_fixed',
        );
      } else if (accessToken is LimitedToken) {
        // LimitedToken has different fields (nonce, userName, userEmail, userId).
        developer.log(
          'fb_fixed: LimitedToken detected — userId=${accessToken.userId} '
          'userName=${accessToken.userName} userEmail=${accessToken.userEmail} nonce=${accessToken.nonce}',
          name: 'facebook_auth_fixed',
        );
      } else {
        developer.log(
          'fb_fixed: AccessToken subtype unknown: ${accessToken.runtimeType}',
          name: 'facebook_auth_fixed',
        );
      }

      // Build Firebase credential with tokenString (not `.token`).
      final AuthCredential fbCredential = FacebookAuthProvider.credential(
        accessToken.tokenString,
      );

      try {
        final UserCredential uc = await _auth.signInWithCredential(
          fbCredential,
        );
        developer.log(
          'fb_fixed: firebase signInWithCredential success uid=${uc.user?.uid}',
          name: 'facebook_auth_fixed',
        );
        return FacebookAuthOutcome(
          success: true,
          code: 'SUCCESS',
          userCredential: uc,
        );
      } on FirebaseAuthException catch (fae, st) {
        developer.log(
          'fb_fixed: firebase signInWithCredential failed: ${fae.code} ${fae.message}\n$st',
          name: 'facebook_auth_fixed',
          level: 1000,
        );

        // If account exists with different credential, return the pending credential for caller to link.
        if (fae.code == 'account-exists-with-different-credential' ||
            fae.code ==
                'account-exists-with-different-credential'.replaceAll(
                  '-',
                  '_',
                )) {
          // Return pending credential so caller can sign-in with existing provider then link.
          return FacebookAuthOutcome(
            success: false,
            code: 'ACCOUNT_EXISTS',
            message: fae.message,
            pendingCredential: fbCredential,
          );
        }

        return FacebookAuthOutcome(
          success: false,
          code: fae.code,
          message: fae.message,
        );
      } catch (e, st) {
        developer.log(
          'fb_fixed: unexpected error signing with credential: $e\n$st',
          name: 'facebook_auth_fixed',
          level: 1000,
        );
        return FacebookAuthOutcome(
          success: false,
          code: 'ERROR',
          message: e.toString(),
        );
      }
    } catch (e, st) {
      developer.log(
        'fb_fixed: outer exception: $e\n$st',
        name: 'facebook_auth_fixed',
        level: 1000,
      );
      return FacebookAuthOutcome(
        success: false,
        code: 'EXCEPTION',
        message: e.toString(),
      );
    }
  }

  /// Sign out from Firebase and (mobile) Facebook SDK
  Future<void> signOutVerbose() async {
    developer.log(
      'fb_fixed: signOutVerbose called',
      name: 'facebook_auth_fixed',
    );
    await _auth.signOut();
    if (!kIsWeb) {
      try {
        await FacebookAuth.instance.logOut();
        developer.log(
          'fb_fixed: Facebook SDK logged out',
          name: 'facebook_auth_fixed',
        );
      } catch (e) {
        developer.log(
          'fb_fixed: facebook sdk logout error: $e',
          name: 'facebook_auth_fixed',
          level: 800,
        );
      }
    }
  }
}
