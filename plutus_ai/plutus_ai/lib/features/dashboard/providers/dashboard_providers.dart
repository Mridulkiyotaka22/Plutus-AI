import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ai_insight.dart';
import '../models/asset_allocation.dart';
import '../models/holding_item.dart';
import '../models/market_index.dart';
import '../models/performance_chart_data.dart';
import '../models/portfolio_metrics.dart';
import '../models/risk_summary.dart';
import '../models/transaction_item.dart';
import '../../../config/env_config.dart';
import '../../../config/environment_provider.dart';
import '../repositories/api_dashboard_repository.dart';
import '../repositories/dashboard_repository.dart';
import '../repositories/mock_dashboard_repository.dart';

/// Repository provider for dashboard data fetching.
/// Can be overridden with an authenticated Django API repository in production.
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  if (environment == Environment.demo) return const MockDashboardRepository();
  return ApiDashboardRepository();
});

/// Selected timeframe range provider for the performance chart.
final selectedChartRangeProvider = StateProvider<TimeRange>((ref) {
  return TimeRange.oneMonth;
});

/// Portfolio metrics provider (value, invested, P&L, returns).
final portfolioMetricsProvider = FutureProvider<PortfolioMetrics>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getPortfolioMetrics();
});

/// Portfolio chart points provider, recomputed reactively when the selected timeframe changes.
final portfolioChartDataProvider =
    FutureProvider<PortfolioChartData>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  final range = ref.watch(selectedChartRangeProvider);
  return repository.getPerformanceChartData(range);
});

/// Asset allocation breakdown provider for the donut chart.
final assetAllocationProvider =
    FutureProvider<List<AssetAllocationItem>>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getAssetAllocation();
});

/// Market indices overview provider.
final marketIndicesProvider = FutureProvider<List<MarketIndex>>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getMarketIndices();
});

/// Top holdings table provider.
final topHoldingsProvider = FutureProvider<List<HoldingItem>>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getTopHoldings();
});

/// Recent transactions list provider.
final recentTransactionsProvider =
    FutureProvider<List<TransactionItem>>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getRecentTransactions();
});

/// Portfolio risk summary provider.
final riskSummaryProvider = FutureProvider<RiskSummary>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getRiskSummary();
});

/// Latest AI intelligence preview provider.
final latestAiInsightProvider = FutureProvider<AiInsight>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getLatestAiInsight();
});
