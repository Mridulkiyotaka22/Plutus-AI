class ModelEvaluationModel {
  final String benchmarkDataset;
  final String split;
  final double? directionalAccuracy;
  final double? mae;
  final double? f1Score;
  final double? sharpeBacktest;
  final String evalDate;
  final String notes;

  const ModelEvaluationModel({
    required this.benchmarkDataset,
    required this.split,
    this.directionalAccuracy,
    this.mae,
    this.f1Score,
    this.sharpeBacktest,
    required this.evalDate,
    this.notes = '',
  });

  factory ModelEvaluationModel.fromJson(Map<String, dynamic> json) {
    return ModelEvaluationModel(
      benchmarkDataset: json['benchmark_dataset'] as String? ?? '',
      split: json['split'] as String? ?? 'Out-of-sample Test',
      directionalAccuracy: (json['directional_accuracy'] as num?)?.toDouble(),
      mae: (json['mae'] as num?)?.toDouble(),
      f1Score: (json['f1_score'] as num?)?.toDouble(),
      sharpeBacktest: (json['sharpe_backtest'] as num?)?.toDouble(),
      evalDate: json['eval_date'] as String? ?? '2026-01-01',
      notes: json['notes'] as String? ?? '',
    );
  }
}

class ResearchModelMeta {
  final String modelId;
  final String name;
  final String architecture;
  final String description;
  final String status;
  final String statusDisplay;
  final String version;
  final String parametersCount;
  final String datasetCoverage;
  final String trainingCutoff;
  final List<ModelEvaluationModel> evaluations;

  const ResearchModelMeta({
    required this.modelId,
    required this.name,
    required this.architecture,
    required this.description,
    required this.status,
    required this.statusDisplay,
    required this.version,
    required this.parametersCount,
    required this.datasetCoverage,
    required this.trainingCutoff,
    required this.evaluations,
  });

  factory ResearchModelMeta.fromJson(Map<String, dynamic> json) {
    final rawEvals = json['evaluations'] as List<dynamic>? ?? [];
    return ResearchModelMeta(
      modelId: json['model_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      architecture: json['architecture'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'EXPERIMENTAL',
      statusDisplay:
          json['status_display'] as String? ?? 'Experimental Offline Testing',
      version: json['version'] as String? ?? 'v0.1',
      parametersCount: json['parameters_count'] as String? ?? '110M',
      datasetCoverage: json['dataset_coverage'] as String? ?? '',
      trainingCutoff: json['training_cutoff'] as String? ?? '2025-12-31',
      evaluations: rawEvals
          .map((e) => ModelEvaluationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
