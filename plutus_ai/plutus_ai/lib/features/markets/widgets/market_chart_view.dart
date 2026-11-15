import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../models/market_instrument.dart';

class MarketChartView extends StatelessWidget {
  final MarketInstrument instrument;
  final String selectedRange;
  final ValueChanged<String> onRangeChanged;

  const MarketChartView({
    super.key,
    required this.instrument,
    required this.selectedRange,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isPos = instrument.isPositive;
    final color = isPos ? AppColors.positive : AppColors.negative;
    final points = instrument.sparklinePoints;
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(instrument.symbol, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(4)),
                      child: Text(instrument.exchange, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(instrument.name, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ]),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(
                  instrument.hasQuote ? instrument.formatPrice(instrument.currentPrice) : 'Quote unavailable',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                if (instrument.hasQuote) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${isPos ? '+' : ''}${instrument.change.toStringAsFixed(2)} (${isPos ? '+' : ''}${instrument.changePercent.toStringAsFixed(2)}%)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
                  ),
                ],
              ]),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              for (final entry in const [
                ('1D', '1d'), ('1W', '5d'), ('1M', '1mo'), ('3M', '3mo'),
                ('6M', '6mo'), ('1Y', '1y'), ('ALL', 'max'),
              ])
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: InkWell(
                    onTap: () => onRangeChanged(entry.$2),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: selectedRange == entry.$2 ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: selectedRange == entry.$2 ? AppColors.primary : AppColors.border),
                      ),
                      child: Text(entry.$1, style: TextStyle(fontSize: 10, fontWeight: selectedRange == entry.$2 ? FontWeight.bold : FontWeight.normal, color: selectedRange == entry.$2 ? Colors.white : AppColors.textSecondary)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: points.length < 2
                ? const Center(
                    child: Text(
                      'No historical price series is available for this symbol and period.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => const FlLine(color: AppColors.border, strokeWidth: 0.8)),
                      titlesData: const FlTitlesData(
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: points,
                          isCurved: true,
                          color: color,
                          barWidth: 2.2,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: true, color: color.withOpacity(0.12)),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: AppColors.surface,
                          getTooltipItems: (spots) => spots.map((spot) => LineTooltipItem(
                            instrument.formatPrice(spot.y),
                            const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                          )).toList(),
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Text('Source: ${instrument.sourceLabel}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
