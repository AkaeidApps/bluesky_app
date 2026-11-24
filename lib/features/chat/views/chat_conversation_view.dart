import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluesky_app/core/constants/app_colors.dart';
import 'package:bluesky_app/core/constants/app_radius.dart';
import 'package:bluesky_app/core/utils/date_formatter.dart';
import 'package:bluesky_app/core/widgets/aura_app_bar.dart';
import 'package:bluesky_app/core/widgets/aura_avatar.dart';
import 'package:bluesky_app/data/models/chat_model.dart';
import 'package:bluesky_app/features/chat/controllers/chat_controller.dart';

class ChatConversationView extends GetView<ChatController> {
  const ChatConversationView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: _buildAppBar(isDark),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.currentMessages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        size: 48,
                        color: AppColors.lightTextTertiary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No messages yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Start the conversation!',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: controller.currentMessages.length,
                itemBuilder: (context, index) {
                  final message = controller.currentMessages[controller.currentMessages.length - 1 - index];
                  final isMe = message.senderId == 'user_current';

                  return _buildMessageBubble(context, message, isMe, isDark);
                },
              );
            }),
          ),
          _buildMessageInput(isDark),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(54),
      child: Obx(() {
        final conv = controller.activeConversation.value;
        final otherUser = conv?.getOtherParticipant('user_current');

        return AuraAppBar(
        titleWidget: Row(
          children: [
            AuraAvatar(
              imageUrl: otherUser?.avatarUrl,
              fallbackName: otherUser?.displayName ?? 'User',
              size: 32,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherUser?.displayName ?? 'User',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '@${otherUser?.handle ?? 'user'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () => _showConversationOptions(conv!),
          ),
        ],
      );
      }),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    ChatMessageModel message,
    bool isMe,
    bool isDark,
  ) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AuraAvatar(
                    imageUrl: null,
                    fallbackName: message.senderHandle,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    message.senderHandle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? AppColors.primary
                    : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.lg),
                  topRight: Radius.circular(AppRadius.lg),
                  bottomLeft: isMe ? Radius.circular(AppRadius.lg) : Radius.circular(AppRadius.xs),
                  bottomRight: isMe ? Radius.circular(AppRadius.xs) : Radius.circular(AppRadius.lg),
                ),
                border: isMe
                    ? null
                    : Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 0.8,
                      ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 15,
                  color: isMe ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormatter.formatRelative(message.createdAt),
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.8,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image_outlined, color: AppColors.primary),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: controller.messageInputController,
                decoration: InputDecoration(
                  hintText: 'Message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: 8),
            Obx(() => controller.messageInputController.text.trim().isEmpty
                ? IconButton(
                    icon: const Icon(Icons.mic_outlined, color: AppColors.primary),
                    onPressed: () {},
                  )
                : IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                    onPressed: controller.sendMessage,
                  )),
          ],
        ),
      ),
    );
  }

  void _showConversationOptions(ConversationModel conv) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(Get.context!).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.notifications_off_outlined),
                title: Text(conv.isMuted ? 'Unmute conversation' : 'Mute conversation'),
                onTap: () => Get.back(),
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: AppColors.error),
                title: const Text('Report', style: TextStyle(color: AppColors.error)),
                onTap: () => Get.back(),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text('Delete conversation', style: TextStyle(color: AppColors.error)),
                onTap: () => Get.back(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}