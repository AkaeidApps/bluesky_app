import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluesky_app/app/routes/app_routes.dart';
import 'package:bluesky_app/core/constants/app_colors.dart';
import 'package:bluesky_app/core/constants/app_radius.dart';
import 'package:bluesky_app/core/widgets/aura_avatar.dart';
import 'package:bluesky_app/core/widgets/aura_button.dart';
import 'package:bluesky_app/features/search/controllers/search_controller.dart';
import 'package:bluesky_app/features/timeline/widgets/post_card.dart';

class SearchView extends GetView<AuraSearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: AppRadius.radiusFull,
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.8,
            ),
          ),
          child: TextField(
            controller: controller.searchFieldController,
            onChanged: controller.onQueryChanged,
            decoration: InputDecoration(
              hintText: 'Search users, posts, or tags',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: controller.searchFieldController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        controller.searchFieldController.clear();
                        controller.onQueryChanged('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.searchFieldController.text.trim().isNotEmpty) {
          return _buildSearchResults(context, isDark);
        }
        return _buildDiscoverLanding(context, isDark);
      }),
    );
  }

  Widget _buildDiscoverLanding(BuildContext context, bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      children: [
        // Trending Topics Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Trending on Aura',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...controller.trendingTopics.map((topic) {
          return InkWell(
            onTap: () {
              controller.searchFieldController.text = topic['tag'];
              controller.executeSearch(topic['tag']);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${topic['tag']}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${topic['postsCount']} posts',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.trending_up_rounded,
                    size: 18,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                ],
              ),
            ),
          );
        }),

        Divider(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          height: 32,
        ),

        // Suggested Accounts Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Suggested Accounts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...controller.suggestedUsers.map((user) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: Row(
              children: [
                AuraAvatar(
                  imageUrl: user.avatarUrl,
                  fallbackName: user.displayName,
                  size: 44,
                  onTap: () =>
                      Get.toNamed(AppRoutes.profile, arguments: user.id),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        Get.toNamed(AppRoutes.profile, arguments: user.id),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user.displayName,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            if (user.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                size: 14,
                                color: AppColors.verifiedBadge,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          '@${user.handle}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AuraButton(
                  text: user.isFollowing ? 'Following' : 'Follow',
                  isCompact: true,
                  variant: user.isFollowing
                      ? AuraButtonVariant.outline
                      : AuraButtonVariant.primary,
                  onPressed: () => controller.toggleFollow(user),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSearchResults(BuildContext context, bool isDark) {
    if (controller.isSearching.value) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            indicatorColor: AppColors.primary,
            labelColor: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
            unselectedLabelColor: isDark
                ? AppColors.darkTextTertiary
                : AppColors.lightTextSecondary,
            tabs: const [
              Tab(text: 'People'),
              Tab(text: 'Posts'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // People results
                controller.searchResultsUsers.isEmpty
                    ? const Center(child: Text('No users found'))
                    : ListView.builder(
                        itemCount: controller.searchResultsUsers.length,
                        itemBuilder: (context, index) {
                          final user = controller.searchResultsUsers[index];
                          return ListTile(
                            leading: AuraAvatar(
                              imageUrl: user.avatarUrl,
                              fallbackName: user.displayName,
                            ),
                            title: Text(
                              user.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text('@${user.handle}'),
                            onTap: () => Get.toNamed(
                              AppRoutes.profile,
                              arguments: user.id,
                            ),
                          );
                        },
                      ),
                // Posts results
                controller.searchResultsPosts.isEmpty
                    ? const Center(child: Text('No posts found'))
                    : ListView.builder(
                        itemCount: controller.searchResultsPosts.length,
                        itemBuilder: (context, index) {
                          final post = controller.searchResultsPosts[index];
                          return PostCard(post: post);
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
