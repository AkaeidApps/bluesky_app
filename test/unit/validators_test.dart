import 'package:flutter_test/flutter_test.dart';
import 'package:bluesky_app/core/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    test('validates email addresses', () {
      expect(Validators.email(''), 'Email is required');
      expect(Validators.email('invalid-email'), 'Enter a valid email address');
      expect(Validators.email('user@example.com'), null);
    });

    test('validates password minimum length', () {
      expect(Validators.password(''), 'Password is required');
      expect(
        Validators.password('12345'),
        'Password must be at least 8 characters',
      );
      expect(Validators.password('password123'), null);
    });

    test('validates confirm password', () {
      expect(
        Validators.confirmPassword('password123', ''),
        'Please confirm your password',
      );
      expect(
        Validators.confirmPassword('password123', 'different'),
        'Passwords do not match',
      );
      expect(Validators.confirmPassword('password123', 'password123'), null);
    });

    test('validates user handles', () {
      expect(Validators.handle(''), 'Handle is required');
      expect(Validators.handle('ab'), 'Handle must be at least 3 characters');
      expect(
        Validators.handle('invalid handle with spaces'),
        'Letters, numbers, underscores and dots only',
      );
      expect(Validators.handle('@valid_handle'), null);
      expect(Validators.handle('maya.lin'), null);
    });

    test('validates display name', () {
      expect(Validators.displayName(''), 'Display name is required');
      expect(Validators.displayName('Maya Lin'), null);
    });
  });
}
