import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../models/risk_models.dart';

class CorrelationHeatmapCard extends StatelessWidget {
  final CorrelationMatrixData data;

  const CorrelationHeatmapCard({super.key, required this.data});

  Color _getHeatmapColor(double val) {
    if (val == 1.0) return AppColors.primary;
    if (val >= 0.7) return AppColors.primaryLight.withOpacity(0.85);
    if (val >= 0.3) return AppColors.market.withOpacity(0.65);
    if (val >= 0.0) return AppColors.surfaceLight;
    if (val >= -0.3) return AppColors.negative.withOpacity(0.4);
    return AppColors.negative.withOpacity(0.8);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cross-Asset Correlation Matrix',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  data.period,
                  style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Pearson coefficient matrix. Low or negative correlation provides effective hedge diversification.',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Asset labels
                Row(
                  children: [
                    const SizedBox(width: 52), // offset for row labels
                    ...data.assets.map((asset) => SizedBox(
                          width: 52,
                          child: Center(
                            child: Text(
                              asset,
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary),
                            ),
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 6),

                // Grid rows
                ...List.generate(data.assets.length, (rowIdx) {
                  final asset = data.assets[rowIdx];
                  final rowValues = data.matrix[rowIdx];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 52,
                          child: Text(
                            asset,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary),
                          ),
                        ),
                        ...rowValues.map((val) {
                          final color = _getHeatmapColor(val);
                          return Container(
                            width: 50,
                            height: 38,
                            margin: const EdgeInsets.only(right: 2),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                val.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
