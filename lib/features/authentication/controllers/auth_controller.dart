import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bluesky_app/app/routes/app_routes.dart';
import 'package:bluesky_app/core/auth/atproto_auth_service.dart';
import 'package:bluesky_app/core/auth/secure_token_storage.dart';
import 'package:bluesky_app/core/utils/validators.dart';
import 'package:bluesky_app/data/models/user_model.dart';
import 'package:bluesky_app/data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final SecureTokenStorage _tokenStorage = Get.find<SecureTokenStorage>();

  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxBool isAuthenticated = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isCheckingHandle = false.obs;
  final RxBool isHandleAvailable = false.obs;
  final RxString handleStatusMessage = ''.obs;

  Timer? _debounceTimer;
  bool _hasInitialNavigated = false;

  @override
  void onInit() {
    super.onInit();
    _initAuthStateListener();
  }

  void _initAuthStateListener() {
    _authRepository.authStateChanges.listen((authenticated) async {
      isAuthenticated.value = authenticated;

      if (authenticated) {
        final profile = await _authRepository.getCurrentUserProfile();
        currentUser.value = profile;

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

  Future<void> startOAuthLogin() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      await _authRepository.signInWithOAuth(
        onAuthUrlReady: (authUrl) async {
          isLoading.value = false;
          final uri = Uri.parse(authUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            Get.snackbar('Error', 'Could not open browser for login');
          }
        },
        onError: (error) {
          isLoading.value = false;
          Get.snackbar('Login Error', error, snackPosition: SnackPosition.BOTTOM);
        },
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Sign In Failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> handleOAuthCallback(Uri callbackUri) async {
    try {
      isLoading.value = true;
      await _authRepository.handleOAuthCallback(callbackUri);
      isLoading.value = false;
      Get.offAllNamed(AppRoutes.mainNav);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Sign In Failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.signOut();
      currentUser.value = null;
      isAuthenticated.value = false;
      Get.offAllNamed(AppRoutes.onboarding);
    } catch (e) {
      Get.snackbar('Sign Out Error', 'Failed to sign out. Please try again.');
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}