import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:bluesky_app/features/authentication/controllers/auth_controller.dart';
import 'package:bluesky_app/data/repositories/auth_repository.dart';
import 'package:bluesky_app/features/authentication/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthController Unit Tests', () {
    late AuthController authController;

    setUp(() {
      Get.reset();
      Get.put<AuthRepository>(AuthRepository(authService: AuthService()));
      authController = Get.put<AuthController>(AuthController());
    });

    tearDown(() {
      Get.reset();
    });

    test('initial state has empty controllers and false loading', () {
      expect(authController.isLoading.value, false);
      expect(authController.isCheckingHandle.value, false);
      expect(authController.loginEmailController.text, '');
      expect(authController.loginPasswordController.text, '');
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
