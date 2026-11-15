import '../fixtures/demo_portfolio.dart';
import '../models/portfolio_position.dart';
import 'portfolio_repository.dart';

class MockPortfolioRepository implements PortfolioRepository {
  final List<PortfolioPosition> _positions = List.from(DemoPortfolio.positions);

  @override
  Future<PortfolioSummaryData> getPortfolioSummary() async {
    await Future.delayed(const Duration(milliseconds: 150));
    double totalVal = 22780.03; // cash
    for (final p in _positions) {
      totalVal += p.marketValue;
    }
    const invested = 234500.0;
    final gainLoss = totalVal - invested;

    return PortfolioSummaryData(
      portfolioId: 'pf-demo-001',
      portfolioName: 'Main Investment Portfolio',
      totalValue: totalVal,
      investedCapital: invested,
      totalGainLoss: gainLoss,
      totalReturnPercent: (gainLoss / invested) * 100,
      cashBalance: 22780.03,
      dailyChange: 3840.20,
      dailyChangePercent: 1.37,
      positions: _positions,
    );
  }

  @override
  Future<bool> addTransaction({
    required String symbol,
    required String type,
    required double shares,
    required double price,
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    // Simulate updating or adding position
    final existingIdx = _positions
        .indexWhere((p) => p.symbol.toUpperCase() == symbol.toUpperCase());
    if (type == 'BUY') {
      if (existingIdx != -1) {
        final ex = _positions[existingIdx];
        final newShares = ex.shares + shares;
        final totalCost = (ex.shares * ex.avgCost) + (shares * price);
        final newAvg = totalCost / newShares;
        final newMarketVal = newShares * price;
        final gainLoss = newMarketVal - totalCost;

        _positions[existingIdx] = PortfolioPosition(
          symbol: ex.symbol,
          name: ex.name,
          assetClass: ex.assetClass,
          shares: newShares,
          avgCost: newAvg,
          currentPrice: price,
          marketValue: newMarketVal,
          gainLoss: gainLoss,
          gainLossPercent: (gainLoss / totalCost) * 100,
          weight: 20.0,
        );
      } else {
        final totalCost = shares * price;
        _positions.add(PortfolioPosition(
          symbol: symbol.toUpperCase(),
          name: '$symbol Inc.',
          assetClass: 'Equities / Stocks',
          shares: shares,
          avgCost: price,
          currentPrice: price,
          marketValue: totalCost,
          gainLoss: 0.0,
          gainLossPercent: 0.0,
          weight: 5.0,
        ));
      }
    } else if (type == 'SELL') {
      if (existingIdx != -1) {
        final ex = _positions[existingIdx];
        final newShares = ex.shares - shares;
        if (newShares <= 0) {
          _positions.removeAt(existingIdx);
        } else {
          final newMarketVal = newShares * ex.currentPrice;
          final totalCost = newShares * ex.avgCost;
          final gainLoss = newMarketVal - totalCost;
          _positions[existingIdx] = PortfolioPosition(
            symbol: ex.symbol,
            name: ex.name,
            assetClass: ex.assetClass,
            shares: newShares,
            avgCost: ex.avgCost,
            currentPrice: ex.currentPrice,
            marketValue: newMarketVal,
            gainLoss: gainLoss,
            gainLossPercent: (gainLoss / totalCost) * 100,
            weight: 15.0,
          );
        }
      }
    }
    return true;
  }
}
