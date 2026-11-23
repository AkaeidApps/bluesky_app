import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bluesky_app/core/media/media_resolver.dart';

enum ReplyPermission { everyone, following, mentioned, nobody }

class PostFacet {
  final String type; // 'mention', 'tag', 'link'
  final String value;
  final int start;
  final int end;

  const PostFacet({
    required this.type,
    required this.value,
    required this.start,
    required this.end,
  });

  Map<String, dynamic> toMap() => {
        'type': type,
        'value': value,
        'start': start,
        'end': end,
      };

  factory PostFacet.fromMap(Map<String, dynamic> map) => PostFacet(
        type: map['type'] ?? '',
        value: map['value'] ?? '',
        start: (map['start'] as num?)?.toInt() ?? 0,
        end: (map['end'] as num?)?.toInt() ?? 0,
      );

  factory PostFacet.fromAtproto(Map<String, dynamic> json) {
    int start = 0;
    int end = 0;
    if (json['index'] is Map) {
      start = (json['index']['byteStart'] as num?)?.toInt() ?? 0;
      end = (json['index']['byteEnd'] as num?)?.toInt() ?? 0;
    }

    String type = 'link';
    String value = '';
    final features = json['features'] as List<dynamic>? ?? [];
    if (features.isNotEmpty) {
      final feature = features.first as Map<String, dynamic>;
      final fType = feature[r'$type'] as String? ?? '';
      if (fType.contains('mention')) {
        type = 'mention';
        value = feature['did'] ?? '';
      } else if (fType.contains('tag')) {
        type = 'tag';
        value = feature['tag'] ?? '';
      } else if (fType.contains('link')) {
        type = 'link';
        value = feature['uri'] ?? '';
      }
    }

    return PostFacet(type: type, value: value, start: start, end: end);
  }
}

class PostModel {
  final String id; // Post AT-URI or Firestore ID
  final String uri;
  final String cid;
  final String authorId; // DID
  final String authorDisplayName;
  final String authorHandle;
  final String? authorAvatarUrl;
  final bool authorIsVerified;
  final String content;
  final List<String> mediaUrls;
  final List<String> mediaTypes;
  final List<String> altTexts;
  final DateTime createdAt;
  final int likesCount;
  final int repostsCount;
  final int repliesCount;
  final int quotesCount;
  final bool isLiked;
  final String? likeUri; // Needed to delete like record
  final bool isReposted;
  final String? repostUri; // Needed to delete repost record
  final bool isBookmarked;
  final String? replyToPostId;
  final String? replyToAuthorHandle;
  final PostModel? quotePost;
  final List<String> contentLabels;
  final List<PostFacet> facets;
  final ReplyPermission replyPermission;
  final String language;

  const PostModel({
    required this.id,
    this.uri = '',
    this.cid = '',
    required this.authorId,
    required this.authorDisplayName,
    required this.authorHandle,
    this.authorAvatarUrl,
    this.authorIsVerified = false,
    required this.content,
    this.mediaUrls = const [],
    this.mediaTypes = const [],
    this.altTexts = const [],
    required this.createdAt,
    this.likesCount = 0,
    this.repostsCount = 0,
    this.repliesCount = 0,
    this.quotesCount = 0,
    this.isLiked = false,
    this.likeUri,
    this.isReposted = false,
    this.repostUri,
    this.isBookmarked = false,
    this.replyToPostId,
    this.replyToAuthorHandle,
    this.quotePost,
    this.contentLabels = const [],
    this.facets = const [],
    this.replyPermission = ReplyPermission.everyone,
    this.language = 'en',
  });

  PostModel copyWith({
    String? id,
    String? uri,
    String? cid,
    String? authorId,
    String? authorDisplayName,
    String? authorHandle,
    String? authorAvatarUrl,
    bool? authorIsVerified,
    String? content,
    List<String>? mediaUrls,
    List<String>? mediaTypes,
    List<String>? altTexts,
    DateTime? createdAt,
    int? likesCount,
    int? repostsCount,
    int? repliesCount,
    int? quotesCount,
    bool? isLiked,
    String? likeUri,
    bool? isReposted,
    String? repostUri,
    bool? isBookmarked,
    String? replyToPostId,
    String? replyToAuthorHandle,
    PostModel? quotePost,
    List<String>? contentLabels,
    List<PostFacet>? facets,
    ReplyPermission? replyPermission,
    String? language,
  }) {
    return PostModel(
      id: id ?? this.id,
      uri: uri ?? this.uri,
      cid: cid ?? this.cid,
      authorId: authorId ?? this.authorId,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      authorHandle: authorHandle ?? this.authorHandle,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      authorIsVerified: authorIsVerified ?? this.authorIsVerified,
      content: content ?? this.content,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      mediaTypes: mediaTypes ?? this.mediaTypes,
      altTexts: altTexts ?? this.altTexts,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      repostsCount: repostsCount ?? this.repostsCount,
      repliesCount: repliesCount ?? this.repliesCount,
      quotesCount: quotesCount ?? this.quotesCount,
      isLiked: isLiked ?? this.isLiked,
      likeUri: likeUri ?? this.likeUri,
      isReposted: isReposted ?? this.isReposted,
      repostUri: repostUri ?? this.repostUri,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      replyToPostId: replyToPostId ?? this.replyToPostId,
      replyToAuthorHandle: replyToAuthorHandle ?? this.replyToAuthorHandle,
      quotePost: quotePost ?? this.quotePost,
      contentLabels: contentLabels ?? this.contentLabels,
      facets: facets ?? this.facets,
      replyPermission: replyPermission ?? this.replyPermission,
      language: language ?? this.language,
    );
  }

  /// Parses official Bluesky AT Protocol XRPC JSON (feedViewPost or postView)
  factory PostModel.fromAtproto(Map<String, dynamic> json) {
    // If wrapping feedViewPost, unpack 'post'
    final post = (json.containsKey('post') && json['post'] is Map)
        ? Map<String, dynamic>.from(json['post'])
        : json;

    final author = post['author'] as Map<String, dynamic>? ?? {};
    final record = post['record'] as Map<String, dynamic>? ?? {};
    final viewer = post['viewer'] as Map<String, dynamic>? ?? {};
    final embed = post['embed'];

    // Parse embeds
    final mediaItems = MediaResolver.parseEmbedImages(embed);
    final video = MediaResolver.parseVideo(embed);

    // Extract quote post if embedded
    PostModel? quotePost;
    if (embed is Map && embed[r'$type'] == 'app.bsky.embed.record#view') {
      final rec = embed['record'];
      if (rec is Map && rec[r'$type'] == 'app.bsky.embed.record#viewRecord') {
        quotePost = PostModel.fromAtproto(Map<String, dynamic>.from(rec));
      }
    }

    // Extract facets
    final rawFacets = record['facets'] as List<dynamic>? ?? [];
    final facets = rawFacets.map((f) => PostFacet.fromAtproto(Map<String, dynamic>.from(f))).toList();

    // Parse created date
    final createdAtStr = record['createdAt'] ?? post['indexedAt'];
    final createdAt = createdAtStr != null
        ? DateTime.tryParse(createdAtStr) ?? DateTime.now()
        : DateTime.now();

    // Parse viewer interaction state
    final isLiked = viewer['like'] != null;
    final likeUri = viewer['like'] as String?;
    final isReposted = viewer['repost'] != null;
    final repostUri = viewer['repost'] as String?;

    final uri = post['uri'] ?? '';
    final cid = post['cid'] ?? '';

    return PostModel(
      id: uri.isNotEmpty ? uri : (post['cid'] ?? ''),
      uri: uri,
      cid: cid,
      authorId: author['did'] ?? '',
      authorDisplayName: (author['displayName'] as String?)?.isNotEmpty == true
          ? author['displayName']
          : (author['handle'] ?? 'User'),
      authorHandle: author['handle'] ?? 'user',
      authorAvatarUrl: author['avatar'],
      authorIsVerified: author['verification'] != null || (author['labels'] as List?)?.isNotEmpty == true,
      content: record['text'] ?? '',
      mediaUrls: mediaItems.map((m) => m.thumbUrl).toList(),
      mediaTypes: mediaItems.isNotEmpty ? List.filled(mediaItems.length, 'image') : (video != null ? ['video'] : []),
      altTexts: mediaItems.map((m) => m.altText).toList(),
      createdAt: createdAt,
      likesCount: (post['likeCount'] as num?)?.toInt() ?? 0,
      repostsCount: (post['repostCount'] as num?)?.toInt() ?? 0,
      repliesCount: (post['replyCount'] as num?)?.toInt() ?? 0,
      quotesCount: (post['quoteCount'] as num?)?.toInt() ?? 0,
      isLiked: isLiked,
      likeUri: likeUri,
      isReposted: isReposted,
      repostUri: repostUri,
      quotePost: quotePost,
      facets: facets,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uri': uri,
      'cid': cid,
      'authorId': authorId,
      'authorDisplayName': authorDisplayName,
      'authorHandle': authorHandle,
      'authorAvatarUrl': authorAvatarUrl,
      'authorIsVerified': authorIsVerified,
      'content': content,
      'mediaUrls': mediaUrls,
      'mediaTypes': mediaTypes,
      'altTexts': altTexts,
      'createdAt': Timestamp.fromDate(createdAt),
      'likesCount': likesCount,
      'repostsCount': repostsCount,
      'repliesCount': repliesCount,
      'quotesCount': quotesCount,
      'replyToPostId': replyToPostId,
      'replyToAuthorHandle': replyToAuthorHandle,
      'quotePost': quotePost?.toMap(),
      'contentLabels': contentLabels,
      'facets': facets.map((f) => f.toMap()).toList(),
      'replyPermission': replyPermission.name,
      'language': language,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
      if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
      return DateTime.now();
    }

    return PostModel(
      id: docId ?? map['id'] ?? '',
      uri: map['uri'] ?? '',
      cid: map['cid'] ?? '',
      authorId: map['authorId'] ?? '',
      authorDisplayName: map['authorDisplayName'] ?? 'User',
      authorHandle: map['authorHandle'] ?? 'user',
      authorAvatarUrl: map['authorAvatarUrl'],
      authorIsVerified: map['authorIsVerified'] ?? false,
      content: map['content'] ?? '',
      mediaUrls: List<String>.from(map['mediaUrls'] ?? []),
      mediaTypes: List<String>.from(map['mediaTypes'] ?? []),
      altTexts: List<String>.from(map['altTexts'] ?? []),
      createdAt: parseDate(map['createdAt']),
      likesCount: (map['likesCount'] as num?)?.toInt() ?? 0,
      repostsCount: (map['repostsCount'] as num?)?.toInt() ?? 0,
      repliesCount: (map['repliesCount'] as num?)?.toInt() ?? 0,
      quotesCount: (map['quotesCount'] as num?)?.toInt() ?? 0,
      isLiked: map['isLiked'] ?? false,
      likeUri: map['likeUri'],
      isReposted: map['isReposted'] ?? false,
      repostUri: map['repostUri'],
      isBookmarked: map['isBookmarked'] ?? false,
      replyToPostId: map['replyToPostId'],
      replyToAuthorHandle: map['replyToAuthorHandle'],
      quotePost: map['quotePost'] != null
          ? PostModel.fromMap(Map<String, dynamic>.from(map['quotePost']))
          : null,
      contentLabels: List<String>.from(map['contentLabels'] ?? []),
      facets: (map['facets'] as List<dynamic>?)
              ?.map((f) => PostFacet.fromMap(Map<String, dynamic>.from(f)))
              .toList() ??
          [],
      replyPermission: ReplyPermission.values.firstWhere(
        (e) => e.name == map['replyPermission'],
        orElse: () => ReplyPermission.everyone,
      ),
      language: map['language'] ?? 'en',
    );
  }

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PostModel.fromMap(data, docId: doc.id);
  }
}
