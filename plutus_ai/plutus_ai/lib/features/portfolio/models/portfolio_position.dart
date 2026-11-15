class PortfolioPosition {
  final String symbol;
  final String name;
  final String assetClass;
  final double shares;
  final double avgCost;
  final double currentPrice;
  final double marketValue;
  final double gainLoss;
  final double gainLossPercent;
  final double weight;

  const PortfolioPosition({
    required this.symbol,
    required this.name,
    required this.assetClass,
    required this.shares,
    required this.avgCost,
    required this.currentPrice,
    required this.marketValue,
    required this.gainLoss,
    required this.gainLossPercent,
    required this.weight,
  });

  bool get isPositive => gainLoss >= 0;

  factory PortfolioPosition.fromJson(Map<String, dynamic> json) {
    return PortfolioPosition(
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? json['symbol'] as String? ?? '',
      assetClass: json['asset_class'] as String? ?? 'Equities',
      shares: (json['shares'] as num?)?.toDouble() ?? 0.0,
      avgCost: (json['avg_cost'] as num?)?.toDouble() ?? 0.0,
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      marketValue: (json['market_value'] as num?)?.toDouble() ?? 0.0,
      gainLoss: (json['gain_loss'] as num?)?.toDouble() ?? 0.0,
      gainLossPercent: (json['gain_loss_percent'] as num?)?.toDouble() ?? 0.0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PortfolioSummaryData {
  final String portfolioId;
  final String portfolioName;
  final double totalValue;
  final double investedCapital;
  final double totalGainLoss;
  final double totalReturnPercent;
  final double cashBalance;
  final double dailyChange;
  final double dailyChangePercent;
  final List<PortfolioPosition> positions;

  const PortfolioSummaryData({
    required this.portfolioId,
    required this.portfolioName,
    required this.totalValue,
    required this.investedCapital,
    required this.totalGainLoss,
    required this.totalReturnPercent,
    required this.cashBalance,
    required this.dailyChange,
    required this.dailyChangePercent,
    required this.positions,
  });

  bool get isPositive => totalGainLoss >= 0;
}
