import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bluesky_app/app/routes/app_routes.dart';
import 'package:bluesky_app/core/constants/app_colors.dart';
import 'package:bluesky_app/core/widgets/aura_brand_mark.dart';
import 'package:bluesky_app/core/widgets/aura_button.dart';
import 'package:bluesky_app/features/authentication/controllers/auth_controller.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: AuraBrandMark(size: 48)),
              const SizedBox(height: 24),
              Text(
                "Create your account",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Sign up on Bluesky first, then connect your account here.",
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 32),
              Obx(
                () => AuraButton(
                  text: "Sign up on Bluesky",
                  width: double.infinity,
                  isLoading: controller.isLoading.value,
                  icon: Icons.cloud_outlined,
                  onPressed: () async {
                    final uri = Uri.parse('https://bsky.app/signup');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => AuraButton(
                  text: "Already have an account? Sign in",
                  width: double.infinity,
                  variant: AuraButtonVariant.outline,
                  isLoading: controller.isLoading.value,
                  onPressed: controller.startOAuthLogin,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Learn more about ",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final uri = Uri.parse('https://docs.bsky.app/');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: const Text(
                      "AT Protocol",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}