import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluesky_app/core/constants/app_colors.dart';
import 'package:bluesky_app/core/widgets/aura_brand_mark.dart';
import 'package:bluesky_app/core/widgets/aura_button.dart';
import 'package:bluesky_app/core/widgets/aura_text_field.dart';
import 'package:bluesky_app/features/authentication/controllers/auth_controller.dart';

class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({super.key});

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: AuraBrandMark(size: 48)),
              const SizedBox(height: 24),
              Text(
                "Reset password",
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
                "Enter your email address and we'll send you instructions to reset your password.",
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 32),
              AuraTextField(
                controller: controller.resetEmailController,
                labelText: "Email",
                hintText: "you@example.com",
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.mail_outline, size: 20),
              ),
              const SizedBox(height: 28),
              Obx(
                () => AuraButton(
                  text: "Send Reset Link",
                  width: double.infinity,
                  isLoading: controller.isLoading.value,
                  onPressed: controller.sendPasswordReset,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
