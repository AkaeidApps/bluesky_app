import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluesky_app/core/constants/app_colors.dart';
import 'package:bluesky_app/data/models/post_model.dart';
import 'package:bluesky_app/data/models/feed_model.dart';
import 'package:bluesky_app/data/repositories/feed_repository.dart';
import 'package:bluesky_app/data/repositories/post_repository.dart';
import 'package:bluesky_app/data/repositories/auth_repository.dart';

class TimelineController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final PostRepository _postRepo = Get.find<PostRepository>();
  final FeedRepository _feedRepo = Get.find<FeedRepository>();
  final AuthRepository _authRepo = Get.find<AuthRepository>();

  late TabController tabController;
  final followingPosts = <PostModel>[].obs;
  final discoverPosts = <PostModel>[].obs;
  final feeds = <FeedModel>[].obs;

  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final hasNewPosts = false.obs;
  final activeFeedIndex = 0.obs;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      activeFeedIndex.value = tabController.index;
    });

    loadInitialData();
  }

  Future<void> loadInitialData() async {
    try {
      isLoading.value = true;
      final fetchedFeeds = await _feedRepo.getFeeds();
      feeds.assignAll(fetchedFeeds);

      await Future.wait([fetchFollowingPosts(), fetchDiscoverPosts()]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFollowingPosts() async {
    final posts = await _postRepo.getPosts(feedType: 'following');
    followingPosts.assignAll(posts);
  }

  Future<void> fetchDiscoverPosts() async {
    final posts = await _postRepo.getPosts(feedType: 'discover');
    discoverPosts.assignAll(posts);
  }

  Future<void> refreshFeed() async {
    try {
      isRefreshing.value = true;
      if (tabController.index == 0) {
        await fetchFollowingPosts();
      } else {
        await fetchDiscoverPosts();
      }
      hasNewPosts.value = false;
    } finally {
      isRefreshing.value = false;
    }
  }

  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    hasNewPosts.value = false;
  }

  // Social Interactions with Optimistic UI Updates
  Future<void> toggleLike(PostModel post) async {
    final currentUserId = _authRepo.currentFirebaseUser?.uid ?? 'user_current';
    final isLiked = post.isLiked;
    final updated = post.copyWith(
      isLiked: !isLiked,
      likesCount: isLiked ? post.likesCount - 1 : post.likesCount + 1,
    );

    _updatePostInLists(updated);

    try {
      if (isLiked) {
        await _postRepo.unlikePost(post.id, currentUserId);
      } else {
        await _postRepo.likePost(post.id, currentUserId);
      }
    } catch (e) {
      // Revert on error
      _updatePostInLists(post);
      Get.snackbar('Error', 'Failed to update like');
    }
  }

  Future<void> toggleRepost(PostModel post) async {
    final currentUserId = _authRepo.currentFirebaseUser?.uid ?? 'user_current';
    final isReposted = post.isReposted;
    final updated = post.copyWith(
      isReposted: !isReposted,
      repostsCount: isReposted ? post.repostsCount - 1 : post.repostsCount + 1,
    );

    _updatePostInLists(updated);

    try {
      if (isReposted) {
        await _postRepo.undoRepost(post.id, currentUserId);
      } else {
        await _postRepo.repost(post.id, currentUserId);
      }
    } catch (e) {
      _updatePostInLists(post);
      Get.snackbar('Error', 'Failed to update repost');
    }
  }

  Future<void> toggleBookmark(PostModel post) async {
    final currentUserId = _authRepo.currentFirebaseUser?.uid ?? 'user_current';
    final isBookmarked = post.isBookmarked;
    final updated = post.copyWith(isBookmarked: !isBookmarked);

    _updatePostInLists(updated);

    try {
      if (isBookmarked) {
        await _postRepo.unbookmarkPost(post.id, currentUserId);
        Get.snackbar(
          'Removed',
          'Post removed from bookmarks',
          duration: const Duration(seconds: 1),
        );
      } else {
        await _postRepo.bookmarkPost(post.id, currentUserId);
        Get.snackbar(
          'Saved',
          'Post added to bookmarks',
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      _updatePostInLists(post);
    }
  }

  void showMoreOptions(PostModel post) {
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
                leading: const Icon(Icons.link),
                title: const Text('Copy link to post'),
                onTap: () {
                  Get.back();
                  Get.snackbar('Copied', 'Link copied to clipboard');
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('Share post via...'),
                onTap: () => Get.back(),
              ),
              ListTile(
                leading: const Icon(
                  Icons.flag_outlined,
                  color: AppColors.error,
                ),
                title: const Text(
                  'Report post',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Get.back();
                  _showReportDialog(post);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDialog(PostModel post) {
    Get.defaultDialog(
      title: 'Report Post',
      middleText: 'Help us understand what is wrong with this post.',
      textConfirm: 'Report',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () {
        Get.back();
        Get.snackbar('Thank you', 'Your report has been submitted for review.');
      },
    );
  }

  void _updatePostInLists(PostModel post) {
    final followingIdx = followingPosts.indexWhere((p) => p.id == post.id);
    if (followingIdx != -1) {
      followingPosts[followingIdx] = post;
    }

    final discoverIdx = discoverPosts.indexWhere((p) => p.id == post.id);
    if (discoverIdx != -1) {
      discoverPosts[discoverIdx] = post;
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
