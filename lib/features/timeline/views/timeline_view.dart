import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluesky_app/app/routes/app_routes.dart';
import 'package:bluesky_app/core/constants/app_colors.dart';
import 'package:bluesky_app/core/constants/app_radius.dart';
import 'package:bluesky_app/core/widgets/aura_app_bar.dart';
import 'package:bluesky_app/core/widgets/aura_brand_mark.dart';
import 'package:bluesky_app/features/timeline/controllers/timeline_controller.dart';
import 'package:bluesky_app/features/timeline/widgets/post_card.dart';

class TimelineView extends GetView<TimelineController> {
  const TimelineView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AuraAppBar(
        titleWidget: const AuraBrandMark(size: 32),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Feeds & Settings',
            onPressed: () => Get.toNamed(AppRoutes.feeds),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 0.8,
                ),
              ),
            ),
            child: TabBar(
              controller: controller.tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              unselectedLabelColor: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextSecondary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              tabs: const [
                Tab(text: 'Following'),
                Tab(text: 'Discover'),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: controller.tabController,
            children: [
              _buildPostsList(context, controller.followingPosts),
              _buildPostsList(context, controller.discoverPosts),
            ],
          ),
          // New Posts Floating Banner (Bluesky style)
          Obx(
            () => controller.hasNewPosts.value
                ? Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: controller.scrollToTop,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: AppRadius.radiusFull,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_upward,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'New posts',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList(BuildContext context, RxList posts) {
    return Obx(() {
      if (controller.isLoading.value && posts.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2.5,
          ),
        );
      }

      if (posts.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.refreshFeed,
          color: AppColors.primary,
          child: ListView(
            children: const [
              SizedBox(height: 120),
              Center(
                child: Column(
                  children: [
                    AuraBrandMark(size: 48),
                    SizedBox(height: 16),
                    Text(
                      'No posts in this feed yet',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Follow accounts or explore trending feeds to see posts.',
                      style: TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshFeed,
        color: AppColors.primary,
        child: ListView.builder(
          controller: controller.scrollController,
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return PostCard(
              post: post,
              onTap: () => Get.toNamed(AppRoutes.postDetails, arguments: post),
              onLike: () => controller.toggleLike(post),
              onRepost: () => controller.toggleRepost(post),
              onReply: () =>
                  Get.toNamed(AppRoutes.composer, arguments: {'replyTo': post}),
              onBookmark: () => controller.toggleBookmark(post),
              onShare: () => controller.showMoreOptions(post),
              onMore: () => controller.showMoreOptions(post),
              onProfileTap: () =>
                  Get.toNamed(AppRoutes.profile, arguments: post.authorId),
            );
          },
        ),
      );
    });
  }
}
