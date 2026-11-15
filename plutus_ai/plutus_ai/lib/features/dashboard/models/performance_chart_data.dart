/// Available timeframes for portfolio chart analysis.
enum TimeRange {
  oneWeek('1W', '1 Week'),
  oneMonth('1M', '1 Month'),
  threeMonths('3M', '3 Months'),
  sixMonths('6M', '6 Months'),
  oneYear('1Y', '1 Year'),
  all('ALL', 'All Time');

  final String label;
  final String description;
  const TimeRange(this.label, this.description);
}

/// A single timestamped point on the performance chart.
class ChartPoint {
  final DateTime timestamp;
  final double value;

  const ChartPoint({
    required this.timestamp,
    required this.value,
  });
}

/// Chart dataset for a given timeframe range.
class PortfolioChartData {
  final TimeRange range;
  final List<ChartPoint> points;
  final double startingValue;
  final double endingValue;
  final double changeAmount;
  final double changePercentage;
  final double minValue;
  final double maxValue;

  const PortfolioChartData({
    required this.range,
    required this.points,
    required this.startingValue,
    required this.endingValue,
    required this.changeAmount,
    required this.changePercentage,
    required this.minValue,
    required this.maxValue,
  });

  bool get isPositive => changeAmount >= 0;
}
