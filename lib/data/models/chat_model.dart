import 'package:cloud_firestore/cloud_firestore.dart';

class ChatParticipant {
  final String id;
  final String displayName;
  final String handle;
  final String? avatarUrl;

  const ChatParticipant({
    required this.id,
    required this.displayName,
    required this.handle,
    this.avatarUrl,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'displayName': displayName,
        'handle': handle,
        'avatarUrl': avatarUrl,
      };

  factory ChatParticipant.fromMap(Map<String, dynamic> map) => ChatParticipant(
        id: map['id'] ?? '',
        displayName: map['displayName'] ?? '',
        handle: map['handle'] ?? '',
        avatarUrl: map['avatarUrl'],
      );

  factory ChatParticipant.fromAtproto(Map<String, dynamic> json) => ChatParticipant(
        id: json['did'] ?? '',
        displayName: (json['displayName'] as String?)?.isNotEmpty == true
            ? json['displayName']
            : (json['handle'] ?? 'User'),
        handle: json['handle'] ?? 'user',
        avatarUrl: json['avatar'],
      );
}

class ConversationModel {
  final String id;
  final List<String> participantIds;
  final Map<String, ChatParticipant> participants;
  final String lastMessageText;
  final String lastMessageSenderId;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isMuted;

  const ConversationModel({
    required this.id,
    required this.participantIds,
    required this.participants,
    required this.lastMessageText,
    required this.lastMessageSenderId,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isMuted = false,
  });

  ChatParticipant? getOtherParticipant(String currentUserId) {
    for (final entry in participants.entries) {
      if (entry.key != currentUserId) return entry.value;
    }
    return participants.values.isNotEmpty ? participants.values.first : null;
  }

  /// Parses real Bluesky Convo View (chat.bsky.convo.defs#convoView)
  factory ConversationModel.fromAtproto(Map<String, dynamic> json) {
    final rawMembers = json['members'] as List<dynamic>? ?? [];
    final participants = <String, ChatParticipant>{};
    final participantIds = <String>[];

    for (final member in rawMembers) {
      if (member is Map<String, dynamic>) {
        final p = ChatParticipant.fromAtproto(member);
        participants[p.id] = p;
        participantIds.add(p.id);
      }
    }

    String lastMsg = '';
    String lastSender = '';
    DateTime lastTime = DateTime.now();

    final lastMessage = json['lastMessage'];
    if (lastMessage is Map<String, dynamic>) {
      lastMsg = lastMessage['text'] ?? '';
      lastSender = lastMessage['sender']?['did'] ?? '';
      final sentAt = lastMessage['sentAt'] as String?;
      if (sentAt != null) {
        lastTime = DateTime.tryParse(sentAt) ?? DateTime.now();
      }
    }

    return ConversationModel(
      id: json['id'] ?? '',
      participantIds: participantIds,
      participants: participants,
      lastMessageText: lastMsg,
      lastMessageSenderId: lastSender,
      lastMessageTime: lastTime,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      isMuted: json['muted'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participantIds': participantIds,
      'participants': participants.map((k, v) => MapEntry(k, v.toMap())),
      'lastMessageText': lastMessageText,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'unreadCount': unreadCount,
      'isMuted': isMuted,
    };
  }

  factory ConversationModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
      return DateTime.now();
    }

    final rawParticipants = map['participants'] as Map<String, dynamic>? ?? {};
    final participants = rawParticipants.map(
      (k, v) => MapEntry(k, ChatParticipant.fromMap(Map<String, dynamic>.from(v))),
    );

    return ConversationModel(
      id: docId ?? map['id'] ?? '',
      participantIds: List<String>.from(map['participantIds'] ?? []),
      participants: participants,
      lastMessageText: map['lastMessageText'] ?? '',
      lastMessageSenderId: map['lastMessageSenderId'] ?? '',
      lastMessageTime: parseDate(map['lastMessageTime']),
      unreadCount: (map['unreadCount'] as num?)?.toInt() ?? 0,
      isMuted: map['isMuted'] ?? false,
    );
  }

  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ConversationModel.fromMap(data, docId: doc.id);
  }
}

class ChatMessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderHandle;
  final String text;
  final String? mediaUrl;
  final DateTime createdAt;
  final bool isRead;

  const ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderHandle,
    required this.text,
    this.mediaUrl,
    required this.createdAt,
    this.isRead = false,
  });

  /// Parses real Bluesky Message View (chat.bsky.convo.defs#messageView)
  factory ChatMessageModel.fromAtproto(Map<String, dynamic> json, String convoId) {
    final sender = json['sender'] as Map<String, dynamic>? ?? {};
    final sentAtStr = json['sentAt'] as String?;
    final sentAt = sentAtStr != null
        ? DateTime.tryParse(sentAtStr) ?? DateTime.now()
        : DateTime.now();

    return ChatMessageModel(
      id: json['id'] ?? '',
      conversationId: convoId,
      senderId: sender['did'] ?? '',
      senderHandle: sender['handle'] ?? 'user',
      text: json['text'] ?? '',
      createdAt: sentAt,
      isRead: true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderHandle': senderHandle,
      'text': text,
      'mediaUrl': mediaUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
      return DateTime.now();
    }

    return ChatMessageModel(
      id: docId ?? map['id'] ?? '',
      conversationId: map['conversationId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderHandle: map['senderHandle'] ?? '',
      text: map['text'] ?? '',
      mediaUrl: map['mediaUrl'],
      createdAt: parseDate(map['createdAt']),
      isRead: map['isRead'] ?? false,
    );
  }

  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ChatMessageModel.fromMap(data, docId: doc.id);
  }
}
