import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bluesky_app/data/models/chat_model.dart';
import 'package:bluesky_app/data/repositories/chat_repository.dart';

class ChatController extends GetxController {
  final ChatRepository _chatRepo = Get.find<ChatRepository>();

  final conversations = <ConversationModel>[].obs;
  final currentMessages = <ChatMessageModel>[].obs;
  final Rxn<ConversationModel> activeConversation = Rxn<ConversationModel>();
  final messageInputController = TextEditingController();

  final isLoadingConversations = false.obs;

  @override
  void onInit() {
    super.onInit();
    _listenConversations();
  }

  void _listenConversations() {
    isLoadingConversations.value = true;
    _chatRepo.getConversationsStream('user_current').listen((convs) {
      conversations.assignAll(convs);
      isLoadingConversations.value = false;
    });
  }

  void openConversation(ConversationModel conv) {
    activeConversation.value = conv;
    _chatRepo.getMessagesStream(conv.id).listen((msgs) {
      currentMessages.assignAll(msgs);
    });
  }

  Future<void> sendMessage() async {
    final text = messageInputController.text.trim();
    if (text.isEmpty || activeConversation.value == null) return;

    final newMsg = ChatMessageModel(
      id: '',
      conversationId: activeConversation.value!.id,
      senderId: 'user_current',
      senderHandle: 'explorer.aura.social',
      text: text,
      createdAt: DateTime.now(),
    );

    messageInputController.clear();
    currentMessages.insert(0, newMsg);

    await _chatRepo.sendMessage(newMsg);
  }

  @override
  void onClose() {
    messageInputController.dispose();
    super.onClose();
  }
}
