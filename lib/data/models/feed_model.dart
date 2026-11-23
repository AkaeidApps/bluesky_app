import 'package:cloud_firestore/cloud_firestore.dart';

class FeedModel {
  final String id;
  final String uri;
  final String cid;
  final String name;
  final String description;
  final String? avatarUrl;
  final String creatorHandle;
  final String creatorDisplayName;
  final int likesCount;
  final bool isSaved;
  final bool isPinned;
  final String queryTag;

  const FeedModel({
    required this.id,
    this.uri = '',
    this.cid = '',
    required this.name,
    required this.description,
    this.avatarUrl,
    required this.creatorHandle,
    this.creatorDisplayName = '',
    this.likesCount = 0,
    this.isSaved = false,
    this.isPinned = false,
    required this.queryTag,
  });

  FeedModel copyWith({
    String? id,
    String? uri,
    String? cid,
    String? name,
    String? description,
    String? avatarUrl,
    String? creatorHandle,
    String? creatorDisplayName,
    int? likesCount,
    bool? isSaved,
    bool? isPinned,
    String? queryTag,
  }) {
    return FeedModel(
      id: id ?? this.id,
      uri: uri ?? this.uri,
      cid: cid ?? this.cid,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      creatorHandle: creatorHandle ?? this.creatorHandle,
      creatorDisplayName: creatorDisplayName ?? this.creatorDisplayName,
      likesCount: likesCount ?? this.likesCount,
      isSaved: isSaved ?? this.isSaved,
      isPinned: isPinned ?? this.isPinned,
      queryTag: queryTag ?? this.queryTag,
    );
  }

  /// Parses real Bluesky Feed Generator (app.bsky.feed.defs#generatorView)
  factory FeedModel.fromAtproto(Map<String, dynamic> json) {
    final creator = json['creator'] as Map<String, dynamic>? ?? {};
    final viewer = json['viewer'] as Map<String, dynamic>? ?? {};
    final uri = json['uri'] ?? '';

    return FeedModel(
      id: uri,
      uri: uri,
      cid: json['cid'] ?? '',
      name: json['displayName'] ?? 'Custom Feed',
      description: json['description'] ?? '',
      avatarUrl: json['avatar'],
      creatorHandle: creator['handle'] ?? 'creator.bsky.social',
      creatorDisplayName: creator['displayName'] ?? creator['handle'] ?? '',
      likesCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      isSaved: viewer['saved'] == true,
      isPinned: viewer['pinned'] == true,
      queryTag: uri,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'uri': uri,
        'cid': cid,
        'name': name,
        'description': description,
        'avatarUrl': avatarUrl,
        'creatorHandle': creatorHandle,
        'creatorDisplayName': creatorDisplayName,
        'likesCount': likesCount,
        'queryTag': queryTag,
      };

  factory FeedModel.fromMap(Map<String, dynamic> map, {String? docId}) => FeedModel(
        id: docId ?? map['id'] ?? '',
        uri: map['uri'] ?? '',
        cid: map['cid'] ?? '',
        name: map['name'] ?? '',
        description: map['description'] ?? '',
        avatarUrl: map['avatarUrl'],
        creatorHandle: map['creatorHandle'] ?? 'aura.official',
        creatorDisplayName: map['creatorDisplayName'] ?? 'Aura Team',
        likesCount: (map['likesCount'] as num?)?.toInt() ?? 0,
        isSaved: map['isSaved'] ?? false,
        isPinned: map['isPinned'] ?? false,
        queryTag: map['queryTag'] ?? 'all',
      );

  factory FeedModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return FeedModel.fromMap(data, docId: doc.id);
  }
}
