class AlertModel {
  final String id;
  final String title;
  final String message;
  final String priority; // INFO, WARNING, CRITICAL
  final String category; // RISK, PORTFOLIO, MARKET, RESEARCH, SYSTEM
  final bool isRead;
  final String actionLabel;
  final String actionRoute;
  final DateTime createdAt;

  const AlertModel({
    required this.id,
    required this.title,
    required this.message,
    required this.priority,
    required this.category,
    required this.isRead,
    this.actionLabel = '',
    this.actionRoute = '',
    required this.createdAt,
  });

  AlertModel copyWith({bool? isRead}) {
    return AlertModel(
      id: id,
      title: title,
      message: message,
      priority: priority,
      category: category,
      isRead: isRead ?? this.isRead,
      actionLabel: actionLabel,
      actionRoute: actionRoute,
      createdAt: createdAt,
    );
  }

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      priority: json['priority'] as String? ?? 'INFO',
      category: json['category'] as String? ?? 'PORTFOLIO',
      isRead: json['is_read'] as bool? ?? false,
      actionLabel: json['action_label'] as String? ?? '',
      actionRoute: json['action_route'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
