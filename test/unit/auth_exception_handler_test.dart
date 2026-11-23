import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bluesky_app/core/errors/auth_exception_handler.dart';

void main() {
  group('AuthExceptionHandler Unit Tests', () {
    test('maps email-already-in-use to friendly message', () {
      final exception = FirebaseAuthException(code: 'email-already-in-use');
      final message = AuthExceptionHandler.getErrorMessage(exception);
      expect(message, contains('already in use'));
    });

    test('maps invalid-email to friendly message', () {
      final exception = FirebaseAuthException(code: 'invalid-email');
      final message = AuthExceptionHandler.getErrorMessage(exception);
      expect(message, contains('valid email'));
    });

    test('maps weak-password to friendly message', () {
      final exception = FirebaseAuthException(code: 'weak-password');
      final message = AuthExceptionHandler.getErrorMessage(exception);
      expect(message, contains('too weak'));
    });

    test('maps user-not-found to friendly message', () {
      final exception = FirebaseAuthException(code: 'user-not-found');
      final message = AuthExceptionHandler.getErrorMessage(exception);
      expect(message, contains('No account found'));
    });

    test('maps wrong-password to friendly message', () {
      final exception = FirebaseAuthException(code: 'wrong-password');
      final message = AuthExceptionHandler.getErrorMessage(exception);
      expect(message, contains('Incorrect password'));
    });

    test('maps invalid-credential to friendly message', () {
      final exception = FirebaseAuthException(code: 'invalid-credential');
      final message = AuthExceptionHandler.getErrorMessage(exception);
      expect(message, contains('Invalid login credentials'));
    });

    test('maps user-disabled to friendly message', () {
      final exception = FirebaseAuthException(code: 'user-disabled');
      final message = AuthExceptionHandler.getErrorMessage(exception);
      expect(message, contains('disabled'));
    });

    test('maps too-many-requests to friendly message', () {
      final exception = FirebaseAuthException(code: 'too-many-requests');
      final message = AuthExceptionHandler.getErrorMessage(exception);
      expect(message, contains('temporarily restricted'));
    });

    test('maps network-request-failed to friendly message', () {
      final exception = FirebaseAuthException(code: 'network-request-failed');
      final message = AuthExceptionHandler.getErrorMessage(exception);
      expect(message, contains('Network error'));
    });

    test('never exposes raw unhandled exception codes', () {
      final exception = FirebaseAuthException(
        code: 'unknown-code-xyz',
        message: 'Friendly explanation',
      );
      final message = AuthExceptionHandler.getErrorMessage(exception);
      expect(message, 'Friendly explanation');
    });
  });
}
