import 'package:dio/dio.dart';
import 'package:bluesky_app/core/network/dio_client.dart';
import 'package:bluesky_app/core/network/api_config.dart';
import 'package:bluesky_app/core/auth/secure_token_storage.dart';
import 'package:bluesky_app/data/models/post_model.dart';
import 'package:bluesky_app/data/models/user_model.dart';
import 'package:bluesky_app/data/models/feed_model.dart';
import 'package:bluesky_app/data/models/notification_model.dart';
import 'package:bluesky_app/data/models/chat_model.dart';
import 'package:bluesky_app/data/models/reply_model.dart';

class AtprotoApiService {
  final DioClient _dioClient;
  final SecureTokenStorage _tokenStorage;

  AtprotoApiService({
    DioClient? dioClient,
    SecureTokenStorage? tokenStorage,
  })  : _dioClient = dioClient ?? DioClient(storage: tokenStorage),
        _tokenStorage = tokenStorage ?? SecureTokenStorage();

  Dio get dio => _dioClient.dio;

  Future<String?> _getAccessToken() => _tokenStorage.getAccessJwt();
  Future<String?> _getPdsUrl() => _tokenStorage.getPdsUrl();
  Future<String?> _getDid() => _tokenStorage.getDid();

  Future<bool> hasValidSession() async {
    final token = await _getAccessToken();
    final did = await _getDid();
    return token != null && token.isNotEmpty && did != null && did.isNotEmpty;
  }

  Future<Map<String, dynamic>> createSession({
    required String identifier,
    required String password,
  }) async {
    final response = await dio.post(
      ApiConfig.createSession,
      data: {
        'identifier': identifier,
        'password': password,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> refreshSession() async {
    final refreshJwt = await _tokenStorage.getRefreshJwt();
    final pdsUrl = await _tokenStorage.getPdsUrl() ?? ApiConfig.defaultPds;

    if (refreshJwt == null || refreshJwt.isEmpty) {
      throw Exception('No refresh token available');
    }

    final refreshDio = Dio(BaseOptions(baseUrl: pdsUrl));
    final response = await refreshDio.post(
      ApiConfig.refreshSession,
      options: Options(headers: {'Authorization': 'Bearer $refreshJwt'}),
    );
    return response.data;
  }

  Future<void> deleteSession() async {
    await dio.post(ApiConfig.deleteSession);
    await _tokenStorage.clearSession();
  }

  Future<UserModel> getProfile({required String actor}) async {
    final response = await dio.get(
      ApiConfig.getProfile,
      queryParameters: {'actor': actor},
    );
    return UserModel.fromAtproto(response.data);
  }

  Future<Map<String, dynamic>> getProfiles(List<String> actors) async {
    final response = await dio.get(
      ApiConfig.getProfiles,
      queryParameters: {'actors': actors.join(',')},
    );
    return response.data;
  }

  Future<List<PostModel>> getTimeline({
    int limit = 50,
    String? cursor,
  }) async {
    final response = await dio.get(
      ApiConfig.getTimeline,
      queryParameters: {
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );

    final feed = response.data['feed'] as List<dynamic>? ?? [];
    return feed
        .map((item) => PostModel.fromAtproto(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<PostModel>> getAuthorFeed({
    required String actor,
    int limit = 50,
    String? cursor,
    bool filter = false,
  }) async {
    final response = await dio.get(
      ApiConfig.getAuthorFeed,
      queryParameters: {
        'actor': actor,
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
        'filter': filter ? 'posts_with_replies' : 'posts_no_replies',
      },
    );

    final feed = response.data['feed'] as List<dynamic>? ?? [];
    return feed
        .map((item) => PostModel.fromAtproto(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<PostModel>> getFeed({
    required String feedUri,
    int limit = 50,
    String? cursor,
  }) async {
    final response = await dio.get(
      ApiConfig.getFeed,
      queryParameters: {
        'feed': feedUri,
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );

    final feed = response.data['feed'] as List<dynamic>? ?? [];
    return feed
        .map((item) => PostModel.fromAtproto(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<PostModel> getPostThread({required String uri, int depth = 6}) async {
    final response = await dio.get(
      ApiConfig.getPostThread,
      queryParameters: {'uri': uri, 'depth': depth},
    );
    return PostModel.fromAtproto(response.data['thread']);
  }

  Future<List<PostModel>> getPosts(List<String> uris) async {
    final response = await dio.get(
      ApiConfig.getPosts,
      queryParameters: {'uris': uris.join(',')},
    );

    final posts = response.data['posts'] as List<dynamic>? ?? [];
    return posts
        .map((item) => PostModel.fromAtproto(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<PostModel>> searchPosts({
    required String q,
    int limit = 25,
    String? cursor,
    String? sort,
    String? since,
    String? until,
    String? lang,
  }) async {
    final response = await dio.get(
      ApiConfig.searchPosts,
      queryParameters: {
        'q': q,
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
        if (sort != null) 'sort': sort,
        if (since != null) 'since': since,
        if (until != null) 'until': until,
        if (lang != null) 'lang': lang,
      },
    );

    final posts = response.data['posts'] as List<dynamic>? ?? [];
    return posts
        .map((item) => PostModel.fromAtproto(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<Map<String, dynamic>> createRecord({
    required String collection,
    required Map<String, dynamic> record,
    String? repo,
    String? rkey,
  }) async {
    final did = await _getDid();
    final response = await dio.post(
      ApiConfig.createRecord,
      data: {
        'repo': repo ?? did,
        'collection': collection,
        'record': record,
        if (rkey != null) 'rkey': rkey,
      },
    );
    return response.data;
  }

  Future<void> deleteRecord({
    required String collection,
    required String rkey,
    String? repo,
  }) async {
    final did = await _getDid();
    await dio.post(
      ApiConfig.deleteRecord,
      data: {
        'repo': repo ?? did,
        'collection': collection,
        'rkey': rkey,
      },
    );
  }

  Future<Map<String, dynamic>> uploadBlob(List<int> bytes, String contentType) async {
    final response = await dio.post(
      ApiConfig.uploadBlob,
      data: bytes,
      options: Options(
        headers: {'Content-Type': contentType},
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> likePost({
    required String postUri,
    required String postCid,
  }) async {
    final did = await _getDid();
    final record = {
      '\$type': 'app.bsky.feed.like',
      'subject': {'uri': postUri, 'cid': postCid},
      'createdAt': DateTime.now().toIso8601String(),
    };
    return createRecord(collection: ApiConfig.collectionLike, record: record);
  }

  Future<void> unlikePost({required String likeUri}) async {
    final parts = likeUri.split('/');
    final rkey = parts.last;
    await deleteRecord(collection: ApiConfig.collectionLike, rkey: rkey);
  }

  Future<Map<String, dynamic>> repostPost({
    required String postUri,
    required String postCid,
  }) async {
    final did = await _getDid();
    final record = {
      '\$type': 'app.bsky.feed.repost',
      'subject': {'uri': postUri, 'cid': postCid},
      'createdAt': DateTime.now().toIso8601String(),
    };
    return createRecord(collection: ApiConfig.collectionRepost, record: record);
  }

  Future<void> undoRepost({required String repostUri}) async {
    final parts = repostUri.split('/');
    final rkey = parts.last;
    await deleteRecord(collection: ApiConfig.collectionRepost, rkey: rkey);
  }

  Future<Map<String, dynamic>> createPost({
    required String text,
    List<String>? facets,
    List<Map<String, dynamic>>? embedImages,
    Map<String, dynamic>? embedExternal,
    Map<String, dynamic>? embedRecord,
    ReplyPermission replyPermission = ReplyPermission.everyone,
    String lang = 'en',
  }) async {
    final did = await _getDid();
    final record = <String, dynamic>{
      '\$type': 'app.bsky.feed.post',
      'text': text,
      'createdAt': DateTime.now().toIso8601String(),
      'langs': [lang],
      'replySettings': replyPermission.name,
    };

    if (facets != null && facets.isNotEmpty) {
      record['facets'] = facets;
    }

    if (embedImages != null && embedImages.isNotEmpty) {
      record['embed'] = {
        '\$type': 'app.bsky.embed.images',
        'images': embedImages,
      };
    } else if (embedExternal != null) {
      record['embed'] = {
        '\$type': 'app.bsky.embed.external',
        'external': embedExternal,
      };
    } else if (embedRecord != null) {
      record['embed'] = {
        '\$type': 'app.bsky.embed.record',
        'record': embedRecord,
      };
    }

    return createRecord(
      collection: ApiConfig.collectionPost,
      record: record,
      repo: did,
    );
  }

  Future<Map<String, dynamic>> createReply({
    required String parentUri,
    required String parentCid,
    required String rootUri,
    required String rootCid,
    required String text,
    List<String>? facets,
    List<Map<String, dynamic>>? embedImages,
  }) async {
    final did = await _getDid();
    final record = <String, dynamic>{
      '\$type': 'app.bsky.feed.post',
      'text': text,
      'createdAt': DateTime.now().toIso8601String(),
      'reply': {
        'parent': {'uri': parentUri, 'cid': parentCid},
        'root': {'uri': rootUri, 'cid': rootCid},
      },
      'langs': ['en'],
    };

    if (facets != null && facets.isNotEmpty) {
      record['facets'] = facets;
    }

    if (embedImages != null && embedImages.isNotEmpty) {
      record['embed'] = {
        '\$type': 'app.bsky.embed.images',
        'images': embedImages,
      };
    }

    return createRecord(
      collection: ApiConfig.collectionPost,
      record: record,
      repo: did,
    );
  }

  Future<Map<String, dynamic>> followUser({
    required String targetDid,
  }) async {
    final did = await _getDid();
    final record = {
      '\$type': 'app.bsky.graph.follow',
      'subject': targetDid,
      'createdAt': DateTime.now().toIso8601String(),
    };
    return createRecord(
      collection: ApiConfig.collectionFollow,
      record: record,
      repo: did,
    );
  }

  Future<void> unfollowUser({required String followUri}) async {
    final parts = followUri.split('/');
    final rkey = parts.last;
    await deleteRecord(collection: ApiConfig.collectionFollow, rkey: rkey);
  }

  Future<List<UserModel>> getFollowers({
    required String actor,
    int limit = 50,
    String? cursor,
  }) async {
    final response = await dio.get(
      ApiConfig.getFollowers,
      queryParameters: {
        'actor': actor,
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );

    final followers = response.data['followers'] as List<dynamic>? ?? [];
    return followers
        .map((item) => UserModel.fromAtproto(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<UserModel>> getFollows({
    required String actor,
    int limit = 50,
    String? cursor,
  }) async {
    final response = await dio.get(
      ApiConfig.getFollows,
      queryParameters: {
        'actor': actor,
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );

    final follows = response.data['follows'] as List<dynamic>? ?? [];
    return follows
        .map((item) => UserModel.fromAtproto(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<UserModel>> searchActors({
    required String q,
    int limit = 25,
    String? cursor,
  }) async {
    final response = await dio.get(
      ApiConfig.searchActors,
      queryParameters: {
        'q': q,
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );

    final actors = response.data['actors'] as List<dynamic>? ?? [];
    return actors
        .map((item) => UserModel.fromAtproto(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<UserModel>> getSuggestions({
    int limit = 10,
    String? cursor,
  }) async {
    final response = await dio.get(
      ApiConfig.getSuggestions,
      queryParameters: {
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );

    final actors = response.data['actors'] as List<dynamic>? ?? [];
    return actors
        .map((item) => UserModel.fromAtproto(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<NotificationModel>> listNotifications({
    int limit = 50,
    String? cursor,
    bool? seen,
  }) async {
    final response = await dio.get(
      ApiConfig.listNotifications,
      queryParameters: {
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
        if (seen != null) 'seen': seen.toString(),
      },
    );

    final notifications = response.data['notifications'] as List<dynamic>? ?? [];
    return notifications
        .map((item) => NotificationModel.fromAtproto(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<int> getUnreadCount({bool? seen}) async {
    final response = await dio.get(
      ApiConfig.getUnreadCount,
      queryParameters: {if (seen != null) 'seen': seen.toString()},
    );
    return (response.data['count'] as num?)?.toInt() ?? 0;
  }

  Future<void> updateSeen({required DateTime seenAt}) async {
    await dio.post(
      ApiConfig.updateSeen,
      data: {'seenAt': seenAt.toIso8601String()},
    );
  }

  Future<List<ConversationModel>> listConvos() async {
    final response = await dio.get(ApiConfig.listConvos);
    final convos = response.data['convos'] as List<dynamic>? ?? [];
    return convos
        .map((item) => ConversationModel.fromAtproto(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<ConversationModel> getConvo({required String convoId}) async {
    final response = await dio.get(
      ApiConfig.getConvo,
      queryParameters: {'convoId': convoId},
    );
    return ConversationModel.fromAtproto(response.data['convo']);
  }

  Future<List<ChatMessageModel>> getMessages({
    required String convoId,
    int limit = 50,
    String? cursor,
  }) async {
    final response = await dio.get(
      ApiConfig.getMessages,
      queryParameters: {
        'convoId': convoId,
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );

    final messages = response.data['messages'] as List<dynamic>? ?? [];
    return messages
        .map((item) => ChatMessageModel.fromAtproto(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<ChatMessageModel> sendMessage({
    required String convoId,
    required String text,
    String? replyTo,
  }) async {
    final response = await dio.post(
      ApiConfig.sendMessage,
      data: {
        'convoId': convoId,
        'message': {
          '\$type': 'chat.bsky.convo.defs#message',
          'text': text,
          'createdAt': DateTime.now().toIso8601String(),
          if (replyTo != null) 'replyTo': replyTo,
        },
      },
    );
    return ChatMessageModel.fromAtproto(response.data['message']);
  }

  Future<void> updateRead({required String convoId, required String messageId}) async {
    await dio.post(
      ApiConfig.updateRead,
      data: {'convoId': convoId, 'messageId': messageId},
    );
  }

  Future<String> resolveHandle({required String handle}) async {
    final response = await dio.get(
      ApiConfig.resolveHandle,
      queryParameters: {'handle': handle},
    );
    return response.data['did'] as String;
  }

  Future<List<FeedModel>> getSuggestedFeeds() async {
    final response = await dio.get(ApiConfig.getSuggestedFeeds);
    final feeds = response.data['feeds'] as List<dynamic>? ?? [];
    return feeds
        .map((item) => FeedModel.fromAtproto(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<FeedModel>> getFeedGenerators({
    String? actor,
  }) async {
    final response = await dio.get(
      ApiConfig.getFeedGenerators,
      queryParameters: {if (actor != null) 'actor': actor},
    );
    final feeds = response.data['feeds'] as List<dynamic>? ?? [];
    return feeds
        .map((item) => FeedModel.fromAtproto(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<Map<String, dynamic>> getLikes({
    required String uri,
    String? cursor,
    int limit = 50,
  }) async {
    final response = await dio.get(
      ApiConfig.getLikes,
      queryParameters: {
        'uri': uri,
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getRepostedBy({
    required String uri,
    String? cursor,
    int limit = 50,
  }) async {
    final response = await dio.get(
      ApiConfig.getRepostedBy,
      queryParameters: {
        'uri': uri,
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    return response.data;
  }
}