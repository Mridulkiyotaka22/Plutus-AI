from rest_framework import serializers
from .models import Instrument, MarketPrice, BenchmarkIndex, Watchlist, WatchlistItem

class InstrumentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Instrument
        fields = [
            'id', 'symbol', 'name', 'exchange', 'asset_type',
            'quote_currency', 'current_price', 'change', 'change_percent',
            'volume', 'market_cap', 'pe_ratio', 'high_52w', 'low_52w', 'is_active'
        ]

class MarketPriceSerializer(serializers.ModelSerializer):
    class Meta:
        model = MarketPrice
        fields = ['timestamp', 'open', 'high', 'low', 'close', 'volume', 'source']

class BenchmarkIndexSerializer(serializers.ModelSerializer):
    class Meta:
        model = BenchmarkIndex
        fields = ['id', 'symbol', 'name', 'value', 'change', 'change_percent', 'sparkline', 'source_label']

class WatchlistItemSerializer(serializers.ModelSerializer):
    instrument = InstrumentSerializer(read_only=True)
    instrument_id = serializers.PrimaryKeyRelatedField(
        queryset=Instrument.objects.all(), source='instrument', write_only=True
    )

    class Meta:
        model = WatchlistItem
        fields = ['id', 'instrument', 'instrument_id', 'notes', 'created_at']

class WatchlistSerializer(serializers.ModelSerializer):
    items = WatchlistItemSerializer(many=True, read_only=True)
    item_count = serializers.SerializerMethodField()

    class Meta:
        model = Watchlist
        fields = ['id', 'name', 'is_default', 'item_count', 'items', 'created_at']
        read_only_fields = ['id', 'created_at']

    def get_item_count(self, obj):
        return obj.items.count()
