import '../models/market_instrument.dart';

abstract class MarketsRepository {
  Future<List<MarketInstrument>> getInstruments({String? search, AssetCategory? category});
  Future<MarketInstrument> getInstrumentDetail(String symbol, {String period = '1mo'});
}
