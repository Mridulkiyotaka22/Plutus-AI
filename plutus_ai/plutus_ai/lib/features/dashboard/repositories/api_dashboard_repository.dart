import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';
import '../models/ai_insight.dart';
import '../models/asset_allocation.dart';
import '../models/holding_item.dart';
import '../models/market_index.dart';
import '../models/performance_chart_data.dart';
import '../models/portfolio_metrics.dart';
import '../models/risk_summary.dart';
import '../models/transaction_item.dart';
import 'dashboard_repository.dart';

class ApiDashboardRepository implements DashboardRepository {
  ApiDashboardRepository();

  final ApiClient _client = ApiClient();
  Future<Map<String, dynamic>>? _dashboardFuture;

  Future<Map<String, dynamic>> _dashboard() {
    return _dashboardFuture ??= _client.dio.get<Map<String, dynamic>>('dashboard/').then(
      (response) => response.data ?? <String, dynamic>{},
    );
  }

  Map<String, dynamic> _summary(Map<String, dynamic> data) {
    final value = data['summary'];
    return value is Map<String, dynamic> ? value : <String, dynamic>{};
  }

  double _number(dynamic value) => value is num ? value.toDouble() : double.tryParse('$value') ?? 0.0;

  @override
  Future<PortfolioMetrics> getPortfolioMetrics() async {
    final data = await _dashboard();
    final summary = _summary(data);
    return PortfolioMetrics(
      totalValue: _number(summary['total_value']),
      investedCapital: _number(summary['invested_capital']),
      dailyChangeAmount: _number(summary['daily_change']),
      dailyChangePercentage: _number(summary['daily_change_pct']),
      totalGainAmount: _number(summary['overall_gain']),
      totalGainPercentage: _number(summary['overall_gain_pct']),
      lastUpdated: DateTime.now(),
      isDemo: false,
      baseCurrency: '${summary['base_currency'] ?? 'INR'}',
      dailyChangeAvailable: summary['daily_change_available'] == true,
    );
  }

  @override
  Future<PortfolioChartData> getPerformanceChartData(TimeRange range) async {
    final data = await _dashboard();
    final raw = (data['snapshots'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final now = DateTime.now();
    final cutoff = switch (range) {
      TimeRange.oneWeek => now.subtract(const Duration(days: 7)),
      TimeRange.oneMonth => now.subtract(const Duration(days: 30)),
      TimeRange.threeMonths => now.subtract(const Duration(days: 90)),
      TimeRange.sixMonths => now.subtract(const Duration(days: 180)),
      TimeRange.oneYear => now.subtract(const Duration(days: 365)),
      TimeRange.all => DateTime.fromMillisecondsSinceEpoch(0),
    };
    final points = raw.map((item) {
      return ChartPoint(
        timestamp: DateTime.tryParse('${item['timestamp']}') ?? now,
        value: _number(item['total_value']),
      );
    }).where((point) => !point.timestamp.isBefore(cutoff)).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final start = points.isEmpty ? 0.0 : points.first.value;
    final end = points.isEmpty ? 0.0 : points.last.value;
    final change = end - start;
    final pct = start > 0 ? change / start * 100 : 0.0;
    final values = points.map((point) => point.value).toList();
    return PortfolioChartData(
      range: range,
      points: points,
      startingValue: start,
      endingValue: end,
      changeAmount: change,
      changePercentage: pct,
      minValue: values.isEmpty ? 0 : values.reduce((a, b) => a < b ? a : b),
      maxValue: values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b),
    );
  }

  @override
  Future<List<AssetAllocationItem>> getAssetAllocation() async {
    final data = await _dashboard();
    return (data['allocation'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((item) => AssetAllocationItem(
              category: '${item['category'] ?? 'Other'}',
              amount: _number(item['amount']),
              percentage: _number(item['percentage']),
              color: _parseColor('${item['color'] ?? '#3B82F6'}'),
              assetCount: 0,
            ))
        .toList();
  }

  @override
  Future<List<MarketIndex>> getMarketIndices() async {
    final data = await _dashboard();
    return (data['market_indices'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((item) => MarketIndex(
              symbol: '${item['symbol'] ?? ''}',
              name: '${item['name'] ?? item['symbol'] ?? ''}',
              value: _number(item['value']),
              change: _number(item['change']),
              changePercent: _number(item['change_percent']),
              sparkline: (item['sparkline'] as List<dynamic>? ?? []).map(_number).toList(),
              isSample: false,
              currency: '${item['currency'] ?? 'USD'}',
            ))
        .toList();
  }

  @override
  Future<List<HoldingItem>> getTopHoldings() async {
    final data = await _dashboard();
    return (data['holdings'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((item) => HoldingItem(
              symbol: '${item['symbol'] ?? ''}',
              name: '${item['name'] ?? item['symbol'] ?? ''}',
              assetClass: '${item['asset_class'] ?? 'Unknown'}',
              shares: _number(item['shares']),
              avgCost: _number(item['avg_cost']),
              currentPrice: _number(item['current_price']),
              totalValue: _number(item['market_value']),
              allocationPercentage: _number(item['allocation_pct']),
              gainLossAmount: _number(item['gain_loss']),
              gainLossPercentage: _number(item['gain_loss_pct']),
            ))
        .toList();
  }

  @override
  Future<List<TransactionItem>> getRecentTransactions() async {
    final data = await _dashboard();
    return (data['transactions'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((item) {
          final instrument = item['instrument'] is Map<String, dynamic>
              ? item['instrument'] as Map<String, dynamic>
              : <String, dynamic>{};
          final symbol = '${instrument['symbol'] ?? 'CASH'}';
          final type = '${item['type'] ?? 'BUY'}'.toUpperCase();
          return TransactionItem(
            id: '${item['id'] ?? ''}',
            type: switch (type) {
              'SELL' => TransactionType.sell,
              'DIVIDEND' => TransactionType.dividend,
              'DEPOSIT' => TransactionType.deposit,
              'WITHDRAWAL' => TransactionType.withdrawal,
              _ => TransactionType.buy,
            },
            symbol: symbol,
            description: '${item['notes'] ?? '$type $symbol'}',
            amount: _number(item['amount']),
            shares: _number(item['shares']),
            price: _number(item['price']),
            date: DateTime.tryParse('${item['trade_date']}') ?? DateTime.now(),
            status: 'Recorded',
          );
        })
        .toList();
  }

  @override
  Future<RiskSummary> getRiskSummary() async {
    final data = await _dashboard();
    final raw = data['risk_summary'];
    if (raw is! Map<String, dynamic>) {
      return const RiskSummary(
        riskScore: 0,
        riskLevel: 'NOT AVAILABLE',
        beta: 0,
        sharpeRatio: 0,
        maxDrawdown: 0,
        valueAtRisk95: 0,
        riskAssessment: 'Risk metrics are not calculated yet. PLUTUS needs sufficient dated portfolio valuation history before reporting portfolio-specific risk.',
        available: false,
      );
    }
    return RiskSummary(
      riskScore: (raw['risk_score'] as num?)?.toInt() ?? 0,
      riskLevel: '${raw['risk_level'] ?? 'Not available'}',
      beta: _number(raw['beta']),
      sharpeRatio: _number(raw['sharpe_ratio']),
      maxDrawdown: _number(raw['max_drawdown']),
      valueAtRisk95: _number(raw['var_95_1d']),
      riskAssessment: '${raw['risk_assessment'] ?? raw['status'] ?? ''}',
      available: raw['status'] == 'VERIFIED_CALCULATION',
    );
  }

  @override
  Future<AiInsight> getLatestAiInsight() async {
    final data = await _dashboard();
    final raw = data['ai_insight'];
    if (raw is! Map<String, dynamic>) {
      return AiInsight(
        id: 'no-insight',
        title: 'No portfolio insight generated yet',
        summary: 'PLUTUS will show a portfolio-specific insight when verified portfolio activity and an AI analysis are available.',
        detailedAnalysis: 'No AI-generated analysis is being represented on this dashboard yet.',
        priority: InsightPriority.low,
        category: 'Information',
        confidenceScore: 0,
        generatedAt: DateTime.now(),
        suggestedAction: 'Add an investment transaction or ask the PLUTUS AI assistant a finance question.',
        targetRoute: '/portfolio',
      );
    }
    return AiInsight(
      id: '${raw['id'] ?? 'insight'}',
      title: '${raw['title'] ?? 'Portfolio insight'}',
      summary: '${raw['summary'] ?? ''}',
      detailedAnalysis: '${raw['detailed_analysis'] ?? ''}',
      priority: InsightPriority.low,
      category: '${raw['category'] ?? 'Portfolio'}',
      confidenceScore: _number(raw['confidence_score']),
      generatedAt: DateTime.tryParse('${raw['generated_at']}') ?? DateTime.now(),
      suggestedAction: '${raw['suggested_action'] ?? ''}',
      targetRoute: '${raw['target_route'] ?? '/ai'}',
    );
  }

  Color _parseColor(String value) {
    final hex = value.replaceFirst('#', '');
    final parsed = int.tryParse(hex, radix: 16) ?? 0x3B82F6;
    return Color(0xFF000000 | parsed);
  }
}
