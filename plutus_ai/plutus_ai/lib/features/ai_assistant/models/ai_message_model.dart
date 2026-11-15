class AIMessageModel {
  final String id;
  final String role; // USER, ASSISTANT, SYSTEM
  final String content;
  final bool isInScope;
  final List<String> sources;
  final String disclaimers;
  final DateTime createdAt;

  const AIMessageModel({
    required this.id,
    required this.role,
    required this.content,
    this.isInScope = true,
    this.sources = const [],
    this.disclaimers = 'Educational intelligence, not financial advice.',
    required this.createdAt,
  });

  bool get isUser => role == 'USER';
  bool get isAssistant => role == 'ASSISTANT';
  bool get isSystem => role == 'SYSTEM';

  factory AIMessageModel.fromJson(Map<String, dynamic> json) {
    final rawSources = json['sources'] as List<dynamic>? ?? [];
    return AIMessageModel(
      id: json['id']?.toString() ?? '',
      role: json['role'] as String? ?? 'ASSISTANT',
      content: json['content'] as String? ?? '',
      isInScope: json['is_in_scope'] as bool? ?? true,
      sources: rawSources.map((s) => s.toString()).toList(),
      disclaimers: json['disclaimers'] as String? ??
          'Educational intelligence, not financial advice.',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class AIConversationModel {
  final String id;
  final String title;
  final bool isPinned;
  final List<AIMessageModel> messages;

  const AIConversationModel({
    required this.id,
    required this.title,
    this.isPinned = false,
    required this.messages,
  });

  factory AIConversationModel.fromJson(Map<String, dynamic> json) {
    final rawMsgs = json['messages'] as List<dynamic>? ?? [];
    return AIConversationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? 'Financial Inquiry',
      isPinned: json['is_pinned'] as bool? ?? false,
      messages: rawMsgs
          .map((m) => AIMessageModel.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}
