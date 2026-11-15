import '../../markets/fixtures/demo_markets.dart';
import '../models/watchlist_model.dart';

class DemoWatchlists {
  static List<WatchlistModel> get defaultWatchlists => [
        WatchlistModel(
          id: 'wl-001',
          name: 'Core Tech & Alpha',
          isDefault: true,
          items: [
            WatchlistItemModel(
              id: 'wli-1',
              instrument:
                  DemoMarkets.instruments.firstWhere((i) => i.symbol == 'NVDA'),
              notes: 'AI compute leadership',
            ),
            WatchlistItemModel(
              id: 'wli-2',
              instrument:
                  DemoMarkets.instruments.firstWhere((i) => i.symbol == 'AAPL'),
              notes: 'Ecosystem & buybacks',
            ),
            WatchlistItemModel(
              id: 'wli-3',
              instrument:
                  DemoMarkets.instruments.firstWhere((i) => i.symbol == 'MSFT'),
              notes: 'Enterprise cloud moat',
            ),
            WatchlistItemModel(
              id: 'wli-4',
              instrument:
                  DemoMarkets.instruments.firstWhere((i) => i.symbol == 'BTC'),
              notes: 'Digital store of value',
            ),
          ],
        ),
        WatchlistModel(
          id: 'wl-002',
          name: 'Defensive & Fixed Income',
          isDefault: false,
          items: [
            WatchlistItemModel(
              id: 'wli-5',
              instrument:
                  DemoMarkets.instruments.firstWhere((i) => i.symbol == 'BND'),
              notes: 'Duration risk hedging',
            ),
            WatchlistItemModel(
              id: 'wli-6',
              instrument:
                  DemoMarkets.instruments.firstWhere((i) => i.symbol == 'GLD'),
              notes: 'Monetary inflation hedge',
            ),
          ],
        ),
      ];
}
