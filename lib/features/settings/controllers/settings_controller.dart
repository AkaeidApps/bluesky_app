import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluesky_app/app/routes/app_routes.dart';
import 'package:bluesky_app/core/constants/app_colors.dart';
import 'package:bluesky_app/data/repositories/auth_repository.dart';

class SettingsController extends GetxController {
  final AuthRepository _authRepo = Get.find<AuthRepository>();

  final themeMode = 'system'.obs;

  void setTheme(ThemeMode mode) {
    Get.changeThemeMode(mode);
    themeMode.value = mode.name;
  }

  Future<void> logout() async {
    await _authRepo.signOut();
    Get.offAllNamed(AppRoutes.onboarding);
  }

  Future<void> confirmDeleteAccount() async {
    Get.defaultDialog(
      title: 'Delete Account',
      middleText: 'Are you sure you want to permanently delete your account? This action cannot be undone.',
      textConfirm: 'Delete Forever',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () async {
        Get.back();
        await _authRepo.deleteAccount();
        Get.offAllNamed(AppRoutes.onboarding);
        Get.snackbar('Account Deleted', 'Your account has been deleted.');
      },
    );
  }
}
