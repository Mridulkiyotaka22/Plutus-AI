from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.shortcuts import get_object_or_404
from django.core.cache import cache
from django.conf import settings
from .models import Portfolio, Transaction, PortfolioSnapshot, TransactionType
from apps.market_data.providers import get_market_data_provider
from .serializers import PortfolioSerializer, TransactionSerializer, PortfolioSnapshotSerializer
from .services import PortfolioLedgerService

class PortfolioListCreateView(generics.ListCreateAPIView):
    serializer_class = PortfolioSerializer
    permission_classes = (permissions.IsAuthenticated,)

    def get_queryset(self):
        return Portfolio.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class PortfolioDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = PortfolioSerializer
    permission_classes = (permissions.IsAuthenticated,)

    def get_queryset(self):
        return Portfolio.objects.filter(user=self.request.user)

class PortfolioSummaryView(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request, pk):
        portfolio = get_object_or_404(Portfolio, id=pk, user=request.user)
        summary = PortfolioLedgerService.get_summary(portfolio)
        return Response(summary)

class PortfolioHoldingsView(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request, pk):
        portfolio = get_object_or_404(Portfolio, id=pk, user=request.user)
        holdings = PortfolioLedgerService.calculate_holdings(portfolio)
        return Response({'holdings': holdings})

class TransactionListCreateView(generics.ListCreateAPIView):
    serializer_class = TransactionSerializer
    permission_classes = (permissions.IsAuthenticated,)

    def get_queryset(self):
        portfolio_id = self.kwargs.get('portfolio_id')
        portfolio = get_object_or_404(Portfolio, id=portfolio_id, user=self.request.user)
        return Transaction.objects.filter(portfolio=portfolio)

    def perform_create(self, serializer):
        portfolio_id = self.kwargs.get('portfolio_id')
        portfolio = get_object_or_404(Portfolio, id=portfolio_id, user=self.request.user)

        # Check ledger constraint: cannot SELL more shares than currently owned
        tx_type = serializer.validated_data.get('type')
        if tx_type == TransactionType.SELL:
            instrument = serializer.validated_data.get('instrument')
            sell_shares = serializer.validated_data.get('shares', 0)
            holdings = PortfolioLedgerService.calculate_holdings(portfolio)
            owned_shares = next((h['shares'] for h in holdings if h['symbol'] == instrument.symbol), 0)
            if sell_shares > owned_shares:
                from rest_framework.exceptions import ValidationError
                raise ValidationError({
                    'shares': f'Cannot sell {sell_shares} shares. You currently own {owned_shares} shares of {instrument.symbol}.'
                })

        serializer.save(portfolio=portfolio)

class PortfolioAllocationView(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request, pk):
        portfolio = get_object_or_404(Portfolio, id=pk, user=request.user)
        holdings = PortfolioLedgerService.calculate_holdings(portfolio)
        total_market_val = sum(h['market_value'] for h in holdings)
        cash_val = float(portfolio.cash_balance)
        grand_total = total_market_val + cash_val

        categories = {}
        for h in holdings:
            cat = h['asset_class']
            categories[cat] = categories.get(cat, 0.0) + h['market_value']
        categories['Cash & Equivalents'] = cash_val

        allocation = []
        palette = {
            'Equities / Stocks': '#3B82F6',
            'Fixed Income / Bonds': '#10B981',
            'Crypto Assets': '#8B5CF6',
            'Commodities': '#F59E0B',
            'Cash & Equivalents': '#06B6D4',
        }

        for cat, val in categories.items():
            pct = round((val / grand_total * 100), 2) if grand_total > 0 else 0.0
            allocation.append({
                'category': cat,
                'amount': round(val, 2),
                'percentage': pct,
                'color': palette.get(cat, '#3B82F6'),
            })

        return Response({'allocation': sorted(allocation, key=lambda x: x['amount'], reverse=True)})


class DashboardOverviewView(APIView):
    """Return authenticated user's real dashboard records; never seed demo metrics."""
    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request):
        portfolio = Portfolio.objects.filter(user=request.user).order_by('-is_default', 'created_at').first()
        if portfolio is None:
            portfolio = Portfolio.objects.create(
                user=request.user,
                name='My Portfolio',
                base_currency='INR',
                is_default=True,
                cash_balance=0,
            )

        summary = PortfolioLedgerService.get_summary(portfolio)
        holdings = PortfolioLedgerService.calculate_holdings(portfolio)

        allocation = []
        categories = {}
        for holding in holdings:
            category = holding['asset_class']
            categories[category] = categories.get(category, 0.0) + holding['market_value']
        if float(portfolio.cash_balance) > 0:
            categories['Cash & Equivalents'] = float(portfolio.cash_balance)
        total = sum(categories.values())
        palette = {
            'Equities / Stocks': '#3B82F6',
            'Fixed Income / Bonds': '#10B981',
            'Crypto Assets': '#8B5CF6',
            'Commodities': '#F59E0B',
            'Cash & Equivalents': '#06B6D4',
        }
        for category, amount in categories.items():
            allocation.append({
                'category': category,
                'amount': round(amount, 2),
                'percentage': round(amount / total * 100, 2) if total > 0 else 0.0,
                'color': palette.get(category, '#3B82F6'),
            })
        allocation.sort(key=lambda item: item['amount'], reverse=True)

        transactions = Transaction.objects.filter(portfolio=portfolio).select_related('instrument')[:10]
        snapshots = PortfolioSnapshot.objects.filter(portfolio=portfolio).order_by('timestamp')
        # Fetch actual latest-available benchmark prices through the configured
        # market-data provider. No seeded/sample BenchmarkIndex prices are used.
        indices = cache.get('plutus:dashboard:yfinance:indices')
        if indices is None:
            indices = []
            provider = get_market_data_provider()
            benchmark_catalogue = [
                ('^NSEI', 'NIFTY 50', 'INR'),
                ('^BSESN', 'BSE SENSEX', 'INR'),
                ('^GSPC', 'S&P 500', 'USD'),
                ('^IXIC', 'NASDAQ Composite', 'USD'),
            ]
            for symbol, name, currency in benchmark_catalogue:
                try:
                    quote = provider.get_quote(symbol)
                    if not quote or not quote.get('available'):
                        continue
                    bars = provider.get_historical_ohlcv(symbol, period='5d', interval='1d')
                    indices.append({
                        'symbol': symbol,
                        'name': name,
                        'value': quote.get('price'),
                        'change': quote.get('change') or 0,
                        'change_percent': quote.get('change_percent') or 0,
                        'sparkline': [bar.get('close') for bar in bars if bar.get('close') is not None],
                        'source_label': quote.get('source', 'Yahoo Finance via yfinance'),
                        'currency': quote.get('currency') or currency,
                        'timestamp': quote.get('timestamp'),
                        'is_sample': False,
                    })
                except Exception:
                    # One unavailable benchmark must not break the dashboard.
                    continue
            cache.set(
                'plutus:dashboard:yfinance:indices',
                indices,
                max(60, min(int(getattr(settings, 'MARKET_DATA_CACHE_TTL', 300)), 900)),
            )

        return Response({
            'portfolio': PortfolioSerializer(portfolio).data,
            'summary': summary,
            'holdings': holdings,
            'allocation': allocation,
            'transactions': TransactionSerializer(transactions, many=True).data,
            'snapshots': PortfolioSnapshotSerializer(snapshots, many=True).data,
            'market_indices': indices,
            'risk_summary': None,
            'ai_insight': None,
        })
