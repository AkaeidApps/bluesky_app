import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluesky_app/app/routes/app_routes.dart';
import 'package:bluesky_app/core/constants/app_colors.dart';
import 'package:bluesky_app/core/utils/date_formatter.dart';
import 'package:bluesky_app/core/widgets/aura_app_bar.dart';
import 'package:bluesky_app/core/widgets/aura_avatar.dart';
import 'package:bluesky_app/data/models/notification_model.dart';
import 'package:bluesky_app/features/notifications/controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AuraAppBar(
        title: 'Notifications',
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'Mark all as read',
            onPressed: controller.markAllAsRead,
          ),
        ],
        bottom: TabBar(
          controller: controller.tabController,
          indicatorColor: AppColors.primary,
          labelColor: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
          unselectedLabelColor: isDark
              ? AppColors.darkTextTertiary
              : AppColors.lightTextSecondary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Mentions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: [
          Obx(
            () => _buildNotificationList(
              context,
              controller.notifications,
              isDark,
            ),
          ),
          Obx(
            () => _buildNotificationList(
              context,
              controller.mentionNotifications,
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(
    BuildContext context,
    List<NotificationModel> list,
    bool isDark,
  ) {
    if (controller.isLoading.value && list.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_none,
              size: 56,
              color: AppColors.lightTextTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final notif = list[index];
        return _buildNotificationTile(context, notif, isDark);
      },
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    NotificationModel notif,
    bool isDark,
  ) {
    IconData icon;
    Color iconColor;

    switch (notif.type) {
      case NotificationType.like:
        icon = Icons.favorite_rounded;
        iconColor = AppColors.like;
        break;
      case NotificationType.repost:
        icon = Icons.repeat_rounded;
        iconColor = AppColors.repost;
        break;
      case NotificationType.reply:
      case NotificationType.mention:
        icon = Icons.chat_bubble_rounded;
        iconColor = AppColors.primary;
        break;
      case NotificationType.follow:
        icon = Icons.person_add_rounded;
        iconColor = AppColors.primary;
        break;
      case NotificationType.quote:
        icon = Icons.format_quote_rounded;
        iconColor = AppColors.bookmark;
        break;
    }

    return InkWell(
      onTap: () {
        if (notif.postId != null) {
          Get.toNamed(AppRoutes.postDetails);
        } else {
          Get.toNamed(AppRoutes.profile, arguments: notif.senderId);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: notif.isRead
              ? Colors.transparent
              : (isDark
                    ? AppColors.darkSurface.withValues(alpha: 0.5)
                    : AppColors.primarySurfaceLight.withValues(alpha: 0.4)),
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              width: 0.8,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 32,
              child: Align(
                alignment: Alignment.topRight,
                child: Icon(icon, color: iconColor, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuraAvatar(
                    imageUrl: notif.senderAvatarUrl,
                    fallbackName: notif.senderDisplayName,
                    size: 32,
                    onTap: () => Get.toNamed(
                      AppRoutes.profile,
                      arguments: notif.senderId,
                    ),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                      children: [
                        TextSpan(
                          text: notif.senderDisplayName,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: _getNotificationActionText(notif.type)),
                      ],
                    ),
                  ),
                  if (notif.postSnippet != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      notif.postSnippet!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    DateFormatter.formatRelative(notif.createdAt),
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
            if (!notif.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getNotificationActionText(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return ' liked your post';
      case NotificationType.repost:
        return ' reposted your post';
      case NotificationType.reply:
        return ' replied to you';
      case NotificationType.mention:
        return ' mentioned you in a post';
      case NotificationType.follow:
        return ' followed you';
      case NotificationType.quote:
        return ' quoted your post';
    }
  }
}
