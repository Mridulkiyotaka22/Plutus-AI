import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_colors.dart';
import '../models/performance_chart_data.dart';
import '../providers/dashboard_providers.dart';

/// Interactive portfolio performance chart with multi-timeframe controls.
class PortfolioChartCard extends ConsumerWidget {
  const PortfolioChartCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRange = ref.watch(selectedChartRangeProvider);
    final chartDataAsync = ref.watch(portfolioChartDataProvider);

    final currencyFormatter =
        NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final compactFormatter = NumberFormat.compactCurrency(symbol: '\$');
    final percentFormatter =
        NumberFormat.decimalPatternDigits(decimalDigits: 2);

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
          // Header Row with Timeframe Selectors
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'PORTFOLIO PERFORMANCE',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    chartDataAsync.when(
                      data: (data) {
                        final isPos = data.isPositive;
                        final color =
                            isPos ? AppColors.positive : AppColors.negative;
                        return Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 10,
                          runSpacing: 4,
                          children: [
                            Text(
                              currencyFormatter.format(data.endingValue),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPos
                                      ? Icons.arrow_upward_rounded
                                      : Icons.arrow_downward_rounded,
                                  size: 14,
                                  color: color,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${isPos ? '+' : ''}${currencyFormatter.format(data.changeAmount)} (${isPos ? '+' : ''}${percentFormatter.format(data.changePercentage)}%)',
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                      loading: () => const Text(
                        'Loading performance...',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 18),
                      ),
                      error: (_, __) => const Text(
                        'Unable to load performance',
                        style:
                            TextStyle(color: AppColors.negative, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              // Timeframe selector pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: TimeRange.values.map((range) {
                      final isSelected = range == selectedRange;
                      return InkWell(
                        onTap: () {
                          ref.read(selectedChartRangeProvider.notifier).state =
                              range;
                        },
                        borderRadius: BorderRadius.circular(7),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            range.label,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Chart Display Area
          SizedBox(
            height: 270,
            child: chartDataAsync.when(
              data: (data) {
                if (data.points.isEmpty) {
                  return const Center(
                    child: Text(
                      'No chart data available for selected range.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  );
                }

                final spots = List.generate(
                  data.points.length,
                  (index) => FlSpot(index.toDouble(), data.points[index].value),
                );

                final lineColor = data.isPositive
                    ? AppColors.primaryLight
                    : AppColors.negative;

                return LineChart(
                  LineChartData(
                    lineTouchData: LineTouchData(
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: AppColors.surfaceLight,
                        tooltipRoundedRadius: 8,
                        tooltipPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final index = spot.x.toInt();
                            if (index < 0 || index >= data.points.length) {
                              return null;
                            }
                            final point = data.points[index];
                            final dateStr = DateFormat('MMM dd, yyyy')
                                .format(point.timestamp);
                            final valStr =
                                currencyFormatter.format(point.value);
                            return LineTooltipItem(
                              '$dateStr\n',
                              const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(
                                  text: valStr,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval:
                          (data.maxValue - data.minValue) / 4 > 0
                              ? (data.maxValue - data.minValue) / 4
                              : 1000,
                      getDrawingHorizontalLine: (value) => const FlLine(
                        color: AppColors.border,
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 26,
                          interval:
                              (data.points.length / 4).clamp(1, 10).toDouble(),
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= data.points.length) {
                              return const SizedBox.shrink();
                            }
                            final date = data.points[index].timestamp;
                            final formatted = DateFormat('MMM d').format(date);
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                formatted,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 52,
                          interval: (data.maxValue - data.minValue) / 4 > 0
                              ? (data.maxValue - data.minValue) / 4
                              : 1000,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              compactFormatter.format(value),
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: (data.points.length - 1).toDouble(),
                    minY: data.minValue,
                    maxY: data.maxValue,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.25,
                        color: lineColor,
                        barWidth: 2.5,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              lineColor.withValues(alpha: 0.28),
                              lineColor.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, _) => Center(
                child: Text(
                  'Error loading chart: $err',
                  style: const TextStyle(color: AppColors.negative),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
