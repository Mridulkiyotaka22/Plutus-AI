import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../models/risk_models.dart';
import '../providers/risk_provider.dart';
import '../widgets/correlation_heatmap_card.dart';

class RiskIntelligenceScreen extends ConsumerWidget {
  const RiskIntelligenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riskAsync = ref.watch(riskProfileProvider);
    final matrixAsync = ref.watch(correlationMatrixProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: riskAsync.when(
        data: (risk) => _buildContent(context, risk, matrixAsync),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
            child: Text('Error loading risk data: $err',
                style: const TextStyle(color: AppColors.negative))),
      ),
    );
  }

  Widget _buildContent(BuildContext context, QuantitativeRiskProfile risk,
      AsyncValue<CorrelationMatrixData> matrixAsync) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 950;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quantitative Risk Intelligence',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Parametric & historical simulation models, Value-at-Risk, and correlation structures',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.positive.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppColors.positive.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified,
                            size: 14, color: AppColors.positive),
                        const SizedBox(width: 6),
                        Text(
                          risk.status,
                          style: const TextStyle(
                              color: AppColors.positive,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Ratio Grid Cards
              Wrap(
                spacing: 16,
                runSpacing: 14,
                children: [
                  _buildMetricCard(
                      'Annualized Volatility',
                      '${risk.annualizedVolatility.toStringAsFixed(2)}%',
                      '252-day historical standard deviation',
                      AppColors.market),
                  _buildMetricCard(
                      'Portfolio Beta (β)',
                      risk.beta.toStringAsFixed(2),
                      'Relative to S&P 500 benchmark',
                      AppColors.primaryLight),
                  _buildMetricCard(
                      'Sharpe Ratio',
                      risk.sharpeRatio.toStringAsFixed(2),
                      'Risk-adjusted return (Rf = 4.5%)',
                      AppColors.positive),
                  _buildMetricCard(
                      'Sortino Ratio',
                      risk.sortinoRatio.toStringAsFixed(2),
                      'Downside deviation penalty only',
                      AppColors.positive),
                  _buildMetricCard(
                      '1-Day 95% Historical VaR',
                      '\$${risk.var951d.toStringAsFixed(2)}',
                      'Expected max loss under normal conditions',
                      AppColors.warning),
                  _buildMetricCard(
                      '1-Day 95% CVaR (Expected Shortfall)',
                      '\$${risk.cvar951d.toStringAsFixed(2)}',
                      'Average tail loss beyond the 95% cutoff',
                      AppColors.negative),
                  _buildMetricCard(
                      'Maximum Drawdown (1Y)',
                      '${risk.maxDrawdown.toStringAsFixed(2)}%',
                      'Peak-to-trough decline',
                      AppColors.positive),
                  _buildMetricCard(
                      'Concentration Index (HHI)',
                      risk.hhiConcentration.toStringAsFixed(3),
                      'Herfindahl index (< 0.15 = Diversified)',
                      AppColors.aiViolet),
                ],
              ),
              const SizedBox(height: 24),

              // Correlation Matrix Heatmap & Stress Testing
              if (isCompact) ...[
                matrixAsync.when(
                  data: (matrix) => CorrelationHeatmapCard(data: matrix),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Heatmap error: $e'),
                ),
                const SizedBox(height: 20),
                _buildStressTestCard(),
              ] else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: matrixAsync.when(
                        data: (matrix) => CorrelationHeatmapCard(data: matrix),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text('Heatmap error: $e'),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: _buildStressTestCard(),
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

  Widget _buildMetricCard(String title, String val, String desc, Color color) {
    return Container(
      width: 230,
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
          Text(val,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 6),
          Text(desc,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary, height: 1.3)),
        ],
      ),
    );
  }

  Widget _buildStressTestCard() {
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
            'Historical Stress-Testing Simulation',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          const Text(
            'Applies historical macro shock factor returns to current holdings weights.',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          _buildScenarioRow('2020 COVID Liquidity Shock', '-14.8%', '-\$42,143',
              AppColors.negative),
          const SizedBox(height: 12),
          _buildScenarioRow('2022 Fed Rate Hike Tech Drawdown', '-18.2%',
              '-\$51,824', AppColors.negative),
          const SizedBox(height: 12),
          _buildScenarioRow('2008 Lehman GFC Credit Freeze', '-26.5%',
              '-\$75,458', AppColors.negative),
          const SizedBox(height: 12),
          _buildScenarioRow('2023 Post-SVB Tech Recovery Wave', '+24.1%',
              '+\$68,624', AppColors.positive),
        ],
      ),
    );
  }

  Widget _buildScenarioRow(
      String name, String pct, String impact, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(name,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(pct,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold, color: color)),
              Text(impact,
                  style:
                      TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
            ],
          ),
        ],
      ),
    );
  }
}
