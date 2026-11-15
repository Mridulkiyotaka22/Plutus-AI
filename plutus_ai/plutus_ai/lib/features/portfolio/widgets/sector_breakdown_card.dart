import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../models/portfolio_position.dart';

class SectorBreakdownCard extends StatelessWidget {
  final List<PortfolioPosition> positions;
  final double totalValue;

  const SectorBreakdownCard(
      {super.key, required this.positions, required this.totalValue});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> assetTotals = {};
    for (final p in positions) {
      assetTotals[p.assetClass] =
          (assetTotals[p.assetClass] ?? 0.0) + p.marketValue;
    }

    final sorted = assetTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
          const Text(
            'Asset Class Diversification',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          ...sorted.map((entry) {
            final pct = totalValue > 0 ? (entry.value / totalValue) * 100 : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      Text(
                        '\$${entry.value.toStringAsFixed(2)} (${pct.toStringAsFixed(1)}%)',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct / 100,
                      backgroundColor: AppColors.surface,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        entry.key.contains('Equities')
                            ? AppColors.primary
                            : entry.key.contains('Crypto')
                                ? AppColors.aiViolet
                                : entry.key.contains('Bond')
                                    ? AppColors.market
                                    : AppColors.warning,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
