import '../../markets/fixtures/demo_markets.dart';
import '../fixtures/demo_watchlists.dart';
import '../models/watchlist_model.dart';
import 'watchlists_repository.dart';

class MockWatchlistsRepository implements WatchlistsRepository {
  final List<WatchlistModel> _watchlists =
      List.from(DemoWatchlists.defaultWatchlists);

  @override
  Future<List<WatchlistModel>> getWatchlists() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _watchlists;
  }

  @override
  Future<WatchlistModel> createWatchlist(String name) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newWl = WatchlistModel(
      id: 'wl-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      isDefault: false,
      items: [],
    );
    _watchlists.add(newWl);
    return newWl;
  }

  @override
  Future<bool> addItem(String watchlistId, String symbol,
      {String? notes}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = _watchlists.indexWhere((w) => w.id == watchlistId);
    if (idx != -1) {
      final inst = DemoMarkets.instruments.firstWhere(
        (i) => i.symbol.toUpperCase() == symbol.toUpperCase(),
        orElse: () => DemoMarkets.instruments.first,
      );
      final newItem = WatchlistItemModel(
        id: 'wli-${DateTime.now().millisecondsSinceEpoch}',
        instrument: inst,
        notes: notes ?? 'Custom watch item',
      );
      final current = _watchlists[idx];
      _watchlists[idx] = WatchlistModel(
        id: current.id,
        name: current.name,
        isDefault: current.isDefault,
        items: [...current.items, newItem],
      );
      return true;
    }
    return false;
  }

  @override
  Future<bool> removeItem(String watchlistId, String itemId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = _watchlists.indexWhere((w) => w.id == watchlistId);
    if (idx != -1) {
      final current = _watchlists[idx];
      _watchlists[idx] = WatchlistModel(
        id: current.id,
        name: current.name,
        isDefault: current.isDefault,
        items: current.items.where((i) => i.id != itemId).toList(),
      );
      return true;
    }
    return false;
  }
}
