from decimal import Decimal
from unittest.mock import patch
from django.core.cache import cache
from django.test import TestCase
from django.contrib.auth.models import User
from rest_framework.test import APIClient
from apps.portfolios.models import Portfolio, Transaction, TransactionType
from apps.portfolios.services import PortfolioLedgerService
from apps.market_data.models import Instrument, AssetType
from apps.analytics.services import FinancialAnalyticsService
from apps.assistant.services import DomainClassifier
from apps.wealth.services import WealthOptimizationService

class PlutusBackendTests(TestCase):
    def setUp(self):
        cache.clear()
        self.client = APIClient()
        self.user = User.objects.create_user(username='testtrader', password='TestPassword123!')
        self.client.force_authenticate(user=self.user)

        self.nvda = Instrument.objects.create(
            symbol='NVDA',
            name='NVIDIA Corporation',
            asset_type=AssetType.EQUITY,
            current_price=Decimal('135.00')
        )
        self.portfolio = Portfolio.objects.create(
            user=self.user,
            name='Test Tech Portfolio',
            cash_balance=Decimal('10000.00')
        )

    def test_ledger_holdings_calculation(self):
        # Buy 10 shares @ 100
        Transaction.objects.create(
            portfolio=self.portfolio,
            instrument=self.nvda,
            type=TransactionType.BUY,
            shares=Decimal('10'),
            price=Decimal('100.00'),
            amount=Decimal('1000.00'),
            fees=Decimal('0.00'),
            trade_date='2026-01-01T00:00:00Z'
        )
        # Buy 10 shares @ 120 -> total 20 shares, cost basis 110
        Transaction.objects.create(
            portfolio=self.portfolio,
            instrument=self.nvda,
            type=TransactionType.BUY,
            shares=Decimal('10'),
            price=Decimal('120.00'),
            amount=Decimal('1200.00'),
            fees=Decimal('0.00'),
            trade_date='2026-01-02T00:00:00Z'
        )
        holdings = PortfolioLedgerService.calculate_holdings(self.portfolio)
        self.assertEqual(len(holdings), 1)
        self.assertEqual(holdings[0]['symbol'], 'NVDA')
        self.assertEqual(holdings[0]['shares'], Decimal('20'))
        self.assertEqual(holdings[0]['avg_cost'], Decimal('110.00'))
        self.assertEqual(holdings[0]['market_value'], Decimal('2700.00')) # 20 * 135
        self.assertEqual(holdings[0]['gain_loss'], Decimal('500.00')) # 2700 - 2200

    def test_analytics_deterministic_metrics(self):
        risk = FinancialAnalyticsService.get_full_risk_profile(Decimal('250000.00'))
        self.assertIn('annualized_volatility', risk)
        self.assertIn('sharpe_ratio', risk)
        self.assertIn('sortino_ratio', risk)
        self.assertIn('var_95_1d', risk)
        self.assertIn('cvar_95_1d', risk)
        self.assertEqual(risk['status'], 'VERIFIED_CALCULATION')

    def test_domain_classifier(self):
        is_fin, _ = DomainClassifier.is_finance_related('What is my portfolio asset allocation?')
        self.assertTrue(is_fin)

        is_fin2, reason = DomainClassifier.is_finance_related('Can you write a poem about chocolate cake?')
        self.assertFalse(is_fin2)
        self.assertIn('exclusive', reason.lower())

    def test_wealth_optimization_tax_harvest(self):
        holdings = [
            {'symbol': 'BND', 'name': 'Vanguard Bond', 'gain_loss': -1500.0, 'asset_class': 'Fixed Income'},
            {'symbol': 'NVDA', 'name': 'NVIDIA', 'gain_loss': 5000.0, 'asset_class': 'Equities'}
        ]
        res = WealthOptimizationService.simulate_tax_loss_harvesting('US_FEDERAL', 2026, holdings)
        self.assertEqual(res['total_harvestable_loss'], 1500.0)
        self.assertGreater(res['estimated_tax_savings'], 0)
        self.assertEqual(len(res['harvestable_opportunities']), 1)
        self.assertEqual(res['harvestable_opportunities'][0]['substitute_asset']['symbol'], 'AGG')

    def test_auth_registration_and_token(self):
        unauth_client = APIClient()
        reg_resp = unauth_client.post('/api/v1/auth/register/', {
            'username': 'newuser',
            'email': 'new@plutus.ai',
            'password': 'ComplexPassword123!',
            'password2': 'ComplexPassword123!',
        })
        self.assertEqual(reg_resp.status_code, 201)

        token_resp = unauth_client.post('/api/v1/auth/token/', {
            'username': 'newuser',
            'password': 'ComplexPassword123!',
        })
        self.assertEqual(token_resp.status_code, 200)
        self.assertIn('access', token_resp.data)


    def test_auth_login_with_email(self):
        unauth_client = APIClient()
        user = User.objects.create_user(
            username='emailtrader',
            email='emailtrader@example.com',
            password='ComplexPassword123!',
        )
        response = unauth_client.post('/api/v1/auth/token/', {
            'username': 'EMAILTRADER@example.com',
            'password': 'ComplexPassword123!',
        })
        self.assertEqual(response.status_code, 200)
        self.assertIn('access', response.data)
        self.assertEqual(response.data['user']['id'], user.id)

    def test_profile_requires_authentication(self):
        unauth_client = APIClient()
        response = unauth_client.get('/api/v1/profile/')
        self.assertEqual(response.status_code, 401)

    def test_register_rejects_duplicate_email_case_insensitively(self):
        unauth_client = APIClient()
        User.objects.create_user(
            username='existing',
            email='same@example.com',
            password='ComplexPassword123!',
        )
        response = unauth_client.post('/api/v1/auth/register/', {
            'username': 'newuser',
            'email': 'SAME@example.com',
            'password': 'AnotherStrongPassword123!',
            'password2': 'AnotherStrongPassword123!',
        })
        self.assertEqual(response.status_code, 400)

    def test_dashboard_endpoint_uses_authenticated_user_records_without_demo_values(self):
        # setUp creates a funded portfolio for ledger tests. Use a separate user
        # to verify the empty-account response without inheriting that test data.
        empty_user = User.objects.create_user(
            username='emptydashboard', password='TestPassword123!'
        )
        empty_client = APIClient()
        empty_client.force_authenticate(user=empty_user)
        response = empty_client.get('/api/v1/dashboard/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['summary']['total_value'], 0.0)
        self.assertEqual(response.data['summary']['invested_capital'], 0.0)
        self.assertEqual(response.data['summary']['daily_change'], 0.0)
        self.assertFalse(response.data['summary']['daily_change_available'])
        self.assertEqual(response.data['holdings'], [])
        self.assertIsNone(response.data['risk_summary'])
        self.assertIsNone(response.data['ai_insight'])

    def test_dashboard_endpoint_requires_authentication(self):
        response = APIClient().get('/api/v1/dashboard/')
        self.assertEqual(response.status_code, 401)

    def test_market_instruments_endpoint(self):
        resp = self.client.get('/api/v1/market/instruments/')
        self.assertEqual(resp.status_code, 200)
        self.assertGreaterEqual(len(resp.data), 1)
        self.assertEqual(resp.data[0]['symbol'], 'NVDA')

    @patch('apps.market_data.views.get_market_data_provider')
    def test_market_quote_endpoint_uses_yfinance_provider(self, provider_factory):
        provider_factory.return_value.get_quote.return_value = {
            'symbol': 'NVDA', 'available': True, 'price': 150.0,
            'change': 2.0, 'change_percent': 1.35, 'previous_close': 148.0,
            'volume': 123456, 'currency': 'USD',
            'source': 'Yahoo Finance via yfinance (test response)',
            'timestamp': '2026-11-15T00:00:00+00:00',
        }
        response = self.client.get('/api/v1/market/instruments/NVDA/quote/')
        self.assertEqual(response.status_code, 200)
        self.assertTrue(response.data['available'])
        self.assertEqual(response.data['price'], 150.0)
        provider_factory.return_value.get_quote.assert_called_once_with('NVDA')

    @patch('apps.market_data.views.get_market_data_provider')
    def test_market_history_endpoint_uses_yfinance_provider(self, provider_factory):
        provider_factory.return_value.get_historical_ohlcv.return_value = [{
            'timestamp': '2026-11-14T00:00:00+00:00',
            'open': 148.0, 'high': 151.0, 'low': 147.0,
            'close': 150.0, 'volume': 123456,
            'source': 'Yahoo Finance via yfinance (historical)',
        }]
        response = self.client.get(
            '/api/v1/market/instruments/NVDA/history/?range=1mo&interval=1d'
        )
        self.assertEqual(response.status_code, 200)
        self.assertTrue(response.data['available'])
        self.assertEqual(len(response.data['data']), 1)
        provider_factory.return_value.get_historical_ohlcv.assert_called_once_with(
            'NVDA', period='1mo', interval='1d'
        )

    def test_portfolio_summary_endpoint(self):
        resp = self.client.get(f'/api/v1/portfolios/{self.portfolio.id}/summary/')
        self.assertEqual(resp.status_code, 200)
        self.assertIn('total_value', resp.data)

    def test_assistant_out_of_scope_rejection(self):
        resp = self.client.post('/api/v1/assistant/chat/', {
            'message': 'Who won the football game yesterday?'
        })
        self.assertEqual(resp.status_code, 200)
        self.assertFalse(resp.data['is_in_scope'])
        self.assertIn('exclusive', resp.data['reply'].lower())

    def test_research_models_endpoint(self):
        resp = self.client.get('/api/v1/research/models/')
        self.assertEqual(resp.status_code, 200)

    def test_alerts_endpoint(self):
        resp = self.client.get('/api/v1/alerts/')
        self.assertEqual(resp.status_code, 200)
