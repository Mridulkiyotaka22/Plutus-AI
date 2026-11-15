import '../models/ai_message_model.dart';

abstract class AssistantRepository {
  Future<List<AIConversationModel>> getConversations();
  Future<AIMessageModel> sendMessage({
    required String message,
    String? conversationId,
  });
}
