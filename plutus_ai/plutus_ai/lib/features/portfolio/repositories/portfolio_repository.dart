import '../models/portfolio_position.dart';

abstract class PortfolioRepository {
  Future<PortfolioSummaryData> getPortfolioSummary();
  Future<bool> addTransaction({
    required String symbol,
    required String type, // BUY or SELL
    required double shares,
    required double price,
    String? notes,
  });
}
