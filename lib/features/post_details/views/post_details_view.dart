import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluesky_app/app/routes/app_routes.dart';
import 'package:bluesky_app/core/constants/app_colors.dart';
import 'package:bluesky_app/core/widgets/aura_app_bar.dart';
import 'package:bluesky_app/data/models/post_model.dart';
import 'package:bluesky_app/features/post_details/controllers/post_details_controller.dart';
import 'package:bluesky_app/features/timeline/widgets/post_card.dart';

class PostDetailsView extends GetView<PostDetailsController> {
  const PostDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AuraAppBar(
        title: 'Post',
        actions: [
          Obx(() => controller.post.value != null
              ? IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: controller.showMoreOptions,
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.post.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final post = controller.post.value;
        if (post == null) {
          return const Center(child: Text('Post not found'));
        }

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.loadPostThread,
                color: AppColors.primary,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    PostCard(
                      post: post,
                      onLike: controller.toggleLike,
                      onRepost: controller.toggleRepost,
                      onReply: () => Get.toNamed(AppRoutes.composer, arguments: {'replyTo': post}),
                      onBookmark: controller.toggleBookmark,
                      onShare: controller.showMoreOptions,
                      onMore: controller.showMoreOptions,
                      onProfileTap: () => Get.toNamed(AppRoutes.profile, arguments: post.authorId),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Replies',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Obx(() {
              if (controller.isLoadingReplies.value && controller.replies.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
                );
              }

              if (controller.replies.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No replies yet',
                      style: TextStyle(color: AppColors.lightTextTertiary),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: controller.replies.length,
                  itemBuilder: (context, index) {
                    final reply = controller.replies[index];
                    final postModel = PostModel(
                      id: reply.id,
                      authorId: reply.authorId,
                      authorDisplayName: reply.authorDisplayName,
                      authorHandle: reply.authorHandle,
                      authorAvatarUrl: reply.authorAvatarUrl,
                      authorIsVerified: reply.authorIsVerified,
                      content: reply.content,
                      mediaUrls: reply.mediaUrls,
                      createdAt: reply.createdAt,
                      likesCount: reply.likesCount,
                      isLiked: reply.isLiked,
                      facets: reply.facets,
                    );
                    return PostCard(
                      post: postModel,
                      showThreadConnector: true,
                      onProfileTap: () => Get.toNamed(AppRoutes.profile, arguments: reply.authorId),
                    );
                  },
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}