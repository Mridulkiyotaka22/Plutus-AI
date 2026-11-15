import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../models/portfolio_position.dart';
import '../providers/portfolio_provider.dart';
import '../widgets/add_transaction_dialog.dart';
import '../widgets/sector_breakdown_card.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(portfolioSummaryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: summaryAsync.when(
        data: (summary) => _buildContent(context, ref, summary),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Error loading portfolio: $err',
              style: const TextStyle(color: AppColors.negative)),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, PortfolioSummaryData summary) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 950;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Action Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.portfolioName,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Ledger-calculated positions with verifiable average cost basis',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const AddTransactionDialog(),
                      );
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Transaction'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // KPI Metric Cards
              Wrap(
                spacing: 16,
                runSpacing: 14,
                children: [
                  _buildKpiCard(
                      'Total Portfolio Value',
                      '\$${summary.totalValue.toStringAsFixed(2)}',
                      AppColors.primaryLight),
                  _buildKpiCard(
                      'Invested Capital',
                      '\$${summary.investedCapital.toStringAsFixed(2)}',
                      AppColors.textPrimary),
                  _buildKpiCard(
                    'Unrealized Gain / Loss',
                    '${summary.isPositive ? "+" : ""}\$${summary.totalGainLoss.toStringAsFixed(2)} (${summary.isPositive ? "+" : ""}${summary.totalReturnPercent.toStringAsFixed(2)}%)',
                    summary.isPositive
                        ? AppColors.positive
                        : AppColors.negative,
                  ),
                  _buildKpiCard(
                      'Cash Balance',
                      '\$${summary.cashBalance.toStringAsFixed(2)}',
                      AppColors.market),
                ],
              ),
              const SizedBox(height: 24),

              // Sector Breakdown and Holdings Ledger
              if (isCompact) ...[
                SectorBreakdownCard(
                    positions: summary.positions,
                    totalValue: summary.totalValue),
                const SizedBox(height: 20),
                _buildHoldingsLedger(summary.positions),
              ] else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildHoldingsLedger(summary.positions),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: SectorBreakdownCard(
                          positions: summary.positions,
                          totalValue: summary.totalValue),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildKpiCard(String title, String value, Color valueColor) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingsLedger(List<PortfolioPosition> positions) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                'Holdings Ledger',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              Text(
                'Average Cost Basis',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 40,
              dataRowMinHeight: 48,
              dataRowMaxHeight: 52,
              horizontalMargin: 8,
              columnSpacing: 20,
              columns: const [
                DataColumn(
                    label: Text('Asset',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12))),
                DataColumn(
                    label: Text('Shares',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12))),
                DataColumn(
                    label: Text('Avg Cost',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12))),
                DataColumn(
                    label: Text('Current Price',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12))),
                DataColumn(
                    label: Text('Market Value',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12))),
                DataColumn(
                    label: Text('Unrealized P&L',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12))),
                DataColumn(
                    label: Text('Weight',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12))),
              ],
              rows: positions.map((p) {
                final isPos = p.isPositive;
                final color = isPos ? AppColors.positive : AppColors.negative;
                return DataRow(
                  cells: [
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(p.symbol,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  fontSize: 13)),
                          Text(p.assetClass,
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 10)),
                        ],
                      ),
                    ),
                    DataCell(Text(
                        p.shares.toStringAsFixed(p.shares < 1 ? 4 : 2),
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12))),
                    DataCell(Text('\$${p.avgCost.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12))),
                    DataCell(Text('\$${p.currentPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600))),
                    DataCell(Text('\$${p.marketValue.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold))),
                    DataCell(
                      Text(
                        '${isPos ? "+" : ""}\$${p.gainLoss.toStringAsFixed(2)} (${isPos ? "+" : ""}${p.gainLossPercent.toStringAsFixed(2)}%)',
                        style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(Text('${p.weight.toStringAsFixed(1)}%',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
