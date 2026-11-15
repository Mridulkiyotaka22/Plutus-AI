import 'package:flutter_test/flutter_test.dart';
import 'package:plutus_ai/features/dashboard/models/performance_chart_data.dart';
import 'package:plutus_ai/features/dashboard/repositories/mock_dashboard_repository.dart';

void main() {
  group('MockDashboardRepository Tests', () {
    const repository = MockDashboardRepository();

    test('getPortfolioMetrics returns consistent demo data', () async {
      final metrics = await repository.getPortfolioMetrics();

      expect(metrics.isDemo, isTrue);
      expect(metrics.totalValue, equals(284750.40));
      expect(metrics.investedCapital, equals(240000.00));
      expect(metrics.totalGainAmount, equals(44750.40));
      expect(metrics.totalGainPercentage, equals(18.65));
      expect(metrics.isDailyPositive, isTrue);
      expect(metrics.isOverallPositive, isTrue);
    });

    test(
        'getPerformanceChartData returns valid data points for all time ranges',
        () async {
      for (final range in TimeRange.values) {
        final chartData = await repository.getPerformanceChartData(range);

        expect(chartData.range, equals(range));
        expect(chartData.points.isNotEmpty, isTrue);
        expect(chartData.endingValue, equals(284750.40));
        expect(chartData.changeAmount,
            equals(chartData.endingValue - chartData.startingValue));
      }
    });

    test('getAssetAllocation returns 5 categories totaling 100%', () async {
      final items = await repository.getAssetAllocation();

      expect(items.length, equals(5));
      final totalPercentage =
          items.fold<double>(0, (sum, i) => sum + i.percentage);
      expect(totalPercentage, closeTo(100.0, 0.01));
    });

    test('getMarketIndices returns major benchmark indices', () async {
      final indices = await repository.getMarketIndices();

      expect(indices.length, greaterThanOrEqualTo(5));
      expect(indices.any((idx) => idx.name == 'S&P 500'), isTrue);
      expect(indices.any((idx) => idx.name == 'NASDAQ 100'), isTrue);
      expect(indices.any((idx) => idx.name == 'Bitcoin'), isTrue);
      expect(indices.every((idx) => idx.isSample), isTrue);
    });

    test(
        'getTopHoldings returns portfolio positions with positive and negative positions',
        () async {
      final holdings = await repository.getTopHoldings();

      expect(holdings.length, greaterThanOrEqualTo(5));
      expect(holdings.any((h) => h.symbol == 'NVDA'), isTrue);
      expect(holdings.any((h) => h.symbol == 'BND'), isTrue);
    });

    test(
        'getRecentTransactions returns recent activity with completed demo status',
        () async {
      final txs = await repository.getRecentTransactions();

      expect(txs.isNotEmpty, isTrue);
      expect(txs.first.status, contains('DEMO'));
    });

    test('getRiskSummary returns valid quantitative ratios', () async {
      final risk = await repository.getRiskSummary();

      expect(risk.riskScore, inInclusiveRange(0, 100));
      expect(risk.beta, greaterThan(0));
      expect(risk.sharpeRatio, greaterThan(0));
      expect(risk.maxDrawdown, lessThan(0));
    });

    test('getLatestAiInsight returns strategic portfolio recommendation',
        () async {
      final insight = await repository.getLatestAiInsight();

      expect(insight.title.isNotEmpty, isTrue);
      expect(insight.confidenceScore, inInclusiveRange(80.0, 100.0));
      expect(insight.targetRoute, equals('/ai'));
    });
  });
}
