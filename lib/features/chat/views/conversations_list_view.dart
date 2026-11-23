import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluesky_app/app/routes/app_routes.dart';
import 'package:bluesky_app/core/constants/app_colors.dart';
import 'package:bluesky_app/core/utils/date_formatter.dart';
import 'package:bluesky_app/core/widgets/aura_app_bar.dart';
import 'package:bluesky_app/core/widgets/aura_avatar.dart';
import 'package:bluesky_app/features/chat/controllers/chat_controller.dart';

class ConversationsListView extends GetView<ChatController> {
  const ConversationsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const AuraAppBar(title: 'Messages'),
      body: Obx(() {
        if (controller.isLoadingConversations.value &&
            controller.conversations.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.mail_outline,
                  size: 56,
                  color: AppColors.lightTextTertiary,
                ),
                const SizedBox(height: 12),
                Text(
                  'No direct messages',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Start a conversation with anyone you follow.',
                  style: TextStyle(
                    color: AppColors.lightTextSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.conversations.length,
          itemBuilder: (context, index) {
            final conv = controller.conversations[index];
            final otherUser = conv.getOtherParticipant('user_current');

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: AuraAvatar(
                imageUrl: otherUser?.avatarUrl,
                fallbackName: otherUser?.displayName ?? 'User',
                size: 46,
              ),
              title: Row(
                children: [
                  Flexible(
                    child: Text(
                      otherUser?.displayName ?? 'User',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '· ${DateFormatter.formatRelative(conv.lastMessageTime)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                conv.lastMessageText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: conv.unreadCount > 0
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: conv.unreadCount > 0
                      ? (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary)
                      : (isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextSecondary),
                ),
              ),
              trailing: conv.unreadCount > 0
                  ? Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${conv.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
              onTap: () {
                controller.openConversation(conv);
                Get.toNamed(AppRoutes.chatConversation);
              },
            );
          },
        );
      }),
    );
  }
}
