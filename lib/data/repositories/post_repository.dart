import 'package:bluesky_app/core/network/atproto_api_service.dart';
import 'package:bluesky_app/core/network/api_config.dart';
import 'package:bluesky_app/data/models/post_model.dart';
import 'package:bluesky_app/data/models/reply_model.dart';
import 'package:bluesky_app/data/providers/mock_data_provider.dart';
import 'dart:convert';

class PostRepository {
  final AtprotoApiService _apiService;

  PostRepository({AtprotoApiService? apiService})
      : _apiService = apiService ?? AtprotoApiService();

  Future<List<PostModel>> getPosts({
    String? feedType,
    String? cursor,
    int limit = 20,
  }) async {
    try {
      switch (feedType) {
        case 'following':
          return await _apiService.getTimeline(limit: limit, cursor: cursor);
        case 'discover':
          return await _apiService.getFeed(
            feedUri: ApiConfig.discoverFeedUri,
            limit: limit,
            cursor: cursor,
          );
        default:
          if (feedType != null && feedType.startsWith('at://')) {
            return await _apiService.getFeed(
              feedUri: feedType,
              limit: limit,
              cursor: cursor,
            );
          }
          return await _apiService.getTimeline(limit: limit, cursor: cursor);
      }
    } catch (e) {
      if (e.toString().contains('401') || e.toString().contains('unauthorized')) {
        return List.from(MockDataProvider.samplePosts);
      }
      rethrow;
    }
  }

  Future<PostModel> createPost(PostModel post) async {
    final facets = post.facets.map((f) => jsonEncode(f.toMap())).toList();

    List<Map<String, dynamic>>? embedImages;
    if (post.mediaUrls.isNotEmpty) {
      embedImages = [];
      for (int i = 0; i < post.mediaUrls.length; i++) {
        final mediaUrl = post.mediaUrls[i];
        if (mediaUrl.startsWith('http')) {
          embedImages.add({
            'image': {'ref': {'\$link': mediaUrl}},
            'alt': post.altTexts.length > i ? post.altTexts[i] : '',
            'aspectRatio': {'width': 16, 'height': 9},
          });
        }
      }
    }

    final result = await _apiService.createPost(
      text: post.content,
      facets: facets.isNotEmpty ? facets : null,
      embedImages: embedImages,
      replyPermission: post.replyPermission,
      lang: post.language,
    );

    final uri = result['uri'] as String;
    final cid = result['cid'] as String;

    return post.copyWith(
      id: uri,
      uri: uri,
      cid: cid,
    );
  }

  Future<void> likePost(String postId, String userId) async {
    final uri = postId.startsWith('at://') ? postId : 'at://$postId';
    final parts = uri.split('/');
    final cid = parts.last;
    await _apiService.likePost(postUri: uri, postCid: cid);
  }

  Future<void> unlikePost(String postId, String userId) async {
    final likeUri = postId;
    await _apiService.unlikePost(likeUri: likeUri);
  }

  Future<void> repost(String postId, String userId) async {
    final uri = postId.startsWith('at://') ? postId : 'at://$postId';
    final parts = uri.split('/');
    final cid = parts.last;
    await _apiService.repostPost(postUri: uri, postCid: cid);
  }

  Future<void> undoRepost(String postId, String userId) async {
    final repostUri = postId;
    await _apiService.undoRepost(repostUri: repostUri);
  }

  Future<void> bookmarkPost(String postId, String userId) async {
  }

  Future<void> unbookmarkPost(String postId, String userId) async {
  }

  Future<List<ReplyModel>> getReplies(String postId) async {
    try {
      final thread = await _apiService.getPostThread(uri: postId, depth: 6);
      final replies = <ReplyModel>[];

      void extractReplies(PostModel post, int depth) {
        if (depth <= 0) return;
        if (post.quotePost != null) {
          extractReplies(post.quotePost!, depth - 1);
        }
      }

      extractReplies(thread, 6);
      return replies;
    } catch (e) {
      return [
        ReplyModel(
          id: 'reply_1',
          postId: postId,
          authorId: 'user_1',
          authorDisplayName: 'Maya Lin',
          authorHandle: 'mayalin.aura.social',
          authorAvatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
          authorIsVerified: true,
          content: 'Excited to see the architecture coming together cleanly! Great work on the design tokens.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
          likesCount: 12,
        ),
        ReplyModel(
          id: 'reply_2',
          postId: postId,
          authorId: 'user_2',
          authorDisplayName: 'Alex Rivera',
          authorHandle: 'alex.aura.social',
          authorAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
          authorIsVerified: true,
          content: 'The custom butterfly vector mark is super clean. Looking forward to testing on device.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          likesCount: 8,
        ),
      ];
    }
  }

  Future<ReplyModel> createReply(String postId, ReplyModel reply) async {
    final parentUri = postId;
    final parentParts = parentUri.split('/');
    final parentCid = parentParts.last;

    final rootUri = parentUri;
    final rootCid = parentCid;

    final facets = reply.facets.map((f) => jsonEncode(f.toMap())).toList();

    List<Map<String, dynamic>>? embedImages;
    if (reply.mediaUrls.isNotEmpty) {
      embedImages = [];
      for (int i = 0; i < reply.mediaUrls.length; i++) {
        final mediaUrl = reply.mediaUrls[i];
        if (mediaUrl.startsWith('http')) {
          embedImages.add({
            'image': {'ref': {'\$link': mediaUrl}},
            'alt': '',
            'aspectRatio': {'width': 16, 'height': 9},
          });
        }
      }
    }

    await _apiService.createReply(
      parentUri: parentUri,
      parentCid: parentCid,
      rootUri: rootUri,
      rootCid: rootCid,
      text: reply.content,
      facets: facets.isNotEmpty ? facets : null,
      embedImages: embedImages,
    );

    return reply;
  }
}