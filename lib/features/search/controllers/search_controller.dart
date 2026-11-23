import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluesky_app/data/models/post_model.dart';
import 'package:bluesky_app/data/models/user_model.dart';
import 'package:bluesky_app/data/providers/mock_data_provider.dart';
import 'package:bluesky_app/data/repositories/post_repository.dart';
import 'package:bluesky_app/data/repositories/user_repository.dart';

class AuraSearchController extends GetxController {
  final UserRepository _userRepo = Get.find<UserRepository>();
  final PostRepository _postRepo = Get.find<PostRepository>();

  final searchFieldController = TextEditingController();
  final searchResultsUsers = <UserModel>[].obs;
  final searchResultsPosts = <PostModel>[].obs;
  final suggestedUsers = <UserModel>[].obs;
  final recentSearches = <String>[].obs;

  final isSearching = false.obs;
  final activeSearchTab = 0.obs; // 0: Top, 1: Users, 2: Posts
  Timer? _debounceTimer;

  final trendingTopics = <Map<String, dynamic>>[
    {'tag': 'Flutter', 'postsCount': '24.5k'},
    {'tag': 'Decentralized', 'postsCount': '18.2k'},
    {'tag': 'OpenSource', 'postsCount': '14.1k'},
    {'tag': 'Photography', 'postsCount': '9.8k'},
    {'tag': 'AIandDesign', 'postsCount': '8.4k'},
  ].obs;

  @override
  void onInit() {
    super.onInit();
    suggestedUsers.assignAll(MockDataProvider.sampleUsers);
    recentSearches.assignAll(['flutter', 'design', 'aura']);
  }

  void onQueryChanged(String query) {
    _debounceTimer?.cancel();
    final clean = query.trim();

    if (clean.isEmpty) {
      isSearching.value = false;
      searchResultsUsers.clear();
      searchResultsPosts.clear();
      return;
    }

    _debounceTimer = Timer(
      const Duration(milliseconds: 300),
      () => executeSearch(clean),
    );
  }

  Future<void> executeSearch(String query) async {
    isSearching.value = true;
    try {
      final users = await _userRepo.searchUsers(query);
      searchResultsUsers.assignAll(users);

      final allPosts = await _postRepo.getPosts();
      searchResultsPosts.assignAll(
        allPosts
            .where((p) => p.content.toLowerCase().contains(query.toLowerCase()))
            .toList(),
      );

      if (!recentSearches.contains(query)) {
        recentSearches.insert(0, query);
        if (recentSearches.length > 8) recentSearches.removeLast();
      }
    } finally {
      isSearching.value = false;
    }
  }

  void clearRecentSearches() {
    recentSearches.clear();
  }

  void toggleFollow(UserModel user) {
    final idx = suggestedUsers.indexWhere((u) => u.id == user.id);
    if (idx != -1) {
      final updated = user.copyWith(
        isFollowing: !user.isFollowing,
        followersCount: user.isFollowing
            ? user.followersCount - 1
            : user.followersCount + 1,
      );
      suggestedUsers[idx] = updated;
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchFieldController.dispose();
    super.onClose();
  }
}
