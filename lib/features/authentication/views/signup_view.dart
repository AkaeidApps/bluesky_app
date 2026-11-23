import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluesky_app/app/routes/app_routes.dart';
import 'package:bluesky_app/core/constants/app_colors.dart';
import 'package:bluesky_app/core/widgets/aura_brand_mark.dart';
import 'package:bluesky_app/core/widgets/aura_button.dart';
import 'package:bluesky_app/core/widgets/aura_text_field.dart';
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
                "Your account will be your home across the open social network.",
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 28),
              AuraTextField(
                controller: controller.signupDisplayNameController,
                labelText: "Display Name",
                hintText: "e.g. Maya Lin",
                prefixIcon: const Icon(Icons.person_outline, size: 20),
              ),
              const SizedBox(height: 18),
              AuraTextField(
                controller: controller.signupHandleController,
                labelText: "User Handle",
                hintText: "mayalin",
                prefixIcon: const Icon(Icons.alternate_email, size: 20),
                onChanged: controller.checkHandleAvailability,
              ),
              Obx(() {
                if (controller.isCheckingHandle.value) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Text(
                      "Checking handle availability...",
                      style: TextStyle(fontSize: 12, color: AppColors.primary),
                    ),
                  );
                }
                if (controller.handleStatusMessage.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      controller.handleStatusMessage.value,
                      style: TextStyle(
                        fontSize: 12,
                        color: controller.isHandleAvailable.value
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 18),
              AuraTextField(
                controller: controller.signupEmailController,
                labelText: "Email",
                hintText: "you@example.com",
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.mail_outline, size: 20),
              ),
              const SizedBox(height: 18),
              AuraTextField(
                controller: controller.signupPasswordController,
                labelText: "Password",
                hintText: "At least 8 characters",
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
              ),
              const SizedBox(height: 28),
              Obx(
                () => AuraButton(
                  text: "Next",
                  width: double.infinity,
                  isLoading: controller.isLoading.value,
                  onPressed: controller.signup,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.offNamed(AppRoutes.login),
                    child: const Text(
                      "Sign in",
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
