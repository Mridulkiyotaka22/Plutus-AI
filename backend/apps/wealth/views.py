from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import permissions, status
from apps.portfolios.models import Portfolio
from apps.portfolios.services import PortfolioLedgerService
from .services import WealthOptimizationService

class TaxHarvestSimulationView(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        jurisdiction = request.data.get('jurisdiction', 'US_FEDERAL')
        tax_year = request.data.get('tax_year', 2026)

        portfolio = Portfolio.objects.filter(user=request.user, is_default=True).first()
        holdings = PortfolioLedgerService.calculate_holdings(portfolio) if portfolio else []

        # If user has no holdings yet, fallback to default portfolio holdings for simulation
        if not holdings:
            holdings = [
                {'symbol': 'BND', 'name': 'Vanguard Total Bond ETF', 'shares': 650, 'gain_loss': -1365.00, 'asset_class': 'Fixed Income / Bonds'},
                {'symbol': 'NVDA', 'name': 'NVIDIA Corp', 'shares': 85, 'gain_loss': 14917.50, 'asset_class': 'Equities / Stocks'},
            ]

        result = WealthOptimizationService.simulate_tax_loss_harvesting(jurisdiction, tax_year, holdings)
        return Response(result)

class RebalanceSimulationView(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        target_allocation = request.data.get('target_allocation', {
            'Equities / Stocks': 40.0,
            'Fixed Income / Bonds': 25.0,
            'Crypto Assets': 10.0,
            'Commodities': 15.0,
            'Cash & Equivalents': 10.0,
        })

        portfolio = Portfolio.objects.filter(user=request.user, is_default=True).first()
        holdings = PortfolioLedgerService.calculate_holdings(portfolio) if portfolio else []

        if not holdings:
            holdings = [
                {'symbol': 'NVDA', 'asset_class': 'Equities / Stocks', 'market_value': 136680.19},
                {'symbol': 'BND', 'asset_class': 'Fixed Income / Bonds', 'market_value': 62645.09},
                {'symbol': 'BTC', 'asset_class': 'Crypto Assets', 'market_value': 34170.05},
                {'symbol': 'GLD', 'asset_class': 'Commodities', 'market_value': 28475.04},
                {'symbol': 'USD', 'asset_class': 'Cash & Equivalents', 'market_value': 22780.03},
            ]

        result = WealthOptimizationService.simulate_rebalancing(holdings, target_allocation)
        return Response(result)

class WealthProjectionView(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        initial = float(request.data.get('initial_capital', 284750.40))
        monthly = float(request.data.get('monthly_savings', 2500.00))
        years = int(request.data.get('years', 20))
        inflation = float(request.data.get('inflation_rate', 0.025))

        result = WealthOptimizationService.simulate_wealth_projections(
            current_net_worth=initial,
            monthly_savings=monthly,
            years=years,
            expected_inflation=inflation
        )
        return Response(result)
