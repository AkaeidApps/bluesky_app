import 'package:firebase_auth/firebase_auth.dart';

class AuthExceptionHandler {
  AuthExceptionHandler._();

  /// Converts a [FirebaseAuthException] or general exception into a clean,
  /// user-friendly message without exposing raw exception codes or stack traces.
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'This email address is already in use. Please sign in or use a different email.';
        case 'invalid-email':
          return 'The email address is invalid. Please enter a valid email.';
        case 'weak-password':
          return 'The password is too weak. Please use at least 8 characters with a mix of letters and numbers.';
        case 'user-not-found':
          return 'No account found with this email. Please check your spelling or sign up.';
        case 'wrong-password':
          return 'Incorrect password. Please try again or reset your password.';
        case 'invalid-credential':
        case 'invalid-verification-code':
        case 'invalid-verification-id':
          return 'Invalid login credentials. Please verify your email and password.';
        case 'user-disabled':
          return 'This account has been disabled. Please contact support for assistance.';
        case 'too-many-requests':
          return 'Too many unsuccessful attempts. Access has been temporarily restricted. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection and try again.';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled. Please contact administrator.';
        case 'requires-recent-login':
          return 'This action requires recent authentication. Please log in again to continue.';
        case 'channel-error':
          return 'Please fill in all required fields.';
        default:
          return error.message ??
              'An unexpected authentication error occurred. Please try again.';
      }
    }

    final stringError = error.toString();
    if (stringError.contains('Username') || stringError.contains('Handle')) {
      return stringError.replaceAll('Exception: ', '');
    }

    return 'An unexpected error occurred. Please try again.';
  }
}
