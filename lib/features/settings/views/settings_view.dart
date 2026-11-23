import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluesky_app/app/routes/app_routes.dart';
import 'package:bluesky_app/core/constants/app_colors.dart';
import 'package:bluesky_app/core/constants/app_constants.dart';
import 'package:bluesky_app/core/widgets/aura_brand_mark.dart';
import 'package:bluesky_app/features/settings/controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Appearance'),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Theme'),
            subtitle: Text(isDark ? 'Dark theme' : 'Light theme'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Get.bottomSheet(
                Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.light_mode_outlined),
                        title: const Text('Light Theme'),
                        onTap: () {
                          controller.setTheme(ThemeMode.light);
                          Get.back();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.dark_mode_outlined),
                        title: const Text('Dark Theme'),
                        onTap: () {
                          controller.setTheme(ThemeMode.dark);
                          Get.back();
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.settings_system_daydream_outlined,
                        ),
                        title: const Text('System Default'),
                        onTap: () {
                          controller.setTheme(ThemeMode.system);
                          Get.back();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          _buildSectionHeader('Preferences'),
          ListTile(
            leading: const Icon(Icons.tag),
            title: const Text('Saved Feeds'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed(AppRoutes.feeds),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notification Preferences'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.snackbar(
              'Notifications',
              'Push notifications enabled via FCM',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.translate_outlined),
            title: const Text('Post Languages'),
            subtitle: const Text('English (US)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          _buildSectionHeader('Safety & Moderation'),
          ListTile(
            leading: const Icon(Icons.block_outlined),
            title: const Text('Blocked Accounts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.volume_off_outlined),
            title: const Text('Muted Words & Tags'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          _buildSectionHeader('About'),
          ListTile(
            leading: const AuraBrandMark(size: 24),
            title: const Text('About ${AppConstants.appName}'),
            subtitle: const Text('v1.0.0+1 · Production build'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () {},
          ),
          _buildSectionHeader('Account'),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: controller.logout,
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: AppColors.error),
            title: const Text(
              'Delete Account',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: controller.confirmDeleteAccount,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.lightTextTertiary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
