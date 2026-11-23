import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluesky_app/app/routes/app_routes.dart';
import 'package:bluesky_app/core/constants/app_colors.dart';
import 'package:bluesky_app/core/utils/date_formatter.dart';
import 'package:bluesky_app/core/widgets/aura_avatar.dart';
import 'package:bluesky_app/core/widgets/aura_button.dart';
import 'package:bluesky_app/features/profile/controllers/profile_controller.dart';
import 'package:bluesky_app/features/timeline/widgets/post_card.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value && controller.user.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final user = controller.user.value;
        if (user == null) {
          return const Center(child: Text('User not found'));
        }

        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              backgroundColor: isDark
                  ? AppColors.darkBackground
                  : AppColors.lightBackground,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    // Cover Banner Image
                    user.bannerUrl != null
                        ? CachedNetworkImage(
                            imageUrl: user.bannerUrl!,
                            width: double.infinity,
                            height: 140,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 140,
                            decoration: const BoxDecoration(
                              gradient: AppColors.brandGradient,
                            ),
                          ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overlapping Avatar & Action Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -32),
                          child: AuraAvatar(
                            imageUrl: user.avatarUrl,
                            fallbackName: user.displayName,
                            size: 80,
                            hasBorder: true,
                            borderColor: isDark
                                ? AppColors.darkBackground
                                : Colors.white,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: controller.isOwnProfile.value
                              ? AuraButton(
                                  text: 'Edit Profile',
                                  variant: AuraButtonVariant.outline,
                                  isCompact: true,
                                  onPressed: () =>
                                      Get.toNamed(AppRoutes.editProfile),
                                )
                              : AuraButton(
                                  text: user.isFollowing
                                      ? 'Following'
                                      : 'Follow',
                                  variant: user.isFollowing
                                      ? AuraButtonVariant.outline
                                      : AuraButtonVariant.primary,
                                  isCompact: true,
                                  onPressed: controller.toggleFollow,
                                ),
                        ),
                      ],
                    ),

                    // Display Name & Handle
                    Row(
                      children: [
                        Text(
                          user.displayName,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        if (user.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 18,
                            color: AppColors.verifiedBadge,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.fullHandle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextSecondary,
                      ),
                    ),

                    // Bio
                    if (user.bio.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        user.bio,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],

                    // Meta Row: Location & Join Date
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (user.location != null) ...[
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: AppColors.lightTextTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user.location!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.lightTextTertiary,
                            ),
                          ),
                          const SizedBox(width: 14),
                        ],
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: AppColors.lightTextTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.formatJoinDate(user.createdAt),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.lightTextTertiary,
                          ),
                        ),
                      ],
                    ),

                    // Follower & Following Counts
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Get.toNamed(
                            AppRoutes.followers,
                            arguments: {'type': 'followers'},
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${user.followersCount} ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              const Text(
                                'followers',
                                style: TextStyle(
                                  color: AppColors.lightTextTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => Get.toNamed(
                            AppRoutes.followers,
                            arguments: {'type': 'following'},
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${user.followingCount} ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              const Text(
                                'following',
                                style: TextStyle(
                                  color: AppColors.lightTextTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarHeaderDelegate(
                TabBar(
                  controller: controller.tabController,
                  indicatorColor: AppColors.primary,
                  labelColor: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  unselectedLabelColor: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextSecondary,
                  tabs: const [
                    Tab(text: 'Posts'),
                    Tab(text: 'Replies'),
                    Tab(text: 'Media'),
                    Tab(text: 'Likes'),
                  ],
                ),
                isDark,
              ),
            ),
          ],
          body: TabBarView(
            controller: controller.tabController,
            children: [
              _buildFeedList(controller.userPosts, 'No posts yet'),
              _buildFeedList(controller.userReplies, 'No replies yet'),
              _buildFeedList(controller.userMedia, 'No media shared yet'),
              _buildFeedList(controller.userLikes, 'No liked posts yet'),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFeedList(RxList posts, String emptyMessage) {
    return Obx(() {
      if (posts.isEmpty) {
        return Center(
          child: Text(
            emptyMessage,
            style: const TextStyle(
              color: AppColors.lightTextTertiary,
              fontSize: 15,
            ),
          ),
        );
      }

      return ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostCard(post: post);
        },
      );
    });
  }
}

class _TabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final bool isDark;

  _TabBarHeaderDelegate(this.tabBar, this.isDark);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarHeaderDelegate oldDelegate) => false;
}
