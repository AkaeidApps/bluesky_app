import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluesky_app/app/routes/app_routes.dart';
import 'package:bluesky_app/core/errors/auth_exception_handler.dart';
import 'package:bluesky_app/core/utils/validators.dart';
import 'package:bluesky_app/data/models/user_model.dart';
import 'package:bluesky_app/data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  // Form Controllers
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();

  final signupDisplayNameController = TextEditingController();
  final signupHandleController = TextEditingController();
  final signupEmailController = TextEditingController();
  final signupPasswordController = TextEditingController();
  final signupConfirmPasswordController = TextEditingController();

  final resetEmailController = TextEditingController();

  // Reactive State
  final Rxn<User> firebaseUser = Rxn<User>();
  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxBool isAuthenticated = false.obs;
  final RxBool isEmailVerified = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isCheckingHandle = false.obs;
  final RxBool isHandleAvailable = false.obs;
  final RxString handleStatusMessage = ''.obs;

  StreamSubscription<User?>? _authStateSubscription;
  Timer? _debounceTimer;
  bool _hasInitialNavigated = false;

  @override
  void onInit() {
    super.onInit();
    _initAuthStateListener();
  }

  void _initAuthStateListener() {
    _authStateSubscription = _authRepository.authStateChanges.listen((
      user,
    ) async {
      firebaseUser.value = user;
      isAuthenticated.value = user != null;
      isEmailVerified.value = user?.emailVerified ?? false;

      if (user != null) {
        final profile = await _authRepository.getUserProfile(user.uid);
        currentUser.value = profile;

        // Guard against duplicate automatic navigation if user is already navigating or in main shell
        if (!_hasInitialNavigated && Get.currentRoute == AppRoutes.splash) {
          _hasInitialNavigated = true;
          Get.offAllNamed(AppRoutes.mainNav);
        }
      } else {
        currentUser.value = null;
        if (!_hasInitialNavigated && Get.currentRoute == AppRoutes.splash) {
          _hasInitialNavigated = true;
          Get.offAllNamed(AppRoutes.onboarding);
        }
      }
    });
  }

  /// Debounced check for handle / username availability
  void checkHandleAvailability(String handle) {
    _debounceTimer?.cancel();
    final clean = handle.replaceAll('@', '').trim().toLowerCase();

    if (clean.length < 3) {
      isHandleAvailable.value = false;
      handleStatusMessage.value = 'Handle must be at least 3 characters';
      return;
    }

    if (clean.length > 30) {
      isHandleAvailable.value = false;
      handleStatusMessage.value = 'Handle cannot exceed 30 characters';
      return;
    }

    final handleRegex = RegExp(r'^[a-zA-Z0-9_\.]+$');
    if (!handleRegex.hasMatch(clean)) {
      isHandleAvailable.value = false;
      handleStatusMessage.value = 'Letters, numbers, underscores and dots only';
      return;
    }

    isCheckingHandle.value = true;
    handleStatusMessage.value = '';

    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      try {
        final available = await _authRepository.isHandleAvailable(clean);
        isHandleAvailable.value = available;
        handleStatusMessage.value = available
            ? '✓ @$clean is available'
            : '✗ @$clean is already taken';
      } catch (_) {
        handleStatusMessage.value = 'Error checking handle';
      } finally {
        isCheckingHandle.value = false;
      }
    });
  }

  /// Real Firebase Authentication: Login with Email or Handle
  Future<void> login() async {
    if (isLoading.value) return; // Prevent repeated submissions

    final identifier = loginEmailController.text.trim();
    final password = loginPasswordController.text;

    if (identifier.isEmpty) {
      Get.snackbar(
        'Email or Handle Required',
        'Please enter your email or user handle.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (password.isEmpty) {
      Get.snackbar(
        'Password Required',
        'Please enter your password.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      final user = await _authRepository.signIn(
        email: identifier,
        password: password,
      );
      currentUser.value = user;

      // Check email verification status and inform user non-intrusively
      if (!user.emailVerified) {
        Get.snackbar(
          'Email Verification',
          'Your email is not verified yet. A verification email was sent to ${user.email}.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }

      Get.offAllNamed(AppRoutes.mainNav);
    } catch (e) {
      final message = AuthExceptionHandler.getErrorMessage(e);
      Get.snackbar(
        'Sign In Failed',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Real Firebase Authentication: Signup with atomic username reservation
  Future<void> signup() async {
    if (isLoading.value) return; // Prevent repeated submissions

    final displayName = signupDisplayNameController.text.trim();
    final handle = signupHandleController.text.trim();
    final email = signupEmailController.text.trim();
    final password = signupPasswordController.text;
    final confirmPassword = signupConfirmPasswordController.text;

    final nameError = Validators.displayName(displayName);
    if (nameError != null) {
      Get.snackbar(
        'Invalid Name',
        nameError,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final handleError = Validators.handle(handle);
    if (handleError != null) {
      Get.snackbar(
        'Invalid Handle',
        handleError,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final emailError = Validators.email(email);
    if (emailError != null) {
      Get.snackbar(
        'Invalid Email',
        emailError,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final passwordError = Validators.password(password);
    if (passwordError != null) {
      Get.snackbar(
        'Weak Password',
        passwordError,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // If confirm password was provided, verify matching
    if (confirmPassword.isNotEmpty && confirmPassword != password) {
      Get.snackbar(
        'Password Mismatch',
        'Passwords do not match. Please re-enter your password.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      final user = await _authRepository.signUp(
        email: email,
        password: password,
        displayName: displayName,
        handle: handle,
      );
      currentUser.value = user;

      Get.snackbar(
        'Welcome to Aura!',
        'Account created successfully. A verification email has been sent to $email.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );

      Get.offAllNamed(AppRoutes.mainNav);
    } catch (e) {
      final message = AuthExceptionHandler.getErrorMessage(e);
      Get.snackbar(
        'Sign Up Failed',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Send password reset link to user email
  Future<void> sendPasswordReset() async {
    if (isLoading.value) return;

    final email = resetEmailController.text.trim();
    final emailError = Validators.email(email);
    if (emailError != null) {
      Get.snackbar(
        'Invalid Email',
        emailError,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      await _authRepository.sendPasswordReset(email);
      Get.back();
      Get.snackbar(
        'Check Your Inbox',
        'A password reset link has been sent to $email. Please check your spam folder if not received.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      final message = AuthExceptionHandler.getErrorMessage(e);
      Get.snackbar(
        'Reset Failed',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Resend email verification
  Future<void> resendEmailVerification() async {
    try {
      await _authRepository.sendEmailVerification();
      Get.snackbar(
        'Verification Sent',
        'A new verification link has been sent to your email.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      final message = AuthExceptionHandler.getErrorMessage(e);
      Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Secure logout: Signs out of Firebase and resets all auth session state
  Future<void> logout() async {
    try {
      await _authRepository.signOut();
      currentUser.value = null;
      firebaseUser.value = null;
      isAuthenticated.value = false;

      // Clear input fields
      loginEmailController.clear();
      loginPasswordController.clear();
      signupDisplayNameController.clear();
      signupHandleController.clear();
      signupEmailController.clear();
      signupPasswordController.clear();
      signupConfirmPasswordController.clear();
      resetEmailController.clear();

      Get.offAllNamed(AppRoutes.onboarding);
    } catch (e) {
      Get.snackbar('Sign Out Error', 'Failed to sign out. Please try again.');
    }
  }

  @override
  void onClose() {
    _authStateSubscription?.cancel();
    _debounceTimer?.cancel();
    loginEmailController.dispose();
    loginPasswordController.dispose();
    signupDisplayNameController.dispose();
    signupHandleController.dispose();
    signupEmailController.dispose();
    signupPasswordController.dispose();
    signupConfirmPasswordController.dispose();
    resetEmailController.dispose();
    super.onClose();
  }
}
