import 'package:flutter/material.dart';

import '../models/ai_insight.dart';
import '../models/asset_allocation.dart';
import '../models/holding_item.dart';
import '../models/market_index.dart';
import '../models/performance_chart_data.dart';
import '../models/portfolio_metrics.dart';
import '../models/risk_summary.dart';
import '../models/transaction_item.dart';

/// Centralized demo fixtures for the Financial Command Center.
/// All figures and records are clearly marked DEMO data.
class DashboardDemoData {
  DashboardDemoData._();

  static final PortfolioMetrics metrics = PortfolioMetrics(
    totalValue: 284750.40,
    investedCapital: 240000.00,
    dailyChangeAmount: 2840.50,
    dailyChangePercentage: 1.01,
    totalGainAmount: 44750.40,
    totalGainPercentage: 18.65,
    lastUpdated: DateTime.now(),
    isDemo: true,
    baseCurrency: 'USD',
  );

  static final List<AssetAllocationItem> assetAllocation = [
    const AssetAllocationItem(
      category: 'Equities',
      amount: 136680.19,
      percentage: 48.0,
      color: Color(0xFF3B82F6), // Blue
      assetCount: 14,
    ),
    const AssetAllocationItem(
      category: 'Fixed Income',
      amount: 62645.09,
      percentage: 22.0,
      color: Color(0xFF10B981), // Emerald
      assetCount: 5,
    ),
    const AssetAllocationItem(
      category: 'Crypto Assets',
      amount: 34170.05,
      percentage: 12.0,
      color: Color(0xFF8B5CF6), // Violet
      assetCount: 3,
    ),
    const AssetAllocationItem(
      category: 'Commodities',
      amount: 28475.04,
      percentage: 10.0,
      color: Color(0xFFF59E0B), // Amber
      assetCount: 2,
    ),
    const AssetAllocationItem(
      category: 'Cash & Equivalents',
      amount: 22780.03,
      percentage: 8.0,
      color: Color(0xFF06B6D4), // Cyan
      assetCount: 2,
    ),
  ];

  static final List<MarketIndex> marketIndices = [
    const MarketIndex(
      symbol: '^GSPC',
      name: 'S&P 500',
      value: 5864.67,
      change: 48.20,
      changePercent: 0.83,
      sparkline: [5810, 5824, 5818, 5840, 5852, 5864.67],
    ),
    const MarketIndex(
      symbol: '^IXIC',
      name: 'NASDAQ 100',
      value: 20412.35,
      change: 215.10,
      changePercent: 1.06,
      sparkline: [20180, 20220, 20290, 20350, 20380, 20412.35],
    ),
    const MarketIndex(
      symbol: '^DJI',
      name: 'Dow Jones',
      value: 43729.34,
      change: 124.80,
      changePercent: 0.29,
      sparkline: [43600, 43650, 43620, 43690, 43710, 43729.34],
    ),
    const MarketIndex(
      symbol: '^NSEI',
      name: 'NIFTY 50',
      value: 24180.80,
      change: 168.45,
      changePercent: 0.70,
      sparkline: [23980, 24040, 24090, 24120, 24150, 24180.80],
    ),
    const MarketIndex(
      symbol: 'BTC-USD',
      name: 'Bitcoin',
      value: 68420.00,
      change: 1450.00,
      changePercent: 2.17,
      sparkline: [66500, 66800, 67200, 67800, 68100, 68420.00],
    ),
    const MarketIndex(
      symbol: '^TNX',
      name: '10-Yr Yield',
      value: 4.38,
      change: -0.04,
      changePercent: -0.90,
      sparkline: [4.45, 4.43, 4.41, 4.42, 4.40, 4.38],
    ),
  ];

  static final List<HoldingItem> topHoldings = [
    const HoldingItem(
      symbol: 'NVDA',
      name: 'NVIDIA Corporation',
      assetClass: 'Equities',
      shares: 85,
      avgCost: 310.00,
      currentPrice: 485.50,
      totalValue: 41267.50,
      allocationPercentage: 14.49,
      gainLossAmount: 14917.50,
      gainLossPercentage: 56.61,
    ),
    const HoldingItem(
      symbol: 'MSFT',
      name: 'Microsoft Corporation',
      assetClass: 'Equities',
      shares: 90,
      avgCost: 340.00,
      currentPrice: 415.20,
      totalValue: 37368.00,
      allocationPercentage: 13.12,
      gainLossAmount: 6768.00,
      gainLossPercentage: 22.12,
    ),
    const HoldingItem(
      symbol: 'AAPL',
      name: 'Apple Inc.',
      assetClass: 'Equities',
      shares: 180,
      avgCost: 168.20,
      currentPrice: 192.80,
      totalValue: 34704.00,
      allocationPercentage: 12.19,
      gainLossAmount: 4428.00,
      gainLossPercentage: 14.63,
    ),
    const HoldingItem(
      symbol: 'BTC',
      name: 'Bitcoin',
      assetClass: 'Crypto',
      shares: 0.45,
      avgCost: 52000.00,
      currentPrice: 68400.00,
      totalValue: 30780.00,
      allocationPercentage: 10.81,
      gainLossAmount: 7380.00,
      gainLossPercentage: 31.54,
    ),
    const HoldingItem(
      symbol: 'BND',
      name: 'Vanguard Total Bond ETF',
      assetClass: 'Fixed Income',
      shares: 650,
      avgCost: 75.20,
      currentPrice: 73.10,
      totalValue: 47515.00,
      allocationPercentage: 16.69,
      gainLossAmount: -1365.00,
      gainLossPercentage: -2.79,
    ),
    const HoldingItem(
      symbol: 'GLD',
      name: 'SPDR Gold Shares',
      assetClass: 'Commodities',
      shares: 120,
      avgCost: 185.00,
      currentPrice: 218.40,
      totalValue: 26208.00,
      allocationPercentage: 9.20,
      gainLossAmount: 4008.00,
      gainLossPercentage: 18.05,
    ),
  ];

  static final List<TransactionItem> recentTransactions = [
    TransactionItem(
      id: 'tx-001',
      type: TransactionType.buy,
      symbol: 'NVDA',
      description: 'Purchased 10 shares of NVDA',
      amount: 4625.00,
      shares: 10,
      price: 462.50,
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    TransactionItem(
      id: 'tx-002',
      type: TransactionType.dividend,
      symbol: 'MSFT',
      description: 'Quarterly dividend payment received',
      amount: 245.50,
      date: DateTime.now().subtract(const Duration(days: 4)),
    ),
    TransactionItem(
      id: 'tx-003',
      type: TransactionType.buy,
      symbol: 'AAPL',
      description: 'Purchased 15 shares of AAPL',
      amount: 2838.00,
      shares: 15,
      price: 189.20,
      date: DateTime.now().subtract(const Duration(days: 7)),
    ),
    TransactionItem(
      id: 'tx-004',
      type: TransactionType.deposit,
      symbol: 'USD',
      description: 'Automated ACH deposit from checking',
      amount: 10000.00,
      date: DateTime.now().subtract(const Duration(days: 11)),
    ),
    TransactionItem(
      id: 'tx-005',
      type: TransactionType.sell,
      symbol: 'TSLA',
      description: 'Sold 12 shares of TSLA',
      amount: 2688.00,
      shares: 12,
      price: 224.00,
      date: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  static const RiskSummary riskSummary = RiskSummary(
    riskScore: 68,
    riskLevel: 'Moderate-Aggressive',
    beta: 1.14,
    sharpeRatio: 1.88,
    maxDrawdown: -13.8,
    valueAtRisk95: 4250.00,
    riskAssessment:
        'Portfolio risk profile is balanced with growth tilt. Mega-cap tech exposure is the primary driver of beta (1.14), offset by defensive fixed income allocation.',
  );

  static final AiInsight latestAiInsight = AiInsight(
    id: 'insight-001',
    title: 'Portfolio Sector Drift Alert: Tech Weighting +7.8%',
    summary:
        'Strong capital appreciation in NVDA and MSFT has expanded tech exposure to 39.8% of your total equity basket, exceeding your 32% strategic allocation threshold.',
    detailedAnalysis:
        'PLUTUS AI multi-factor analysis indicates upcoming macroeconomic rate decision volatility. Shifting \$8,500 from NVDA profits into short-duration Treasury ETFs will lower overall portfolio beta from 1.14 to 1.02 while preserving dividend yield.',
    priority: InsightPriority.high,
    category: 'Asset Allocation & Risk',
    confidenceScore: 94.2,
    generatedAt: DateTime.now().subtract(const Duration(hours: 3)),
    suggestedAction: 'Review Rebalancing Recommendations in PLUTUS AI',
    targetRoute: '/ai',
  );

  /// Generates dynamic chart data points for the given time range.
  static PortfolioChartData getChartData(TimeRange range) {
    final now = DateTime.now();
    final List<ChartPoint> points = [];

    switch (range) {
      case TimeRange.oneWeek:
        final baseValues = [
          281909.90,
          282450.10,
          281800.50,
          283120.00,
          282900.20,
          283890.80,
          284750.40
        ];
        for (int i = 0; i < baseValues.length; i++) {
          points.add(ChartPoint(
            timestamp: now.subtract(Duration(days: 6 - i)),
            value: baseValues[i],
          ));
        }
        return PortfolioChartData(
          range: range,
          points: points,
          startingValue: baseValues.first,
          endingValue: baseValues.last,
          changeAmount: baseValues.last - baseValues.first,
          changePercentage:
              ((baseValues.last - baseValues.first) / baseValues.first) * 100,
          minValue: 281500,
          maxValue: 285000,
        );

      case TimeRange.oneMonth:
        final baseValues = [
          274200.00,
          275100.50,
          273800.00,
          276400.20,
          278150.00,
          277900.10,
          279500.80,
          281200.00,
          282100.40,
          284750.40,
        ];
        for (int i = 0; i < baseValues.length; i++) {
          points.add(ChartPoint(
            timestamp:
                now.subtract(Duration(days: (baseValues.length - 1 - i) * 3)),
            value: baseValues[i],
          ));
        }
        return PortfolioChartData(
          range: range,
          points: points,
          startingValue: baseValues.first,
          endingValue: baseValues.last,
          changeAmount: baseValues.last - baseValues.first,
          changePercentage:
              ((baseValues.last - baseValues.first) / baseValues.first) * 100,
          minValue: 272000,
          maxValue: 286000,
        );

      case TimeRange.threeMonths:
        final baseValues = [
          261800.00,
          264200.00,
          262900.00,
          267400.00,
          269800.00,
          273100.00,
          275600.00,
          278900.00,
          281400.00,
          284750.40,
        ];
        for (int i = 0; i < baseValues.length; i++) {
          points.add(ChartPoint(
            timestamp:
                now.subtract(Duration(days: (baseValues.length - 1 - i) * 9)),
            value: baseValues[i],
          ));
        }
        return PortfolioChartData(
          range: range,
          points: points,
          startingValue: baseValues.first,
          endingValue: baseValues.last,
          changeAmount: baseValues.last - baseValues.first,
          changePercentage:
              ((baseValues.last - baseValues.first) / baseValues.first) * 100,
          minValue: 260000,
          maxValue: 286000,
        );

      case TimeRange.sixMonths:
        final baseValues = [
          252000.00,
          255400.00,
          253100.00,
          259600.00,
          264800.00,
          268200.00,
          272500.00,
          277100.00,
          280900.00,
          284750.40,
        ];
        for (int i = 0; i < baseValues.length; i++) {
          points.add(ChartPoint(
            timestamp:
                now.subtract(Duration(days: (baseValues.length - 1 - i) * 18)),
            value: baseValues[i],
          ));
        }
        return PortfolioChartData(
          range: range,
          points: points,
          startingValue: baseValues.first,
          endingValue: baseValues.last,
          changeAmount: baseValues.last - baseValues.first,
          changePercentage:
              ((baseValues.last - baseValues.first) / baseValues.first) * 100,
          minValue: 250000,
          maxValue: 286000,
        );

      case TimeRange.oneYear:
        final baseValues = [
          239500.00,
          242000.00,
          246500.00,
          244200.00,
          251000.00,
          258300.00,
          263900.00,
          269400.00,
          275800.00,
          284750.40,
        ];
        for (int i = 0; i < baseValues.length; i++) {
          points.add(ChartPoint(
            timestamp:
                now.subtract(Duration(days: (baseValues.length - 1 - i) * 36)),
            value: baseValues[i],
          ));
        }
        return PortfolioChartData(
          range: range,
          points: points,
          startingValue: baseValues.first,
          endingValue: baseValues.last,
          changeAmount: baseValues.last - baseValues.first,
          changePercentage:
              ((baseValues.last - baseValues.first) / baseValues.first) * 100,
          minValue: 235000,
          maxValue: 288000,
        );

      case TimeRange.all:
        final baseValues = [
          195000.00,
          208000.00,
          219500.00,
          212000.00,
          228000.00,
          239500.00,
          251000.00,
          263900.00,
          275800.00,
          284750.40,
        ];
        for (int i = 0; i < baseValues.length; i++) {
          points.add(ChartPoint(
            timestamp:
                now.subtract(Duration(days: (baseValues.length - 1 - i) * 72)),
            value: baseValues[i],
          ));
        }
        return PortfolioChartData(
          range: range,
          points: points,
          startingValue: baseValues.first,
          endingValue: baseValues.last,
          changeAmount: baseValues.last - baseValues.first,
          changePercentage:
              ((baseValues.last - baseValues.first) / baseValues.first) * 100,
          minValue: 190000,
          maxValue: 290000,
        );
    }
  }
}
