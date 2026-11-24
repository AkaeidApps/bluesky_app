import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluesky_app/core/constants/app_colors.dart';
import 'package:bluesky_app/data/models/post_model.dart';
import 'package:bluesky_app/data/models/reply_model.dart';
import 'package:bluesky_app/data/repositories/post_repository.dart';

class PostDetailsController extends GetxController {
  final PostRepository _postRepo = Get.find<PostRepository>();

  final Rxn<PostModel> post = Rxn<PostModel>();
  final replies = <ReplyModel>[].obs;
  final isLoading = false.obs;
  final isLoadingReplies = false.obs;

  @override
  void onInit() {
    super.onInit();
    final postArg = Get.arguments as PostModel?;
    if (postArg != null) {
      post.value = postArg;
      loadPostThread();
      loadReplies();
    }
  }

  Future<void> loadPostThread() async {
    if (post.value == null) return;
    try {
      isLoading.value = true;
      final thread = await _postRepo.getPosts(feedType: post.value!.uri);
      if (thread.isNotEmpty) {
        post.value = thread.first;
      }
    } catch (e) {
      // Ignore error, keep original post
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadReplies() async {
    if (post.value == null) return;
    try {
      isLoadingReplies.value = true;
      final replyModels = await _postRepo.getReplies(post.value!.id);
      replies.assignAll(replyModels);
    } catch (e) {
      // Ignore error
    } finally {
      isLoadingReplies.value = false;
    }
  }

  Future<void> toggleLike() async {
    final currentPost = post.value;
    if (currentPost == null) return;

    final currentUserId = 'user_current';
    final isLiked = currentPost.isLiked;
    final updated = currentPost.copyWith(
      isLiked: !isLiked,
      likesCount: isLiked ? currentPost.likesCount - 1 : currentPost.likesCount + 1,
    );

    post.value = updated;

    try {
      if (isLiked) {
        await _postRepo.unlikePost(currentPost.id, currentUserId);
      } else {
        await _postRepo.likePost(currentPost.id, currentUserId);
      }
    } catch (e) {
      post.value = currentPost;
      Get.snackbar('Error', 'Failed to update like');
    }
  }

  Future<void> toggleRepost() async {
    final currentPost = post.value;
    if (currentPost == null) return;

    final currentUserId = 'user_current';
    final isReposted = currentPost.isReposted;
    final updated = currentPost.copyWith(
      isReposted: !isReposted,
      repostsCount: isReposted ? currentPost.repostsCount - 1 : currentPost.repostsCount + 1,
    );

    post.value = updated;

    try {
      if (isReposted) {
        await _postRepo.undoRepost(currentPost.id, currentUserId);
      } else {
        await _postRepo.repost(currentPost.id, currentUserId);
      }
    } catch (e) {
      post.value = currentPost;
      Get.snackbar('Error', 'Failed to update repost');
    }
  }

  Future<void> toggleBookmark() async {
    final currentPost = post.value;
    if (currentPost == null) return;

    final currentUserId = 'user_current';
    final isBookmarked = currentPost.isBookmarked;
    final updated = currentPost.copyWith(isBookmarked: !isBookmarked);

    post.value = updated;

    try {
      if (isBookmarked) {
        await _postRepo.unbookmarkPost(currentPost.id, currentUserId);
        Get.snackbar('Removed', 'Post removed from bookmarks', duration: const Duration(seconds: 1));
      } else {
        await _postRepo.bookmarkPost(currentPost.id, currentUserId);
        Get.snackbar('Saved', 'Post added to bookmarks', duration: const Duration(seconds: 1));
      }
    } catch (e) {
      post.value = currentPost;
    }
  }

  void showMoreOptions() {
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
                leading: const Icon(Icons.flag_outlined, color: AppColors.error),
                title: const Text('Report post', style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Get.back();
                  _showReportDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDialog() {
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
}