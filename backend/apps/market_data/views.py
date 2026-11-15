from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.shortcuts import get_object_or_404
from django.core.cache import cache
from django.conf import settings

from .models import Instrument, MarketPrice, BenchmarkIndex, Watchlist, WatchlistItem
from .serializers import (
    InstrumentSerializer, MarketPriceSerializer,
    BenchmarkIndexSerializer, WatchlistSerializer, WatchlistItemSerializer
)
from .providers import get_market_data_provider


class InstrumentListView(generics.ListAPIView):
    """Search the real instrument catalogue. Quotes are fetched separately."""
    serializer_class = InstrumentSerializer
    permission_classes = (permissions.AllowAny,)

    def get_queryset(self):
        queryset = Instrument.objects.filter(is_active=True)
        search = self.request.query_params.get('search', '').strip()
        asset_type = self.request.query_params.get('asset_type')
        if search:
            from django.db.models import Q
            queryset = queryset.filter(Q(symbol__icontains=search) | Q(name__icontains=search))
        if asset_type:
            queryset = queryset.filter(asset_type=asset_type.upper())
        return queryset.order_by('symbol')[:100]


class InstrumentDetailView(generics.RetrieveAPIView):
    queryset = Instrument.objects.filter(is_active=True)
    serializer_class = InstrumentSerializer
    permission_classes = (permissions.AllowAny,)
    lookup_field = 'symbol'


class InstrumentQuoteView(APIView):
    """Fetch a real latest-available quote from yfinance for a catalogue symbol."""
    permission_classes = (permissions.AllowAny,)

    def get(self, request, symbol):
        instrument = get_object_or_404(Instrument, symbol__iexact=symbol, is_active=True)
        cache_key = f"plutus:market:quote:{instrument.symbol}"
        cached = cache.get(cache_key)
        if cached is not None:
            return Response(cached)

        quote = get_market_data_provider().get_quote(instrument.symbol)
        if not quote:
            return Response({
                'symbol': instrument.symbol,
                'available': False,
                'message': 'No quote is currently available from the configured market-data provider.',
                'source': 'Yahoo Finance via yfinance',
            })

        # Store only real provider values; never substitute sample prices.
        from decimal import Decimal
        instrument.current_price = Decimal(str(quote['price']))
        if quote.get('change') is not None:
            instrument.change = Decimal(str(quote['change']))
        if quote.get('change_percent') is not None:
            instrument.change_percent = Decimal(str(quote['change_percent']))
        instrument.volume = int(quote.get('volume') or 0)
        if quote.get('currency'):
            instrument.quote_currency = quote['currency']
        instrument.save(update_fields=[
            'current_price', 'change', 'change_percent', 'volume',
            'quote_currency', 'updated_at'
        ])

        quote['quote_currency'] = instrument.quote_currency
        ttl = int(getattr(settings, 'MARKET_DATA_CACHE_TTL', 300))
        cache.set(cache_key, quote, max(30, min(ttl, 900)))
        return Response(quote)


class InstrumentHistoryView(APIView):
    permission_classes = (permissions.AllowAny,)

    def get(self, request, symbol):
        instrument = get_object_or_404(Instrument, symbol__iexact=symbol, is_active=True)
        period = request.query_params.get('range', '1mo')
        interval = request.query_params.get('interval')
        if not interval:
            interval = '5m' if period == '1d' else ('15m' if period == '5d' else '1d')
        try:
            records = get_market_data_provider().get_historical_ohlcv(
                instrument.symbol, period=period, interval=interval
            )
        except ValueError as exc:
            return Response({'detail': str(exc)}, status=status.HTTP_400_BAD_REQUEST)

        return Response({
            'symbol': instrument.symbol,
            'available': bool(records),
            'source': 'Yahoo Finance via yfinance (historical; may be delayed)',
            'period': period,
            'interval': interval,
            'data': records,
        })


class BenchmarkIndexListView(generics.ListAPIView):
    queryset = BenchmarkIndex.objects.all()
    serializer_class = BenchmarkIndexSerializer
    permission_classes = (permissions.AllowAny,)


class WatchlistListCreateView(generics.ListCreateAPIView):
    serializer_class = WatchlistSerializer
    permission_classes = (permissions.IsAuthenticated,)

    def get_queryset(self):
        return Watchlist.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class WatchlistDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = WatchlistSerializer
    permission_classes = (permissions.IsAuthenticated,)

    def get_queryset(self):
        return Watchlist.objects.filter(user=self.request.user)


class WatchlistItemCreateDeleteView(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request, watchlist_id):
        watchlist = get_object_or_404(Watchlist, id=watchlist_id, user=request.user)
        serializer = WatchlistItemSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        item = serializer.save(watchlist=watchlist)
        return Response(WatchlistItemSerializer(item).data, status=status.HTTP_201_CREATED)

    def delete(self, request, watchlist_id, item_id):
        watchlist = get_object_or_404(Watchlist, id=watchlist_id, user=request.user)
        item = get_object_or_404(WatchlistItem, id=item_id, watchlist=watchlist)
        item.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
