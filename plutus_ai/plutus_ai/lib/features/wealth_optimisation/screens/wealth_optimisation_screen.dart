import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../models/wealth_models.dart';
import '../providers/wealth_provider.dart';

class WealthOptimisationScreen extends ConsumerWidget {
  const WealthOptimisationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxHarvestAsync = ref.watch(taxHarvestSimulationProvider);
    final rebalanceAsync = ref.watch(rebalancePlanProvider);
    final currentJurisdiction = ref.watch(selectedJurisdictionProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
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
                      'Wealth & Tax Optimisation',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Simulated tax-loss harvesting, wash-sale safe substitutes, and drift rebalancing',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                // Jurisdiction Selector
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentJurisdiction,
                      dropdownColor: AppColors.card,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                      items: const [
                        DropdownMenuItem(
                            value: 'US_FEDERAL',
                            child: Text('US Federal (IRS)')),
                        DropdownMenuItem(
                            value: 'UK_HMRC', child: Text('UK (HMRC)')),
                        DropdownMenuItem(
                            value: 'IN_ITR', child: Text('India (ITR)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          ref
                              .read(selectedJurisdictionProvider.notifier)
                              .state = val;
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tax Loss Harvesting Section
            taxHarvestAsync.when(
              data: (taxResult) =>
                  _buildTaxHarvestCard(context, ref, taxResult),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error: $err',
                  style: const TextStyle(color: AppColors.negative)),
            ),
            const SizedBox(height: 24),

            // Rebalancing Simulation Section
            rebalanceAsync.when(
              data: (rebalanceList) =>
                  _buildRebalancingCard(context, rebalanceList),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error: $err',
                  style: const TextStyle(color: AppColors.negative)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxHarvestCard(
      BuildContext context, WidgetRef ref, TaxHarvestResult res) {
    return Container(
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.positive.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.receipt_long_rounded,
                        color: AppColors.positive, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tax-Loss Harvesting Opportunities',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary),
                      ),
                      Text(
                        'Automated wash-sale rule check (30-day window)',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.positive.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Estimated Savings: \$${res.estimatedTaxSavings.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: AppColors.positive,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Overview KPI
          Row(
            children: [
              _buildMiniMetric(
                  'Total Harvestable Loss',
                  '\$${res.totalHarvestableLoss.toStringAsFixed(2)}',
                  AppColors.negative),
              const SizedBox(width: 16),
              _buildMiniMetric('Assumed Marginal Tax Rate', res.marginalRate,
                  AppColors.textPrimary),
              const SizedBox(width: 16),
              _buildMiniMetric('Tax Year', '${res.taxYear}', AppColors.market),
            ],
          ),
          const SizedBox(height: 20),

          // Candidate Positions Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 38,
              dataRowMinHeight: 48,
              dataRowMaxHeight: 52,
              horizontalMargin: 8,
              columnSpacing: 24,
              columns: const [
                DataColumn(
                    label: Text('Candidate Asset',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12))),
                DataColumn(
                    label: Text('Shares',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12))),
                DataColumn(
                    label: Text('Harvestable Loss',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12))),
                DataColumn(
                    label: Text('Wash-Sale Substitute',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12))),
                DataColumn(
                    label: Text('Tracking Correlation',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12))),
                DataColumn(
                    label: Text('Wash-Sale Safe?',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12))),
              ],
              rows: res.opportunities.map((op) {
                return DataRow(
                  cells: [
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(op.symbol,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  fontSize: 13)),
                          Text(op.name,
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 10)),
                        ],
                      ),
                    ),
                    DataCell(Text('${op.shares.toStringAsFixed(0)} shs',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12))),
                    DataCell(Text('-\$${op.currentLoss.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: AppColors.negative,
                            fontWeight: FontWeight.bold,
                            fontSize: 12))),
                    DataCell(
                      Row(
                        children: [
                          Text(op.substituteSymbol,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryLight,
                                  fontSize: 13)),
                          const SizedBox(width: 4),
                          Text('(${op.substituteName})',
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 10)),
                        ],
                      ),
                    ),
                    DataCell(Text(
                        '${(op.correlation * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                            color: AppColors.positive,
                            fontWeight: FontWeight.bold,
                            fontSize: 12))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.positive.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('YES (30-day window)',
                            style: TextStyle(
                                color: AppColors.positive,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            res.disclaimer,
            style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildRebalancingCard(
      BuildContext context, List<RebalanceAction> actions) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Systematic Rebalancing Simulator',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              Text(
                'Target Model: Moderate Growth (40/25/10/15/10)',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 38,
              dataRowMinHeight: 48,
              dataRowMaxHeight: 52,
              horizontalMargin: 8,
              columnSpacing: 28,
              columns: const [
                DataColumn(
                    label: Text('Asset Class',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12))),
                DataColumn(
                    label: Text('Current Weight',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12))),
                DataColumn(
                    label: Text('Target Weight',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12))),
                DataColumn(
                    label: Text('Drift (%)',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12))),
                DataColumn(
                    label: Text('Recommended Action',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12))),
                DataColumn(
                    label: Text('Dollar Adjustment',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12))),
              ],
              rows: actions.map((act) {
                final isOverweight = act.drift > 0;
                final driftColor =
                    isOverweight ? AppColors.warning : AppColors.market;

                return DataRow(
                  cells: [
                    DataCell(Text(act.assetClass,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontSize: 13))),
                    DataCell(Text('${act.currentWeight.toStringAsFixed(1)}%',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12))),
                    DataCell(Text('${act.targetWeight.toStringAsFixed(1)}%',
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold))),
                    DataCell(
                      Text(
                        '${isOverweight ? "+" : ""}${act.drift.toStringAsFixed(1)}%',
                        style: TextStyle(
                            color: driftColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: act.action == 'TRIM'
                              ? AppColors.warning.withOpacity(0.12)
                              : act.action == 'BUY'
                                  ? AppColors.positive.withOpacity(0.12)
                                  : AppColors.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          act.action,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: act.action == 'TRIM'
                                ? AppColors.warning
                                : act.action == 'BUY'
                                    ? AppColors.positive
                                    : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${act.estimatedAdjustment >= 0 ? "+" : ""}\$${act.estimatedAdjustment.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: act.estimatedAdjustment >= 0
                              ? AppColors.positive
                              : AppColors.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
