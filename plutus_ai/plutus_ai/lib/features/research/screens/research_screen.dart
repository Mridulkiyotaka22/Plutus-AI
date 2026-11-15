import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../models/research_model_meta.dart';
import '../providers/research_provider.dart';

class ResearchScreen extends ConsumerWidget {
  const ResearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modelsAsync = ref.watch(researchModelsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: modelsAsync.when(
        data: (models) => _buildContent(context, models),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Error loading models: $err',
              style: const TextStyle(color: AppColors.negative)),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<ResearchModelMeta> models) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quantitative Research & AI Models',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Neural architectures, out-of-sample backtest benchmarks, and dataset coverage',
                    style:
                        TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.aiViolet.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border:
                      Border.all(color: AppColors.aiViolet.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.science_outlined,
                        size: 14, color: AppColors.aiViolet),
                    SizedBox(width: 6),
                    Text(
                      'RESEARCH / NON-PRODUCTION',
                      style: TextStyle(
                          color: AppColors.aiViolet,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Models List
          ...models.map((model) => _buildModelCard(model)),
        ],
      ),
    );
  }

  Widget _buildModelCard(ResearchModelMeta model) {
    Color statusColor = AppColors.warning;
    if (model.status == 'PROPOSED') statusColor = AppColors.market;
    if (model.status == 'EXPERIMENTAL') statusColor = AppColors.aiViolet;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      model.name,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        model.version,
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withOpacity(0.4)),
                ),
                child: Text(
                  model.statusDisplay,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            model.description,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),

          // Metadata Grid
          Wrap(
            spacing: 20,
            runSpacing: 10,
            children: [
              _buildMetaTag('Architecture', model.architecture),
              _buildMetaTag('Parameters', model.parametersCount),
              _buildMetaTag('Training Cutoff', model.trainingCutoff),
              _buildMetaTag('Dataset Corpus', model.datasetCoverage),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),

          // Evaluation Metrics
          const Text(
            'Out-of-Sample Benchmark Validation',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),

          ...model.evaluations.map((ev) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(ev.benchmarkDataset,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                      Text(ev.split,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.market)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 6,
                    children: [
                      if (ev.directionalAccuracy != null)
                        Text(
                            'Directional Accuracy: ${ev.directionalAccuracy!.toStringAsFixed(1)}%',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.positive,
                                fontWeight: FontWeight.bold)),
                      if (ev.f1Score != null)
                        Text('F1-Score: ${ev.f1Score!.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.bold)),
                      if (ev.mae != null)
                        Text('MAE: ${ev.mae!.toStringAsFixed(4)}',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.warning,
                                fontWeight: FontWeight.bold)),
                      if (ev.sharpeBacktest != null)
                        Text(
                            'Backtest Sharpe: ${ev.sharpeBacktest!.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.positive,
                                fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (ev.notes.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(ev.notes,
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                            fontStyle: FontStyle.italic)),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMetaTag(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ],
    );
  }
}
