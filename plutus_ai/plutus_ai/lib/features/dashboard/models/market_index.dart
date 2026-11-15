/// Benchmark market index summary for the overview.
class MarketIndex {
  final String symbol;
  final String name;
  final double value;
  final double change;
  final double changePercent;
  final List<double> sparkline;
  final bool isSample;
  final String currency;

  const MarketIndex({
    required this.symbol,
    required this.name,
    required this.value,
    required this.change,
    required this.changePercent,
    required this.sparkline,
    this.isSample = true,
    this.currency = 'USD',
  });

  bool get isPositive => change >= 0;
}
