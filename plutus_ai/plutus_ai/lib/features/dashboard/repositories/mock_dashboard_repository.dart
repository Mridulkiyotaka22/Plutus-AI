import '../fixtures/dashboard_demo_data.dart';
import '../models/ai_insight.dart';
import '../models/asset_allocation.dart';
import '../models/holding_item.dart';
import '../models/market_index.dart';
import '../models/performance_chart_data.dart';
import '../models/portfolio_metrics.dart';
import '../models/risk_summary.dart';
import '../models/transaction_item.dart';
import 'dashboard_repository.dart';

/// Mock implementation of [DashboardRepository] backed by [DashboardDemoData].
/// Clearly marked DEMO fixtures ensure transparency and safety.
class MockDashboardRepository implements DashboardRepository {
  const MockDashboardRepository();

  @override
  Future<PortfolioMetrics> getPortfolioMetrics() async {
    // Simulated micro-delay for realistic async behavior in UI
    await Future.delayed(const Duration(milliseconds: 30));
    return DashboardDemoData.metrics;
  }

  @override
  Future<PortfolioChartData> getPerformanceChartData(TimeRange range) async {
    await Future.delayed(const Duration(milliseconds: 30));
    return DashboardDemoData.getChartData(range);
  }

  @override
  Future<List<AssetAllocationItem>> getAssetAllocation() async {
    await Future.delayed(const Duration(milliseconds: 30));
    return DashboardDemoData.assetAllocation;
  }

  @override
  Future<List<MarketIndex>> getMarketIndices() async {
    await Future.delayed(const Duration(milliseconds: 30));
    return DashboardDemoData.marketIndices;
  }

  @override
  Future<List<HoldingItem>> getTopHoldings() async {
    await Future.delayed(const Duration(milliseconds: 30));
    return DashboardDemoData.topHoldings;
  }

  @override
  Future<List<TransactionItem>> getRecentTransactions() async {
    await Future.delayed(const Duration(milliseconds: 30));
    return DashboardDemoData.recentTransactions;
  }

  @override
  Future<RiskSummary> getRiskSummary() async {
    await Future.delayed(const Duration(milliseconds: 30));
    return DashboardDemoData.riskSummary;
  }

  @override
  Future<AiInsight> getLatestAiInsight() async {
    await Future.delayed(const Duration(milliseconds: 30));
    return DashboardDemoData.latestAiInsight;
  }
}
