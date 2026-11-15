import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_colors.dart';
import '../providers/dashboard_providers.dart';

/// Market snapshot grid using provider-backed benchmark data in API mode.
class MarketIndicesCard extends ConsumerWidget {
  const MarketIndicesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indicesAsync = ref.watch(marketIndicesProvider);
    final numberFormatter = NumberFormat('#,##0.00');

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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MARKET OVERVIEW',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Key Global Benchmarks',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Builder(builder: (context) {
                final values = indicesAsync.valueOrNull ?? const [];
                final isDemo = values.any((item) => item.isSample);
                final unavailable = values.isEmpty;
                final statusColor = isDemo
                    ? AppColors.warning
                    : (unavailable ? AppColors.textMuted : AppColors.market);
                final statusText = isDemo
                    ? 'DEMO DATA'
                    : (unavailable ? 'NO PROVIDER DATA' : 'YFINANCE • LAST AVAILABLE');
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 18),
          indicesAsync.when(
            data: (indices) {
              if (indices.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'No benchmark prices are currently available from the market-data provider.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                );
              }
              return LayoutBuilder(
                builder: (context, constraints) {
                  // Adaptive columns based on available width
                  final crossAxisCount = constraints.maxWidth > 900
                      ? 6
                      : (constraints.maxWidth > 600 ? 3 : 2);

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: indices.length,
                    itemBuilder: (context, index) {
                      final item = indices[index];
                      final isPositive = item.isPositive;
                      final color =
                          isPositive ? AppColors.positive : AppColors.negative;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${isPositive ? '+' : ''}${item.changePercent.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              item.name.contains('Yield')
                                  ? '${item.value.toStringAsFixed(2)}%'
                                  : '${item.currency.toUpperCase() == 'INR' ? '₹' : (item.currency.toUpperCase() == 'USD' ? r'$' : '${item.currency} ')}${numberFormatter.format(item.value)}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  isPositive
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  size: 10,
                                  color: color,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${isPositive ? '+' : ''}${item.change.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (err, _) => Center(
              child: Text('Error loading indices: $err',
                  style: const TextStyle(color: AppColors.negative)),
            ),
          ),
        ],
      ),
    );
  }
}
