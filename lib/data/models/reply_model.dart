import 'package:cloud_firestore/cloud_firestore.dart';

import 'post_model.dart';

class ReplyModel {
  final String id;
  final String postId;
  final String? parentReplyId;
  final String authorId;
  final String authorDisplayName;
  final String authorHandle;
  final String? authorAvatarUrl;
  final bool authorIsVerified;
  final String content;
  final List<String> mediaUrls;
  final DateTime createdAt;
  final int likesCount;
  final bool isLiked;
  final List<PostFacet> facets;

  const ReplyModel({
    required this.id,
    required this.postId,
    this.parentReplyId,
    required this.authorId,
    required this.authorDisplayName,
    required this.authorHandle,
    this.authorAvatarUrl,
    this.authorIsVerified = false,
    required this.content,
    this.mediaUrls = const [],
    required this.createdAt,
    this.likesCount = 0,
    this.isLiked = false,
    this.facets = const [],
  });

  ReplyModel copyWith({
    String? id,
    String? postId,
    String? parentReplyId,
    String? authorId,
    String? authorDisplayName,
    String? authorHandle,
    String? authorAvatarUrl,
    bool? authorIsVerified,
    String? content,
    List<String>? mediaUrls,
    DateTime? createdAt,
    int? likesCount,
    bool? isLiked,
    List<PostFacet>? facets,
  }) {
    return ReplyModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      parentReplyId: parentReplyId ?? this.parentReplyId,
      authorId: authorId ?? this.authorId,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      authorHandle: authorHandle ?? this.authorHandle,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      authorIsVerified: authorIsVerified ?? this.authorIsVerified,
      content: content ?? this.content,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      facets: facets ?? this.facets,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'postId': postId,
    'parentReplyId': parentReplyId,
    'authorId': authorId,
    'authorDisplayName': authorDisplayName,
    'authorHandle': authorHandle,
    'authorAvatarUrl': authorAvatarUrl,
    'authorIsVerified': authorIsVerified,
    'content': content,
    'mediaUrls': mediaUrls,
    'createdAt': Timestamp.fromDate(createdAt),
    'likesCount': likesCount,
    'facets': facets.map((f) => f.toMap()).toList(),
  };

  factory ReplyModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
      return DateTime.now();
    }

    return ReplyModel(
      id: docId ?? map['id'] ?? '',
      postId: map['postId'] ?? '',
      parentReplyId: map['parentReplyId'],
      authorId: map['authorId'] ?? '',
      authorDisplayName: map['authorDisplayName'] ?? 'User',
      authorHandle: map['authorHandle'] ?? 'user',
      authorAvatarUrl: map['authorAvatarUrl'],
      authorIsVerified: map['authorIsVerified'] ?? false,
      content: map['content'] ?? '',
      mediaUrls: List<String>.from(map['mediaUrls'] ?? []),
      createdAt: parseDate(map['createdAt']),
      likesCount: (map['likesCount'] as num?)?.toInt() ?? 0,
      isLiked: map['isLiked'] ?? false,
      facets:
          (map['facets'] as List<dynamic>?)
              ?.map((f) => PostFacet.fromMap(Map<String, dynamic>.from(f)))
              .toList() ??
          [],
    );
  }

  factory ReplyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ReplyModel.fromMap(data, docId: doc.id);
  }
}
