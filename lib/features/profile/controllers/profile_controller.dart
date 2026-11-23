import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluesky_app/data/models/post_model.dart';
import 'package:bluesky_app/data/models/user_model.dart';
import 'package:bluesky_app/data/providers/mock_data_provider.dart';
import 'package:bluesky_app/data/repositories/auth_repository.dart';
import 'package:bluesky_app/data/repositories/post_repository.dart';
import 'package:bluesky_app/data/repositories/user_repository.dart';

class ProfileController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final UserRepository _userRepo = Get.find<UserRepository>();
  final PostRepository _postRepo = Get.find<PostRepository>();
  final AuthRepository _authRepo = Get.find<AuthRepository>();

  late TabController tabController;
  final user = Rxn<UserModel>();
  final isOwnProfile = true.obs;
  final isLoading = false.obs;

  final userPosts = <PostModel>[].obs;
  final userReplies = <PostModel>[].obs;
  final userMedia = <PostModel>[].obs;
  final userLikes = <PostModel>[].obs;

  // Edit Profile form controllers
  final editDisplayNameController = TextEditingController();
  final editBioController = TextEditingController();
  final editWebsiteController = TextEditingController();
  final editLocationController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    final targetUid = Get.arguments as String?;
    loadProfile(targetUid);
  }

  Future<void> loadProfile(String? targetUid) async {
    isLoading.value = true;
    try {
      final currentUid = _authRepo.currentFirebaseUser?.uid ?? 'user_current';
      final uid = targetUid ?? currentUid;
      isOwnProfile.value = (uid == currentUid);

      final fetchedUser = await _userRepo.getUser(uid);
      user.value = fetchedUser ?? MockDataProvider.currentUser;

      editDisplayNameController.text = user.value?.displayName ?? '';
      editBioController.text = user.value?.bio ?? '';
      editWebsiteController.text = user.value?.website ?? '';
      editLocationController.text = user.value?.location ?? '';

      // Load user posts
      final allPosts = await _postRepo.getPosts();
      userPosts.assignAll(allPosts.where((p) => p.authorId == uid).toList());
      userMedia.assignAll(
        allPosts
            .where((p) => p.authorId == uid && p.mediaUrls.isNotEmpty)
            .toList(),
      );
      userLikes.assignAll(allPosts.where((p) => p.isLiked).toList());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFollow() async {
    if (user.value == null) return;
    final u = user.value!;
    final updated = u.copyWith(
      isFollowing: !u.isFollowing,
      followersCount: u.isFollowing
          ? u.followersCount - 1
          : u.followersCount + 1,
    );
    user.value = updated;

    if (u.isFollowing) {
      await _userRepo.unfollowUser(currentUid: 'user_current', targetUid: u.id);
    } else {
      await _userRepo.followUser(currentUid: 'user_current', targetUid: u.id);
    }
  }

  Future<void> saveProfile() async {
    if (user.value == null) return;
    final updated = user.value!.copyWith(
      displayName: editDisplayNameController.text.trim(),
      bio: editBioController.text.trim(),
      website: editWebsiteController.text.trim(),
      location: editLocationController.text.trim(),
    );
    user.value = updated;
    await _userRepo.updateUserProfile(updated);
    Get.back();
    Get.snackbar('Profile Updated', 'Your profile details have been saved.');
  }

  @override
  void onClose() {
    tabController.dispose();
    editDisplayNameController.dispose();
    editBioController.dispose();
    editWebsiteController.dispose();
    editLocationController.dispose();
    super.onClose();
  }
}
