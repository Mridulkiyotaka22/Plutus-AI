/// Domain model representing portfolio headline metrics for the Financial Command Center.
class PortfolioMetrics {
  final double totalValue;
  final double investedCapital;
  final double dailyChangeAmount;
  final double dailyChangePercentage;
  final double totalGainAmount;
  final double totalGainPercentage;
  final DateTime lastUpdated;
  final bool isDemo;
  final String baseCurrency;
  final bool dailyChangeAvailable;

  String get currencySymbol => baseCurrency.toUpperCase() == 'INR' ? '₹' : (baseCurrency.toUpperCase() == 'EUR' ? '€' : (baseCurrency.toUpperCase() == 'GBP' ? '£' : '\$'));

  const PortfolioMetrics({
    required this.totalValue,
    required this.investedCapital,
    required this.dailyChangeAmount,
    required this.dailyChangePercentage,
    required this.totalGainAmount,
    required this.totalGainPercentage,
    required this.lastUpdated,
    this.isDemo = true,
    this.baseCurrency = 'INR',
    this.dailyChangeAvailable = true,
  });

  bool get isDailyPositive => dailyChangeAmount >= 0;
  bool get isOverallPositive => totalGainAmount >= 0;

  PortfolioMetrics copyWith({
    double? totalValue,
    double? investedCapital,
    double? dailyChangeAmount,
    double? dailyChangePercentage,
    double? totalGainAmount,
    double? totalGainPercentage,
    DateTime? lastUpdated,
    bool? isDemo,
    String? baseCurrency,
    bool? dailyChangeAvailable,
  }) {
    return PortfolioMetrics(
      totalValue: totalValue ?? this.totalValue,
      investedCapital: investedCapital ?? this.investedCapital,
      dailyChangeAmount: dailyChangeAmount ?? this.dailyChangeAmount,
      dailyChangePercentage:
          dailyChangePercentage ?? this.dailyChangePercentage,
      totalGainAmount: totalGainAmount ?? this.totalGainAmount,
      totalGainPercentage: totalGainPercentage ?? this.totalGainPercentage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isDemo: isDemo ?? this.isDemo,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      dailyChangeAvailable: dailyChangeAvailable ?? this.dailyChangeAvailable,
    );
  }
}
