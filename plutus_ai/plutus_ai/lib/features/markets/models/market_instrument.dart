import 'package:fl_chart/fl_chart.dart';

enum AssetCategory {
  all('All Assets'),
  equity('Equities'),
  crypto('Crypto'),
  fixedIncome('Fixed Income'),
  commodity('Commodities');

  final String label;
  const AssetCategory(this.label);
}

class MarketInstrument {
  final String symbol;
  final String name;
  final String exchange;
  final AssetCategory category;
  final double currentPrice;
  final double change;
  final double changePercent;
  final double volume;
  final double? marketCap;
  final double? peRatio;
  final double high52w;
  final double low52w;
  final List<FlSpot> sparklinePoints;
  final String sourceLabel;
  final String quoteCurrency;
  final bool hasQuote;

  const MarketInstrument({
    required this.symbol,
    required this.name,
    required this.exchange,
    required this.category,
    required this.currentPrice,
    required this.change,
    required this.changePercent,
    required this.volume,
    this.marketCap,
    this.peRatio,
    required this.high52w,
    required this.low52w,
    required this.sparklinePoints,
    this.sourceLabel = 'Provider data unavailable',
    this.quoteCurrency = 'USD',
    this.hasQuote = false,
  });

  bool get isPositive => change >= 0;
  String get currencySymbol => quoteCurrency.toUpperCase() == 'INR' ? '₹' : '\$';
  String formatPrice(double value) => '$currencySymbol${value.toStringAsFixed(2)}';

  factory MarketInstrument.fromJson(Map<String, dynamic> json) {
    AssetCategory cat = AssetCategory.equity;
    final catStr = json['asset_type']?.toString().toUpperCase() ?? '';
    if (catStr.contains('CRYPTO')) {
      cat = AssetCategory.crypto;
    } else if (catStr.contains('FIXED') || catStr.contains('BOND')) {
      cat = AssetCategory.fixedIncome;
    } else if (catStr.contains('COMMODITY')) {
      cat = AssetCategory.commodity;
    }

    double? number(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '');
    }

    final rawPrice = number(json['price'] ?? json['current_price']);
    final hasQuote = json['available'] == false
        ? false
        : rawPrice != null && rawPrice > 0;
    final price = hasQuote ? rawPrice! : 0.0;
    final rawHistory = (json['history'] as List<dynamic>?) ?? const [];
    final points = <FlSpot>[];
    for (var i = 0; i < rawHistory.length; i++) {
      final item = rawHistory[i];
      if (item is! Map<String, dynamic>) continue;
      final close = number(item['close'] ?? item['Close']);
      if (close != null && close > 0) {
        points.add(FlSpot(i.toDouble(), close));
      }
    }

    final currency = (json['quote_currency'] ?? json['currency'] ?? 'USD').toString();
    return MarketInstrument(
      symbol: json['symbol']?.toString() ?? '',
      name: json['name']?.toString() ?? json['symbol']?.toString() ?? 'Unknown instrument',
      exchange: json['exchange']?.toString() ?? '—',
      category: cat,
      currentPrice: price,
      change: hasQuote ? (number(json['change']) ?? 0.0) : 0.0,
      changePercent: hasQuote ? (number(json['change_percent']) ?? 0.0) : 0.0,
      volume: hasQuote ? (number(json['volume']) ?? 0.0) : 0.0,
      marketCap: number(json['market_cap']),
      peRatio: number(json['pe_ratio']),
      high52w: number(json['high_52w']) ?? 0.0,
      low52w: number(json['low_52w']) ?? 0.0,
      sparklinePoints: points,
      sourceLabel: json['source']?.toString() ?? 'Provider data unavailable',
      quoteCurrency: currency,
      hasQuote: hasQuote,
    );
  }
}
