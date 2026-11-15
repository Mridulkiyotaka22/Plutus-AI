import '../../markets/models/market_instrument.dart';

class WatchlistItemModel {
  final String id;
  final MarketInstrument instrument;
  final String notes;

  const WatchlistItemModel({
    required this.id,
    required this.instrument,
    this.notes = '',
  });

  factory WatchlistItemModel.fromJson(Map<String, dynamic> json) {
    return WatchlistItemModel(
      id: json['id']?.toString() ?? '',
      instrument: MarketInstrument.fromJson(
          json['instrument'] as Map<String, dynamic>? ?? {}),
      notes: json['notes'] as String? ?? '',
    );
  }
}

class WatchlistModel {
  final String id;
  final String name;
  final bool isDefault;
  final List<WatchlistItemModel> items;

  const WatchlistModel({
    required this.id,
    required this.name,
    this.isDefault = false,
    required this.items,
  });

  factory WatchlistModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return WatchlistModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Watchlist',
      isDefault: json['is_default'] as bool? ?? false,
      items: rawItems
          .map((i) => WatchlistItemModel.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}
