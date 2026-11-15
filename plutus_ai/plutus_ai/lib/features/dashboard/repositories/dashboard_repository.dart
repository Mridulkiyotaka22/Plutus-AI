import '../models/ai_insight.dart';
import '../models/asset_allocation.dart';
import '../models/holding_item.dart';
import '../models/market_index.dart';
import '../models/performance_chart_data.dart';
import '../models/portfolio_metrics.dart';
import '../models/risk_summary.dart';
import '../models/transaction_item.dart';

/// Abstract contract for dashboard financial data operations.
/// This decoupling ensures that future Django REST API integration will not require rewriting UI widgets.
abstract class DashboardRepository {
  Future<PortfolioMetrics> getPortfolioMetrics();
  Future<PortfolioChartData> getPerformanceChartData(TimeRange range);
  Future<List<AssetAllocationItem>> getAssetAllocation();
  Future<List<MarketIndex>> getMarketIndices();
  Future<List<HoldingItem>> getTopHoldings();
  Future<List<TransactionItem>> getRecentTransactions();
  Future<RiskSummary> getRiskSummary();
  Future<AiInsight> getLatestAiInsight();
}
