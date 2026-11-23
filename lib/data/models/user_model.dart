import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String handle;
  final String? avatarUrl;
  final String? bannerUrl;
  final String bio;
  final String? website;
  final String? location;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool emailVerified;
  final bool isPrivate;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final bool isVerified;
  final bool isMuted;
  final bool isBlocked;
  final bool isFollowing;
  final String? followUri; // AT-URI of follow record

  const UserModel({
    required this.id,
    this.email = '',
    required this.displayName,
    required this.handle,
    this.avatarUrl,
    this.bannerUrl,
    this.bio = '',
    this.website,
    this.location,
    required this.createdAt,
    this.updatedAt,
    this.emailVerified = false,
    this.isPrivate = false,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.isVerified = false,
    this.isMuted = false,
    this.isBlocked = false,
    this.isFollowing = false,
    this.followUri,
  });

  // Aliases for Firebase & AT Protocol standard schema compliance
  String get uid => id;
  String get did => id;
  String get username => handle;
  String? get photoURL => avatarUrl;
  String get fullHandle => handle.startsWith('@') ? handle : '@$handle';

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? handle,
    String? avatarUrl,
    String? bannerUrl,
    String? bio,
    String? website,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? emailVerified,
    bool? isPrivate,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    bool? isVerified,
    bool? isMuted,
    bool? isBlocked,
    bool? isFollowing,
    String? followUri,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      handle: handle ?? this.handle,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      emailVerified: emailVerified ?? this.emailVerified,
      isPrivate: isPrivate ?? this.isPrivate,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      isVerified: isVerified ?? this.isVerified,
      isMuted: isMuted ?? this.isMuted,
      isBlocked: isBlocked ?? this.isBlocked,
      isFollowing: isFollowing ?? this.isFollowing,
      followUri: followUri ?? this.followUri,
    );
  }

  /// Parses real Bluesky XRPC Profile JSON (profileViewDetailed or profileView)
  factory UserModel.fromAtproto(Map<String, dynamic> json) {
    final viewer = json['viewer'] as Map<String, dynamic>? ?? {};
    final isFollowing = viewer['following'] != null;
    final followUri = viewer['following'] as String?;
    final isBlocked = viewer['blocking'] != null || viewer['blockedBy'] == true;
    final isMuted = viewer['muted'] == true;

    final createdAtStr = json['createdAt'] as String?;
    final createdAt = createdAtStr != null
        ? DateTime.tryParse(createdAtStr) ?? DateTime.now()
        : DateTime.now();

    final handle = json['handle'] ?? 'user';
    final displayName = (json['displayName'] as String?)?.isNotEmpty == true
        ? json['displayName']
        : handle;

    return UserModel(
      id: json['did'] ?? '',
      email: '',
      displayName: displayName,
      handle: handle,
      avatarUrl: json['avatar'],
      bannerUrl: json['banner'],
      bio: json['description'] ?? '',
      createdAt: createdAt,
      followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
      followingCount: (json['followsCount'] as num?)?.toInt() ?? 0,
      postsCount: (json['postsCount'] as num?)?.toInt() ?? 0,
      isVerified: (json['labels'] as List?)?.isNotEmpty == true,
      isFollowing: isFollowing,
      followUri: followUri,
      isMuted: isMuted,
      isBlocked: isBlocked,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'id': id,
      'email': email,
      'displayName': displayName,
      'username': handle,
      'handle': handle,
      'photoURL': avatarUrl,
      'avatarUrl': avatarUrl,
      'bannerUrl': bannerUrl,
      'bio': bio,
      'website': website,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      'emailVerified': emailVerified,
      'isPrivate': isPrivate,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'isVerified': isVerified,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
      if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
      return DateTime.now();
    }

    final id = docId ?? map['uid'] ?? map['id'] ?? '';
    final handle = map['username'] ?? map['handle'] ?? 'user';
    final avatarUrl = map['photoURL'] ?? map['avatarUrl'];

    return UserModel(
      id: id,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? 'User',
      handle: handle,
      avatarUrl: avatarUrl,
      bannerUrl: map['bannerUrl'],
      bio: map['bio'] ?? '',
      website: map['website'],
      location: map['location'],
      createdAt: parseDate(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? parseDate(map['updatedAt']) : null,
      emailVerified: map['emailVerified'] ?? false,
      isPrivate: map['isPrivate'] ?? false,
      followersCount: (map['followersCount'] as num?)?.toInt() ?? 0,
      followingCount: (map['followingCount'] as num?)?.toInt() ?? 0,
      postsCount: (map['postsCount'] as num?)?.toInt() ?? 0,
      isVerified: map['isVerified'] ?? false,
      isMuted: map['isMuted'] ?? false,
      isBlocked: map['isBlocked'] ?? false,
      isFollowing: map['isFollowing'] ?? false,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromMap(data, docId: doc.id);
  }
}
