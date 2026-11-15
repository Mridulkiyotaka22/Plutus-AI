import '../fixtures/demo_markets.dart';
import '../models/market_instrument.dart';
import 'markets_repository.dart';

class MockMarketsRepository implements MarketsRepository {
  @override
  Future<List<MarketInstrument>> getInstruments(
      {String? search, AssetCategory? category}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var list = DemoMarkets.instruments;
    if (category != null && category != AssetCategory.all) {
      list = list.where((i) => i.category == category).toList();
    }
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      list = list
          .where((i) =>
              i.symbol.toLowerCase().contains(q) ||
              i.name.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  Future<MarketInstrument> getInstrumentDetail(String symbol, {String period = '1mo'}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return DemoMarkets.instruments.firstWhere(
      (i) => i.symbol.toUpperCase() == symbol.toUpperCase(),
      orElse: () => DemoMarkets.instruments.first,
    );
  }
}
