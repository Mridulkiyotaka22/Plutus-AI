import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/env_config.dart';
import '../../../config/environment_provider.dart';
import '../models/market_instrument.dart';
import '../repositories/api_markets_repository.dart';
import '../repositories/markets_repository.dart';
import '../repositories/mock_markets_repository.dart';

final marketsRepositoryProvider = Provider<MarketsRepository>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  if (environment == Environment.demo) return MockMarketsRepository();
  return ApiMarketsRepository();
});

final selectedCategoryProvider = StateProvider<AssetCategory>((ref) => AssetCategory.all);
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedInstrumentSymbolProvider = StateProvider<String>((ref) => 'NVDA');
final selectedMarketRangeProvider = StateProvider<String>((ref) => '1mo');

final marketInstrumentsProvider = FutureProvider<List<MarketInstrument>>((ref) async {
  final repo = ref.watch(marketsRepositoryProvider);
  final category = ref.watch(selectedCategoryProvider);
  final search = ref.watch(searchQueryProvider);
  return repo.getInstruments(search: search, category: category);
});

final selectedInstrumentDetailProvider = FutureProvider<MarketInstrument>((ref) async {
  final repo = ref.watch(marketsRepositoryProvider);
  final symbol = ref.watch(selectedInstrumentSymbolProvider);
  final period = ref.watch(selectedMarketRangeProvider);
  return repo.getInstrumentDetail(symbol, period: period);
});
