import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthResult {
  const AuthResult({
    required this.success,
    required this.message,
    this.code,
  });

  final bool success;
  final String message;
  final String? code;
}

class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;
  GoogleSignIn? _googleSignIn;

  GoogleSignIn get _googleSignInClient {
    return _googleSignIn ??= GoogleSignIn(
      scopes: const <String>['email', 'profile', 'openid'],
    );
  }

  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  Stream<GoogleSignInAccount?> googleAccountChanges() {
    return _googleSignInClient.onCurrentUserChanged;
  }

  Future<void> restoreGoogleSignInOnWeb() async {
    if (!kIsWeb) {
      return;
    }

    try {
      await _googleSignInClient.signInSilently();
    } catch (_) {
      // Ignore warm-up failures here; the interactive web button will retry.
    }
  }

  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return const AuthResult(
        success: true,
        message: 'Signed in successfully.',
      );
    } on FirebaseAuthException catch (error) {
      return _firebaseAuthFailure(error);
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'Unable to sign in right now. Please try again.',
      );
    }
  }

  Future<AuthResult> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final GoogleAuthProvider provider = GoogleAuthProvider();
        provider.addScope('email');
        provider.addScope('profile');
        await _firebaseAuth.signInWithPopup(provider);
        return const AuthResult(
          success: true,
          message: 'Signed in with Google successfully.',
        );
      }

      final GoogleSignInAccount? gUser = await _googleSignInClient.signIn();
      if (gUser == null) {
        return const AuthResult(
          success: false,
          message: 'Google sign-in was cancelled.',
        );
      }
      return await signInWithGoogleAccount(gUser);
    } on FirebaseAuthException catch (error) {
      return _firebaseAuthFailure(error);
    } on PlatformException catch (error) {
      return AuthResult(
        success: false,
        message: _googlePlatformMessage(error.code),
        code: error.code,
      );
    } catch (error) {
      return AuthResult(
        success: false,
        message: 'Google sign-in failed. (${error.runtimeType})',
        code: error.runtimeType.toString(),
      );
    }
  }

  Future<AuthResult> signInWithGoogleAccount(GoogleSignInAccount gUser) async {
    try {
      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      if (gAuth.idToken == null && gAuth.accessToken == null) {
        return const AuthResult(
          success: false,
          message: 'Google sign-in did not return a usable token. '
              '(code: missing-google-token)',
          code: 'missing-google-token',
        );
      }

      final OAuthCredential cred = GoogleAuthProvider.credential(
        idToken: gAuth.idToken,
        accessToken: gAuth.accessToken,
      );
      await _firebaseAuth.signInWithCredential(cred);
      return const AuthResult(
        success: true,
        message: 'Signed in with Google successfully.',
      );
    } on FirebaseAuthException catch (error) {
      return _firebaseAuthFailure(error);
    } on PlatformException catch (error) {
      return AuthResult(
        success: false,
        message: _googlePlatformMessage(error.code),
        code: error.code,
      );
    } catch (error) {
      return AuthResult(
        success: false,
        message: 'Google sign-in failed. (${error.runtimeType})',
        code: error.runtimeType.toString(),
      );
    }
  }

  Future<AuthResult> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return const AuthResult(
        success: true,
        message: 'Account created successfully.',
      );
    } on FirebaseAuthException catch (error) {
      return _firebaseAuthFailure(error);
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'Unable to create account right now. Please try again.',
      );
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb && _googleSignIn != null) {
      await _googleSignIn!.signOut();
    }
    await _firebaseAuth.signOut();
  }

  Future<AuthResult> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return const AuthResult(
        success: true,
        message: 'Password reset email has been sent. Please check your inbox.',
      );
    } on FirebaseAuthException catch (error) {
      return _firebaseAuthFailure(error);
    } catch (_) {
      return const AuthResult(
        success: false,
        message:
            'Unable to send password reset email right now. Please try again.',
      );
    }
  }

  AuthResult _firebaseAuthFailure(FirebaseAuthException error) {
    return AuthResult(
      success: false,
      message: '${_messageFromCode(error.code)} (code: ${error.code})',
      code: error.code,
    );
  }

  String _googlePlatformMessage(String code) {
    switch (code) {
      case GoogleSignIn.kSignInCanceledError:
        return 'Google sign-in was cancelled. (code: $code)';
      case GoogleSignIn.kNetworkError:
        return 'Google sign-in failed because of a network issue. '
            '(code: $code)';
      case GoogleSignIn.kSignInFailedError:
        return 'Google sign-in failed before Firebase could complete the '
            'login. (code: $code)';
      default:
        return 'Google sign-in failed. (code: $code)';
    }
  }

  String _messageFromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account was found for this email.';
      case 'wrong-password':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled in Firebase.';
      case 'configuration-not-found':
        return 'Firebase Auth configuration was not found for this app. '
            'Check project selection and enable Email/Password sign-in.';
      case 'app-not-authorized':
        return 'This app is not authorized for the current Firebase project.';
      case 'invalid-credential':
        return 'Google returned a credential that Firebase could not accept.';
      case 'account-exists-with-different-credential':
        return 'This email is already linked with another sign-in method.';
      case 'popup-closed-by-user':
        return 'The Google sign-in popup was closed before login completed.';
      case 'popup-blocked':
        return 'The browser blocked the Google sign-in popup.';
      case 'unauthorized-domain':
        return 'This domain is not authorized for Firebase Authentication.';
      default:
        return 'Authentication failed: $code';
    }
  }
}
