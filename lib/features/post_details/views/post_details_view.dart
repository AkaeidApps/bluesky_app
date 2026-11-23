import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluesky_app/core/constants/app_colors.dart';
import 'package:bluesky_app/core/utils/date_formatter.dart';
import 'package:bluesky_app/core/widgets/aura_avatar.dart';
import 'package:bluesky_app/core/widgets/media_grid.dart';
import 'package:bluesky_app/core/widgets/rich_post_text.dart';
import 'package:bluesky_app/data/models/post_model.dart';
import 'package:bluesky_app/data/models/reply_model.dart';
import 'package:bluesky_app/data/repositories/post_repository.dart';

class PostDetailsController extends GetxController {
  final PostRepository _postRepo = Get.find<PostRepository>();

  final Rxn<PostModel> post = Rxn<PostModel>();
  final replies = <ReplyModel>[].obs;
  final isLoadingReplies = false.obs;
  final replyTextController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is PostModel) {
      post.value = args;
      loadReplies(args.id);
    }
  }

  Future<void> loadReplies(String postId) async {
    try {
      isLoadingReplies.value = true;
      final fetched = await _postRepo.getReplies(postId);
      replies.assignAll(fetched);
    } finally {
      isLoadingReplies.value = false;
    }
  }

  Future<void> sendInlineReply() async {
    final text = replyTextController.text.trim();
    if (text.isEmpty || post.value == null) return;

    final newReply = ReplyModel(
      id: '',
      postId: post.value!.id,
      authorId: 'user_current',
      authorDisplayName: 'Aura Explorer',
      authorHandle: 'explorer.aura.social',
      authorIsVerified: true,
      content: text,
      createdAt: DateTime.now(),
    );

    replyTextController.clear();
    replies.add(newReply);
    await _postRepo.createReply(post.value!.id, newReply);
  }

  @override
  void onClose() {
    replyTextController.dispose();
    super.onClose();
  }
}

class PostDetailsView extends GetView<PostDetailsController> {
  const PostDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Post',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final currentPost = controller.post.value;
        if (currentPost == null) {
          return const Center(child: Text('Post not found'));
        }

        return Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  // Full Post Detail Card
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Author Header
                        Row(
                          children: [
                            AuraAvatar(
                              imageUrl: currentPost.authorAvatarUrl,
                              fallbackName: currentPost.authorDisplayName,
                              size: 48,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      currentPost.authorDisplayName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    if (currentPost.authorIsVerified) ...[
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
                                  '@${currentPost.authorHandle}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? AppColors.darkTextTertiary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Post Content
                        RichPostText(
                          text: currentPost.content,
                          facets: currentPost.facets,
                          style: TextStyle(
                            fontSize: 18,
                            height: 1.4,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),

                        // Media Grid
                        if (currentPost.mediaUrls.isNotEmpty)
                          MediaGrid(
                            mediaUrls: currentPost.mediaUrls,
                            altTexts: currentPost.altTexts,
                          ),

                        const SizedBox(height: 12),
                        // Detail Timestamp
                        Text(
                          DateFormatter.formatDetail(currentPost.createdAt),
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Divider(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),

                        // Metrics Count Row (Reposts, Quotes, Likes)
                        Row(
                          children: [
                            _buildMetric(
                              currentPost.repostsCount,
                              'Reposts',
                              isDark,
                            ),
                            const SizedBox(width: 18),
                            _buildMetric(
                              currentPost.quotesCount,
                              'Quotes',
                              isDark,
                            ),
                            const SizedBox(width: 18),
                            _buildMetric(
                              currentPost.likesCount,
                              'Likes',
                              isDark,
                            ),
                          ],
                        ),
                        Divider(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ],
                    ),
                  ),

                  // Replies Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      'Replies',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),

                  // Nested Replies List
                  Obx(() {
                    if (controller.isLoadingReplies.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }

                    if (controller.replies.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            'No replies yet. Be the first to reply!',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.lightTextTertiary,
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.replies.length,
                      itemBuilder: (context, index) {
                        final reply = controller.replies[index];
                        return _buildReplyItem(context, reply, isDark);
                      },
                    );
                  }),
                ],
              ),
            ),

            // Inline Reply Composer Bar at bottom
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
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.replyTextController,
                        decoration: InputDecoration(
                          hintText: 'Write a reply...',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: AppColors.primary,
                      ),
                      onPressed: controller.sendInlineReply,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMetric(int count, String label, bool isDark) {
    return Row(
      children: [
        Text(
          '$count ',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.darkTextTertiary
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildReplyItem(BuildContext context, ReplyModel reply, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            width: 0.8,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuraAvatar(
            imageUrl: reply.authorAvatarUrl,
            fallbackName: reply.authorDisplayName,
            size: 38,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      reply.authorDisplayName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    if (reply.authorIsVerified) ...[
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.verified,
                        size: 14,
                        color: AppColors.verifiedBadge,
                      ),
                    ],
                    const SizedBox(width: 6),
                    Text(
                      '@${reply.authorHandle}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '· ${DateFormatter.formatRelative(reply.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  reply.content,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
