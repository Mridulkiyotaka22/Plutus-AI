import '../../../core/api/api_client.dart';
import '../models/ai_message_model.dart';
import 'assistant_repository.dart';

class ApiAssistantRepository implements AssistantRepository {
  final ApiClient _client = ApiClient();

  @override
  Future<List<AIConversationModel>> getConversations() async {
    final response = await _client.dio.get('assistant/conversations/');
    final list = response.data as List<dynamic>;
    return list
        .map((json) =>
            AIConversationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AIMessageModel> sendMessage({
    required String message,
    String? conversationId,
  }) async {
    final response = await _client.dio.post(
      'assistant/chat/',
      data: {
        'message': message,
        if (conversationId != null) 'conversation_id': conversationId,
      },
    );
    final data = response.data as Map<String, dynamic>;
    if (data['assistant_message'] != null) {
      return AIMessageModel.fromJson(
          data['assistant_message'] as Map<String, dynamic>);
    }
    return AIMessageModel(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      role: (data['is_in_scope'] == false) ? 'SYSTEM' : 'ASSISTANT',
      content: data['reply'] as String? ?? data['answer'] as String? ?? '',
      isInScope: data['is_in_scope'] as bool? ?? true,
      sources: (data['sources'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
      disclaimers: data['disclaimers'] as String? ?? '',
      createdAt: DateTime.now(),
    );
  }
}
