import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/dashboard_providers.dart';
import '../widgets/ai_insight_card.dart';
import '../widgets/asset_allocation_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/market_indices_card.dart';
import '../widgets/metric_card.dart';
import '../widgets/portfolio_chart_card.dart';
import '../widgets/recent_transactions_card.dart';
import '../widgets/risk_summary_card.dart';
import '../widgets/top_holdings_card.dart';

/// Financial Command Center Screen
/// Consolidated premium dark fintech dashboard featuring real-time KPI metrics,
/// interactive performance chart, asset allocation donut, benchmark indices,
/// top holdings, recent activity, risk diagnostics and PLUTUS AI insights.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(portfolioMetricsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard Top Header
              const DashboardHeader(),
              const SizedBox(height: 20),

              // KPI Metrics Row
              metricsAsync.when(
                data: (metrics) => LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final crossAxisCount =
                        width > 1050 ? 4 : (width > 600 ? 2 : 1);

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio:
                          width > 1050 ? 1.75 : (width > 600 ? 2.1 : 2.6),
                      children: [
                        MetricCard(
                          title: 'PORTFOLIO VALUE',
                          amount: metrics.totalValue,
                          changeAmount: metrics.dailyChangeAvailable ? metrics.dailyChangeAmount : null,
                          changePercentage: metrics.dailyChangeAvailable ? metrics.dailyChangePercentage : null,
                          currencySymbol: metrics.currencySymbol,
                          icon: Icons.account_balance_wallet_rounded,
                        ),
                        MetricCard(
                          title: 'INVESTED CAPITAL',
                          amount: metrics.investedCapital,
                          currencySymbol: metrics.currencySymbol,
                          icon: Icons.savings_rounded,
                        ),
                        MetricCard(
                          title: 'DAILY P&L',
                          amount: metrics.dailyChangeAmount,
                          changeAmount: metrics.dailyChangeAvailable ? metrics.dailyChangeAmount : null,
                          changePercentage: metrics.dailyChangeAvailable ? metrics.dailyChangePercentage : null,
                          currencySymbol: metrics.currencySymbol,
                          unavailableLabel: metrics.dailyChangeAvailable ? null : 'Not available',
                          icon: Icons.trending_up_rounded,
                        ),
                        MetricCard(
                          title: 'OVERALL RETURN',
                          amount: metrics.totalGainPercentage,
                          isCurrency: false,
                          changeAmount: metrics.totalGainAmount,
                          changePercentage: metrics.totalGainPercentage,
                          icon: Icons.insights_rounded,
                        ),
                      ],
                    );
                  },
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, _) => Center(
                  child: Text('Error loading metrics: $err'),
                ),
              ),
              const SizedBox(height: 20),

              // Main Responsive Layout Section
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 1050;

                  if (isDesktop) {
                    return const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left / Primary Column (Charts, Markets, Holdings, Transactions)
                        Expanded(
                          flex: 7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              PortfolioChartCard(),
                              SizedBox(height: 20),
                              MarketIndicesCard(),
                              SizedBox(height: 20),
                              TopHoldingsCard(),
                              SizedBox(height: 20),
                              RecentTransactionsCard(),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),

                        // Right / Secondary Column (Allocation, Risk, AI Insight)
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AssetAllocationCard(),
                              SizedBox(height: 20),
                              AiInsightCard(),
                              SizedBox(height: 20),
                              RiskSummaryCard(),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  // Tablet / Mobile Stacked Layout
                  return const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PortfolioChartCard(),
                      SizedBox(height: 18),
                      AssetAllocationCard(),
                      SizedBox(height: 18),
                      MarketIndicesCard(),
                      SizedBox(height: 18),
                      AiInsightCard(),
                      SizedBox(height: 18),
                      RiskSummaryCard(),
                      SizedBox(height: 18),
                      TopHoldingsCard(),
                      SizedBox(height: 18),
                      RecentTransactionsCard(),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
