/// Importance level of the AI insight.
enum InsightPriority { high, medium, low }

/// AI-generated insight preview for the dashboard.
class AiInsight {
  final String id;
  final String title;
  final String summary;
  final String detailedAnalysis;
  final InsightPriority priority;
  final String category;
  final double confidenceScore;
  final DateTime generatedAt;
  final String suggestedAction;
  final String targetRoute;

  const AiInsight({
    required this.id,
    required this.title,
    required this.summary,
    required this.detailedAnalysis,
    required this.priority,
    required this.category,
    required this.confidenceScore,
    required this.generatedAt,
    required this.suggestedAction,
    this.targetRoute = '/ai',
  });
}
