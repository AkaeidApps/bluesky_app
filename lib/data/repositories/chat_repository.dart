import 'package:bluesky_app/core/network/atproto_api_service.dart';
import 'package:bluesky_app/data/models/chat_model.dart';
import 'package:bluesky_app/data/providers/mock_data_provider.dart';

class ChatRepository {
  final AtprotoApiService _apiService;

  ChatRepository({AtprotoApiService? apiService})
      : _apiService = apiService ?? AtprotoApiService();

  Stream<List<ConversationModel>> getConversationsStream(String userId) {
    return Stream.periodic(const Duration(seconds: 30), (_) async {
      try {
        return await _apiService.listConvos();
      } catch (e) {
        return MockDataProvider.sampleConversations;
      }
    }).asyncMap((event) => event);
  }

  Stream<List<ChatMessageModel>> getMessagesStream(String conversationId) {
    return Stream.periodic(const Duration(seconds: 5), (_) async {
      try {
        return await _apiService.getMessages(convoId: conversationId, limit: 50);
      } catch (e) {
        return [
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
        ];
      }
    }).asyncMap((event) => event);
  }

  Future<ChatMessageModel> sendMessage(ChatMessageModel message) async {
    try {
      return await _apiService.sendMessage(
        convoId: message.conversationId,
        text: message.text,
      );
    } catch (e) {
      return message;
    }
  }

  Future<void> updateRead(String convoId, String messageId) async {
    try {
      await _apiService.updateRead(convoId: convoId, messageId: messageId);
    } catch (e) {
    }
  }
}