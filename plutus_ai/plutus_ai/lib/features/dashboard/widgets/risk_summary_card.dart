import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_colors.dart';
import '../providers/dashboard_providers.dart';

/// Portfolio risk snapshot card with risk gauge and factor metrics.
class RiskSummaryCard extends ConsumerWidget {
  const RiskSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riskAsync = ref.watch(riskSummaryProvider);
    final currencyFormatter =
        NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RISK INTELLIGENCE',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Risk Profile & Diagnostics',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.go('/risk'),
                icon: const Icon(Icons.open_in_new_rounded,
                    size: 18, color: AppColors.textSecondary),
                tooltip: 'Open Risk Intelligence Terminal',
              ),
            ],
          ),
          const SizedBox(height: 20),
          riskAsync.when(
            data: (risk) {
              if (!risk.available) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    risk.riskAssessment,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                );
              }
              final scorePercent = (risk.riskScore / 100.0).clamp(0.0, 1.0);
              final scoreColor = risk.riskScore > 75
                  ? AppColors.negative
                  : (risk.riskScore > 50
                      ? AppColors.warning
                      : AppColors.positive);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Risk Score Gauge
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'COMPOSITE RISK SCORE',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: scoreColor.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                risk.riskLevel.toUpperCase(),
                                style: TextStyle(
                                  color: scoreColor,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${risk.riskScore}',
                              style: TextStyle(
                                color: scoreColor,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Text(
                              ' / 100',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: scorePercent,
                            minHeight: 6,
                            backgroundColor: AppColors.surface,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(scoreColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Key Quantitative Ratios Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildRatioCard(
                          label: 'BETA (VS SPY)',
                          value: risk.beta.toStringAsFixed(2),
                          subtext: 'Growth Tilt',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildRatioCard(
                          label: 'SHARPE RATIO',
                          value: risk.sharpeRatio.toStringAsFixed(2),
                          subtext: 'High Efficiency',
                          valueColor: AppColors.positive,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildRatioCard(
                          label: 'MAX DRAWDOWN',
                          value: '${risk.maxDrawdown.toStringAsFixed(1)}%',
                          subtext: '12-Month Historical',
                          valueColor: AppColors.negative,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildRatioCard(
                          label: '1-DAY 95% VaR',
                          value: currencyFormatter.format(risk.valueAtRisk95),
                          subtext: 'Simulated Tail Risk',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Summary Assessment Note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.shield_outlined,
                            size: 16, color: AppColors.warning),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            risk.riskAssessment,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (err, _) => Center(
              child: Text('Error loading risk: $err',
                  style: const TextStyle(color: AppColors.negative)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatioCard({
    required String label,
    required String value,
    required String subtext,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 9.5,
            ),
          ),
        ],
      ),
    );
  }
}
