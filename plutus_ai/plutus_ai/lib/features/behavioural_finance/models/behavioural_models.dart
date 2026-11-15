class QuestionOptionModel {
  final String id;
  final String text;
  final int score;

  const QuestionOptionModel({
    required this.id,
    required this.text,
    required this.score,
  });

  factory QuestionOptionModel.fromJson(Map<String, dynamic> json) {
    return QuestionOptionModel(
      id: json['id']?.toString() ?? '',
      text: json['text'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 10,
    );
  }
}

class QuestionModel {
  final String id;
  final int order;
  final String text;
  final String category;
  final List<QuestionOptionModel> options;

  const QuestionModel({
    required this.id,
    required this.order,
    required this.text,
    required this.category,
    required this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>? ?? [];
    return QuestionModel(
      id: json['id']?.toString() ?? '',
      order: (json['order'] as num?)?.toInt() ?? 1,
      text: json['text'] as String? ?? '',
      category: json['category'] as String? ?? 'RISK_TOLERANCE',
      options: rawOptions
          .map((o) => QuestionOptionModel.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BehaviouralProfileModel {
  final int compositeScore;
  final String riskCategory;
  final int lossAversionScore;
  final int overconfidenceScore;
  final String panicSellingPropensity;
  final int selfReportedScore;
  final int tradeObservedScore;
  final String summary;

  const BehaviouralProfileModel({
    required this.compositeScore,
    required this.riskCategory,
    required this.lossAversionScore,
    required this.overconfidenceScore,
    required this.panicSellingPropensity,
    required this.selfReportedScore,
    required this.tradeObservedScore,
    required this.summary,
  });

  factory BehaviouralProfileModel.fromJson(Map<String, dynamic> json) {
    return BehaviouralProfileModel(
      compositeScore: (json['composite_score'] as num?)?.toInt() ?? 72,
      riskCategory:
          json['risk_category'] as String? ?? 'Assertive / Growth Oriented',
      lossAversionScore: (json['loss_aversion_score'] as num?)?.toInt() ?? 45,
      overconfidenceScore:
          (json['overconfidence_score'] as num?)?.toInt() ?? 35,
      panicSellingPropensity:
          json['panic_selling_propensity'] as String? ?? 'Low-Medium',
      selfReportedScore: (json['self_reported_score'] as num?)?.toInt() ?? 75,
      tradeObservedScore: (json['trade_observed_score'] as num?)?.toInt() ?? 68,
      summary: json['summary'] as String? ??
          'Disciplined profile with healthy risk tolerance.',
    );
  }
}
