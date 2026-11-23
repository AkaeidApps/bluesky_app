import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluesky_app/app/routes/app_routes.dart';
import 'package:bluesky_app/core/constants/app_colors.dart';
import 'package:bluesky_app/core/widgets/aura_avatar.dart';
import 'package:bluesky_app/core/widgets/aura_brand_mark.dart';
import 'package:bluesky_app/features/home/controllers/home_controller.dart';
import 'package:bluesky_app/features/timeline/views/timeline_view.dart';
import 'package:bluesky_app/features/search/views/search_view.dart';
import 'package:bluesky_app/features/notifications/views/notifications_view.dart';
import 'package:bluesky_app/features/chat/views/conversations_list_view.dart';
import 'package:bluesky_app/features/profile/views/profile_view.dart';

class MainNavigationShell extends GetView<HomeController> {
  const MainNavigationShell({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> pages = [
      const TimelineView(),
      const SearchView(),
      const NotificationsView(),
      const ConversationsListView(),
      const ProfileView(),
    ];

    return Scaffold(
      drawer: _buildDrawer(context, isDark),
      body: Obx(
        () => IndexedStack(
          index: controller.currentTabIndex.value,
          children: pages,
        ),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 0.8,
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: controller.currentTabIndex.value,
            onDestinationSelected: controller.switchTab,
            backgroundColor: isDark
                ? AppColors.darkBackground
                : AppColors.lightBackground,
            indicatorColor: Colors.transparent,
            height: 60,
            destinations: [
              NavigationDestination(
                icon: Icon(
                  Icons.home_outlined,
                  color: controller.currentTabIndex.value == 0
                      ? AppColors.primary
                      : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                  size: 26,
                ),
                selectedIcon: const Icon(
                  Icons.home,
                  color: AppColors.primary,
                  size: 26,
                ),
                label: '',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.search_outlined,
                  color: controller.currentTabIndex.value == 1
                      ? AppColors.primary
                      : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                  size: 26,
                ),
                selectedIcon: const Icon(
                  Icons.search,
                  color: AppColors.primary,
                  size: 26,
                ),
                label: '',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: controller.unreadNotificationsCount.value > 0,
                  label: Text('${controller.unreadNotificationsCount.value}'),
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.notifications_outlined,
                    color: controller.currentTabIndex.value == 2
                        ? AppColors.primary
                        : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                    size: 26,
                  ),
                ),
                selectedIcon: const Icon(
                  Icons.notifications,
                  color: AppColors.primary,
                  size: 26,
                ),
                label: '',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: controller.unreadMessagesCount.value > 0,
                  label: Text('${controller.unreadMessagesCount.value}'),
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.mail_outline_rounded,
                    color: controller.currentTabIndex.value == 3
                        ? AppColors.primary
                        : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                    size: 26,
                  ),
                ),
                selectedIcon: const Icon(
                  Icons.mail_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
                label: '',
              ),
              NavigationDestination(
                icon: Obx(
                  () => Container(
                    padding: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: controller.currentTabIndex.value == 4
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: AuraAvatar(
                      imageUrl: controller.currentUser.value?.avatarUrl,
                      fallbackName:
                          controller.currentUser.value?.displayName ?? 'User',
                      size: 24,
                    ),
                  ),
                ),
                label: '',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.composer),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: const CircleBorder(),
        child: const Icon(Icons.edit_outlined, size: 24),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDark) {
    return Drawer(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Obx(() {
                final user = controller.currentUser.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AuraAvatar(
                      imageUrl: user?.avatarUrl,
                      fallbackName: user?.displayName ?? 'User',
                      size: 56,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user?.displayName ?? 'User',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (user?.isVerified ?? false) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 16,
                            color: AppColors.verifiedBadge,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      user?.fullHandle ?? '@user',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          '${user?.followersCount ?? 0}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'followers',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${user?.followingCount ?? 0}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'following',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
            Divider(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            _drawerItem(
              icon: Icons.person_outline,
              title: 'Profile',
              onTap: () {
                Navigator.of(context).pop();
                controller.switchTab(4);
              },
            ),
            _drawerItem(
              icon: Icons.tag,
              title: 'Feeds',
              onTap: () {
                Navigator.of(context).pop();
                Get.toNamed(AppRoutes.feeds);
              },
            ),
            _drawerItem(
              icon: Icons.bookmark_border,
              title: 'Bookmarks',
              onTap: () {
                Navigator.of(context).pop();
                Get.toNamed(AppRoutes.profile);
              },
            ),
            _drawerItem(
              icon: Icons.shield_outlined,
              title: 'Moderation',
              onTap: () {
                Navigator.of(context).pop();
                Get.toNamed(AppRoutes.settings);
              },
            ),
            _drawerItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {
                Navigator.of(context).pop();
                Get.toNamed(AppRoutes.settings);
              },
            ),
            const Spacer(),
            Divider(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AuraBrandMark(size: 24),
                  IconButton(
                    icon: Icon(
                      isDark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    onPressed: () {
                      Get.changeThemeMode(
                        isDark ? ThemeMode.light : ThemeMode.dark,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
    );
  }
}
