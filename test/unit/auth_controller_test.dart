import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:bluesky_app/features/authentication/controllers/auth_controller.dart';
import 'package:bluesky_app/data/repositories/auth_repository.dart';
import 'package:bluesky_app/core/auth/secure_token_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthController Unit Tests', () {
    late AuthController authController;

    setUp(() {
      Get.reset();
      Get.put<SecureTokenStorage>(SecureTokenStorage());
      Get.put<AuthRepository>(AuthRepository());
      authController = Get.put<AuthController>(AuthController());
    });

    tearDown(() {
      Get.reset();
    });

    test('initial state has false loading and unauthenticated status', () {
      expect(authController.isLoading.value, false);
      expect(authController.isAuthenticated.value, false);
    });

    test('validates handle minimum length immediately', () {
      authController.checkHandleAvailability('ab');
      expect(authController.isHandleAvailable.value, false);
      expect(authController.handleStatusMessage.value, contains('at least 3 characters'));
    });

    test('validates handle maximum length immediately', () {
      authController.checkHandleAvailability('a' * 35);
      expect(authController.isHandleAvailable.value, false);
      expect(authController.handleStatusMessage.value, contains('cannot exceed 30 characters'));
    });

    test('validates invalid characters in handle immediately', () {
      authController.checkHandleAvailability('invalid handle!');
      expect(authController.isHandleAvailable.value, false);
      expect(authController.handleStatusMessage.value, contains('Letters, numbers'));
    });
  });
}
