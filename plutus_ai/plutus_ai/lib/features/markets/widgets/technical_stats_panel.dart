import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../models/market_instrument.dart';

class TechnicalStatsPanel extends StatelessWidget {
  final MarketInstrument instrument;
  const TechnicalStatsPanel({super.key, required this.instrument});

  String _formatNumber(double val) {
    if (val <= 0) return '—';
    if (val >= 1e12) return '${(val / 1e12).toStringAsFixed(2)}T';
    if (val >= 1e9) return '${(val / 1e9).toStringAsFixed(2)}B';
    if (val >= 1e6) return '${(val / 1e6).toStringAsFixed(2)}M';
    if (val >= 1e3) return '${(val / 1e3).toStringAsFixed(1)}K';
    return val.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Available Market Metrics', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        Wrap(spacing: 20, runSpacing: 14, children: [
          _buildStatTile('52-Week High', instrument.high52w > 0 ? instrument.formatPrice(instrument.high52w) : '—'),
          _buildStatTile('52-Week Low', instrument.low52w > 0 ? instrument.formatPrice(instrument.low52w) : '—'),
          _buildStatTile('Market Capitalization', instrument.marketCap != null ? _formatNumber(instrument.marketCap!) : '—'),
          _buildStatTile('Latest Volume', _formatNumber(instrument.volume)),
          _buildStatTile('P/E Ratio (TTM)', instrument.peRatio != null ? '${instrument.peRatio!.toStringAsFixed(1)}x' : '—'),
          _buildStatTile('Asset Class', instrument.category.label),
        ]),
        const SizedBox(height: 16),
        const Divider(color: AppColors.border),
        const SizedBox(height: 10),
        const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.info_outline, size: 15, color: AppColors.textMuted),
          SizedBox(width: 8),
          Expanded(child: Text(
            'Order-book depth and Level II bid/ask data are not supplied by yfinance. PLUTUS will not display simulated depth as market data.',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          )),
        ]),
      ]),
    );
  }

  Widget _buildStatTile(String label, String value) => SizedBox(
    width: 145,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    ]),
  );
}
