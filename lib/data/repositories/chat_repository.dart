import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bluesky_app/core/services/firebase_service.dart';
import 'package:bluesky_app/data/models/chat_model.dart';
import 'package:bluesky_app/data/providers/mock_data_provider.dart';

class ChatRepository {
  final FirebaseFirestore? _firestore = FirebaseService.isInitialized
      ? FirebaseFirestore.instance
      : null;

  Stream<List<ConversationModel>> getConversationsStream(String userId) {
    if (_firestore != null) {
      return _firestore
          .collection('conversations')
          .where('participantIds', arrayContains: userId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => ConversationModel.fromFirestore(doc))
                .toList(),
          );
    }
    return Stream.value(MockDataProvider.sampleConversations);
  }

  Stream<List<ChatMessageModel>> getMessagesStream(String conversationId) {
    if (_firestore != null) {
      return _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => ChatMessageModel.fromFirestore(doc))
                .toList(),
          );
    }

    return Stream.value([
      ChatMessageModel(
        id: 'msg_2',
        conversationId: conversationId,
        senderId: 'user_1',
        senderHandle: 'mayalin.aura.social',
        text: 'The new UI design looks super clean! Loved the butterfly mark.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        isRead: true,
      ),
      ChatMessageModel(
        id: 'msg_1',
        conversationId: conversationId,
        senderId: 'user_current',
        senderHandle: 'explorer.aura.social',
        text: 'Hey Maya! Working on the feeds and direct messaging right now.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
        isRead: true,
      ),
    ]);
  }

  Future<void> sendMessage(ChatMessageModel message) async {
    if (_firestore != null) {
      final batch = _firestore.batch();
      final msgRef = _firestore
          .collection('conversations')
          .doc(message.conversationId)
          .collection('messages')
          .doc();

      batch.set(msgRef, message.toMap());
      batch.update(
        _firestore.collection('conversations').doc(message.conversationId),
        {
          'lastMessageText': message.text,
          'lastMessageSenderId': message.senderId,
          'lastMessageTime': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();
    }
  }
}
