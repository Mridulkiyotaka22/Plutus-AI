/// Individual portfolio holding representation.
class HoldingItem {
  final String symbol;
  final String name;
  final String assetClass;
  final double shares;
  final double avgCost;
  final double currentPrice;
  final double totalValue;
  final double allocationPercentage;
  final double gainLossAmount;
  final double gainLossPercentage;

  const HoldingItem({
    required this.symbol,
    required this.name,
    required this.assetClass,
    required this.shares,
    required this.avgCost,
    required this.currentPrice,
    required this.totalValue,
    required this.allocationPercentage,
    required this.gainLossAmount,
    required this.gainLossPercentage,
  });

  bool get isPositive => gainLossAmount >= 0;
}
