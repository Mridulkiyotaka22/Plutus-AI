import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/env_config.dart';
import '../../../config/environment_provider.dart';
import '../fixtures/demo_assistant.dart';
import '../models/ai_message_model.dart';
import '../repositories/api_assistant_repository.dart';
import '../repositories/assistant_repository.dart';
import '../repositories/mock_assistant_repository.dart';

final assistantRepositoryProvider = Provider<AssistantRepository>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  if (environment == Environment.demo) {
    return MockAssistantRepository();
  }
  return ApiAssistantRepository();
});

class ChatState {
  final List<AIMessageModel> messages;
  final bool isThinking;
  final String? activeConversationId;

  const ChatState({
    required this.messages,
    this.isThinking = false,
    this.activeConversationId,
  });

  ChatState copyWith({
    List<AIMessageModel>? messages,
    bool? isThinking,
    String? activeConversationId,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isThinking: isThinking ?? this.isThinking,
      activeConversationId: activeConversationId ?? this.activeConversationId,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final AssistantRepository _repository;

  ChatNotifier(this._repository)
      : super(ChatState(messages: DemoAssistant.initialMessages));

  Future<void> sendUserMessage(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;

    final userMsg = AIMessageModel(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      role: 'USER',
      content: trimmed,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isThinking: true,
    );

    try {
      final botMsg = await _repository.sendMessage(
        message: trimmed,
        conversationId: state.activeConversationId,
      );
      state = state.copyWith(
        messages: [...state.messages, botMsg],
        isThinking: false,
      );
    } catch (e) {
      final errorMsg = AIMessageModel(
        id: 'err-${DateTime.now().millisecondsSinceEpoch}',
        role: 'SYSTEM',
        content: 'Failed to obtain AI response: $e',
        isInScope: false,
        createdAt: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isThinking: false,
      );
    }
  }

  void clearChat() {
    state = ChatState(messages: DemoAssistant.initialMessages);
  }
}

final chatStateProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final repo = ref.watch(assistantRepositoryProvider);
  return ChatNotifier(repo);
});
