import 'package:firebase_auth/firebase_auth.dart';

class AuthResult {
  const AuthResult({required this.success, required this.message});

  final bool success;
  final String message;
}

class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
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
      return AuthResult(success: false, message: _messageFromCode(error.code));
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'Unable to sign in right now. Please try again.',
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
      return AuthResult(success: false, message: _messageFromCode(error.code));
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'Unable to create account right now. Please try again.',
      );
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
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
      case 'invalid-credential':
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
      default:
        return 'Authentication failed: $code';
    }
  }
}
