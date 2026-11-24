import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bluesky_app/app/routes/app_routes.dart';
import 'package:bluesky_app/core/constants/app_colors.dart';
import 'package:bluesky_app/core/widgets/aura_brand_mark.dart';
import 'package:bluesky_app/core/widgets/aura_button.dart';
import 'package:bluesky_app/features/authentication/controllers/auth_controller.dart';

class OnboardingView extends GetView<AuthController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              const AuraBrandMark(size: 96),
              const SizedBox(height: 32),
              Text(
                "See what's next.",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Join the open, decentralized social conversation where you control your experience, your algorithms, and your data.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const Spacer(flex: 3),
              Obx(
                () => AuraButton(
                  text: "Connect with Bluesky",
                  width: double.infinity,
                  isLoading: controller.isLoading.value,
                  icon: Icons.cloud_outlined,
                  onPressed: controller.startOAuthLogin,
                ),
              ),
              const SizedBox(height: 14),
              AuraButton(
                text: "Learn about AT Protocol",
                width: double.infinity,
                variant: AuraButtonVariant.secondary,
                onPressed: () async {
                  final uri = Uri.parse('https://atproto.com/');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              const SizedBox(height: 24),
              Text(
                "By connecting, you agree to the Terms of Service and Privacy Policy.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}