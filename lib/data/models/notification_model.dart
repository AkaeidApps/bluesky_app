import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  like,
  repost,
  reply,
  mention,
  follow,
  quote,
}

class NotificationModel {
  final String id;
  final String userId;
  final String senderId;
  final String senderDisplayName;
  final String senderHandle;
  final String? senderAvatarUrl;
  final NotificationType type;
  final String? postId;
  final String? postSnippet;
  final DateTime createdAt;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.senderId,
    required this.senderDisplayName,
    required this.senderHandle,
    this.senderAvatarUrl,
    required this.type,
    this.postId,
    this.postSnippet,
    required this.createdAt,
    this.isRead = false,
  });

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? senderId,
    String? senderDisplayName,
    String? senderHandle,
    String? senderAvatarUrl,
    NotificationType? type,
    String? postId,
    String? postSnippet,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      senderId: senderId ?? this.senderId,
      senderDisplayName: senderDisplayName ?? this.senderDisplayName,
      senderHandle: senderHandle ?? this.senderHandle,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      type: type ?? this.type,
      postId: postId ?? this.postId,
      postSnippet: postSnippet ?? this.postSnippet,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  /// Parses real Bluesky Notification View (app.bsky.notification.listNotifications)
  factory NotificationModel.fromAtproto(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>? ?? {};
    final reason = json['reason'] as String? ?? 'like';
    final isRead = json['isRead'] == true;

    NotificationType type;
    switch (reason) {
      case 'repost':
        type = NotificationType.repost;
        break;
      case 'reply':
        type = NotificationType.reply;
        break;
      case 'mention':
        type = NotificationType.mention;
        break;
      case 'follow':
        type = NotificationType.follow;
        break;
      case 'quote':
        type = NotificationType.quote;
        break;
      case 'like':
      default:
        type = NotificationType.like;
        break;
    }

    final indexedAtStr = json['indexedAt'] as String?;
    final createdAt = indexedAtStr != null
        ? DateTime.tryParse(indexedAtStr) ?? DateTime.now()
        : DateTime.now();

    final record = json['record'] as Map<String, dynamic>? ?? {};
    final postSnippet = record['text'] as String?;

    return NotificationModel(
      id: json['uri'] ?? json['cid'] ?? '',
      userId: '',
      senderId: author['did'] ?? '',
      senderDisplayName: (author['displayName'] as String?)?.isNotEmpty == true
          ? author['displayName']
          : (author['handle'] ?? 'User'),
      senderHandle: author['handle'] ?? 'user',
      senderAvatarUrl: author['avatar'],
      type: type,
      postId: json['reasonSubject'] ?? json['uri'],
      postSnippet: postSnippet,
      createdAt: createdAt,
      isRead: isRead,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'senderId': senderId,
      'senderDisplayName': senderDisplayName,
      'senderHandle': senderHandle,
      'senderAvatarUrl': senderAvatarUrl,
      'type': type.name,
      'postId': postId,
      'postSnippet': postSnippet,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
      return DateTime.now();
    }

    return NotificationModel(
      id: docId ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderDisplayName: map['senderDisplayName'] ?? '',
      senderHandle: map['senderHandle'] ?? '',
      senderAvatarUrl: map['senderAvatarUrl'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.like,
      ),
      postId: map['postId'],
      postSnippet: map['postSnippet'],
      createdAt: parseDate(map['createdAt']),
      isRead: map['isRead'] ?? false,
    );
  }

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return NotificationModel.fromMap(data, docId: doc.id);
  }
}
