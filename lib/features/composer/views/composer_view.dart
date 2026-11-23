import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluesky_app/core/constants/app_colors.dart';
import 'package:bluesky_app/core/constants/app_constants.dart';
import 'package:bluesky_app/core/constants/app_radius.dart';
import 'package:bluesky_app/core/widgets/aura_avatar.dart';
import 'package:bluesky_app/core/widgets/aura_button.dart';
import 'package:bluesky_app/data/providers/mock_data_provider.dart';
import 'package:bluesky_app/features/composer/controllers/composer_controller.dart';

class ComposerView extends GetView<ComposerController> {
  const ComposerView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = MockDataProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Obx(
              () => AuraButton(
                text: controller.replyingToPost.value != null
                    ? 'Reply'
                    : 'Post',
                isCompact: true,
                isLoading: controller.isPublishing.value,
                onPressed: controller.publishPost,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Replying To preview banner if applicable
                    Obx(() {
                      final parent = controller.replyingToPost.value;
                      if (parent == null) return const SizedBox.shrink();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurface,
                          borderRadius: AppRadius.radiusMd,
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AuraAvatar(
                              imageUrl: parent.authorAvatarUrl,
                              fallbackName: parent.authorDisplayName,
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Replying to @${parent.authorHandle}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    parent.content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AuraAvatar(
                          imageUrl: user.avatarUrl,
                          fallbackName: user.displayName,
                          size: 40,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: controller.textController,
                            autofocus: true,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            style: TextStyle(
                              fontSize: 17,
                              height: 1.4,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: controller.replyingToPost.value != null
                                  ? 'Write your reply'
                                  : "What's up?",
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              fillColor: Colors.transparent,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Media preview gallery
                    Obx(() {
                      if (controller.selectedImages.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Container(
                        height: 120,
                        margin: const EdgeInsets.only(top: 16),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.selectedImages.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final file = controller.selectedImages[index];
                            final alt = controller.altTexts[index];

                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: AppRadius.radiusMd,
                                  child: Image.file(
                                    File(file.path),
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => controller.removeImage(index),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 4,
                                  left: 4,
                                  child: GestureDetector(
                                    onTap: () => controller.editAltText(index),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: alt.isNotEmpty
                                            ? AppColors.primary
                                            : Colors.black54,
                                        borderRadius: AppRadius.radiusXs,
                                      ),
                                      child: Text(
                                        alt.isNotEmpty ? 'ALT ✓' : '+ ALT',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Bottom toolbar: Media picker, Reply permission & Character Counter wheel
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    width: 0.8,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.image_outlined,
                      color: AppColors.primary,
                    ),
                    tooltip: 'Add images',
                    onPressed: controller.pickImages,
                  ),
                  IconButton(
                    icon: const Icon(Icons.tag, color: AppColors.primary),
                    tooltip: 'Add hashtag',
                    onPressed: () {
                      controller.textController.text += ' #';
                      controller.textController.selection =
                          TextSelection.fromPosition(
                            TextPosition(
                              offset: controller.textController.text.length,
                            ),
                          );
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.alternate_email,
                      color: AppColors.primary,
                    ),
                    tooltip: 'Mention user',
                    onPressed: () {
                      controller.textController.text += ' @';
                      controller.textController.selection =
                          TextSelection.fromPosition(
                            TextPosition(
                              offset: controller.textController.text.length,
                            ),
                          );
                    },
                  ),
                  const Spacer(),
                  // Character Count Circular Progress Indicator
                  Obx(() {
                    final remaining = controller.remainingChars.value;
                    final progress =
                        (AppConstants.maxPostLength - remaining) /
                        AppConstants.maxPostLength;
                    final isOver = remaining < 0;
                    final isClose = remaining <= 20;

                    Color indicatorColor = AppColors.primary;
                    if (isOver) {
                      indicatorColor = AppColors.error;
                    } else if (isClose) {
                      indicatorColor = AppColors.warning;
                    }

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isClose)
                          Text(
                            '$remaining',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: indicatorColor,
                            ),
                          ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            strokeWidth: 2.5,
                            backgroundColor: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                            color: indicatorColor,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
