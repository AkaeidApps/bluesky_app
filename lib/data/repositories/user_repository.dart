import 'package:bluesky_app/core/network/atproto_api_service.dart';
import 'package:bluesky_app/data/models/user_model.dart';
import 'package:bluesky_app/data/providers/mock_data_provider.dart';

class UserRepository {
  final AtprotoApiService _apiService;

  UserRepository({AtprotoApiService? apiService})
      : _apiService = apiService ?? AtprotoApiService();

  Future<UserModel?> getUser(String uid) async {
    try {
      return await _apiService.getProfile(actor: uid);
    } catch (e) {
      if (uid == MockDataProvider.currentUser.id) {
        return MockDataProvider.currentUser;
      }
      return MockDataProvider.sampleUsers.firstWhere(
        (u) => u.id == uid,
        orElse: () => MockDataProvider.currentUser,
      );
    }
  }

  Future<void> updateUserProfile(UserModel user) async {
  }

  Future<void> followUser({
    required String currentUid,
    required String targetUid,
  }) async {
    await _apiService.followUser(targetDid: targetUid);
  }

  Future<void> unfollowUser({
    required String currentUid,
    required String targetUid,
  }) async {
  }

  Future<void> blockUser({
    required String currentUid,
    required String targetUid,
  }) async {
  }

  Future<void> muteUser({
    required String currentUid,
    required String targetUid,
  }) async {
  }

  Future<List<UserModel>> searchUsers(String query) async {
    try {
      return await _apiService.searchActors(q: query, limit: 20);
    } catch (e) {
      final clean = query.trim().toLowerCase();
      if (clean.isEmpty) return [];
      return MockDataProvider.sampleUsers
          .where(
            (u) =>
                u.displayName.toLowerCase().contains(clean) ||
                u.handle.toLowerCase().contains(clean),
          )
          .toList();
    }
  }

  Future<List<UserModel>> getFollowers({
    required String actor,
    int limit = 50,
    String? cursor,
  }) async {
    try {
      return await _apiService.getFollowers(actor: actor, limit: limit, cursor: cursor);
    } catch (e) {
      return [];
    }
  }

  Future<List<UserModel>> getFollows({
    required String actor,
    int limit = 50,
    String? cursor,
  }) async {
    try {
      return await _apiService.getFollows(actor: actor, limit: limit, cursor: cursor);
    } catch (e) {
      return [];
    }
  }

  Future<List<UserModel>> getSuggestions({
    int limit = 10,
    String? cursor,
  }) async {
    try {
      return await _apiService.getSuggestions(limit: limit, cursor: cursor);
    } catch (e) {
      return MockDataProvider.sampleUsers.take(limit).toList();
    }
  }
}