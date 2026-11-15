import os
from datetime import datetime, timedelta
from decimal import Decimal
from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from apps.accounts.models import UserProfile
from apps.market_data.models import Instrument, MarketPrice, BenchmarkIndex, Watchlist, WatchlistItem, AssetType
from apps.portfolios.models import Portfolio, Transaction, TransactionType, PortfolioSnapshot
from apps.behavioural_finance.models import Question, QuestionOption, BehaviouralProfile
from apps.research.models import ResearchModel, ModelEvaluation, ModelStatus
from apps.alerts.models import Alert, AlertPreference, AlertPriority, AlertCategory

class Command(BaseCommand):
    help = 'Seeds deterministic demo data matching PLUTUS AI specifications'

    def handle(self, *args, **kwargs):
        self.stdout.write(self.style.NOTICE('Starting PLUTUS AI demo data seed...'))

        # 1. Create or get Demo User
        demo_user, created = User.objects.get_or_create(
            username='demo_user',
            defaults={
                'email': 'demo@plutus.ai',
                'first_name': 'Mridul',
                'last_name': 'Investor',
            }
        )
        demo_user.set_password('PlutusDemo123!')
        demo_user.save()

        # Update profile
        profile, _ = UserProfile.objects.get_or_create(user=demo_user)
        profile.base_currency = 'USD'
        profile.tax_jurisdiction = 'US_FEDERAL'
        profile.save()

        # Admin user
        admin_user, _ = User.objects.get_or_create(
            username='admin',
            defaults={
                'email': 'admin@plutus.ai',
                'is_staff': True,
                'is_superuser': True,
            }
        )
        admin_user.set_password('AdminPass123!')
        admin_user.save()

        self.stdout.write(self.style.SUCCESS(f'Created users: {demo_user.username}, {admin_user.username}'))

        # 2. Seed Instruments
        instruments_data = [
            {
                'symbol': 'NVDA', 'name': 'NVIDIA Corporation', 'exchange': 'NASDAQ',
                'asset_type': AssetType.EQUITY, 'current_price': Decimal('138.25'),
                'change': Decimal('4.15'), 'change_percent': Decimal('3.10'),
                'volume': 42800000, 'market_cap': Decimal('3400000000000'), 'pe_ratio': Decimal('52.4'),
                'high_52w': Decimal('140.76'), 'low_52w': Decimal('45.20')
            },
            {
                'symbol': 'AAPL', 'name': 'Apple Inc.', 'exchange': 'NASDAQ',
                'asset_type': AssetType.EQUITY, 'current_price': Decimal('228.40'),
                'change': Decimal('1.20'), 'change_percent': Decimal('0.53'),
                'volume': 38200000, 'market_cap': Decimal('3510000000000'), 'pe_ratio': Decimal('34.2'),
                'high_52w': Decimal('237.23'), 'low_52w': Decimal('164.08')
            },
            {
                'symbol': 'MSFT', 'name': 'Microsoft Corporation', 'exchange': 'NASDAQ',
                'asset_type': AssetType.EQUITY, 'current_price': Decimal('428.15'),
                'change': Decimal('-2.45'), 'change_percent': Decimal('-0.57'),
                'volume': 19500000, 'market_cap': Decimal('3180000000000'), 'pe_ratio': Decimal('36.1'),
                'high_52w': Decimal('468.35'), 'low_52w': Decimal('366.50')
            },
            {
                'symbol': 'BTC', 'name': 'Bitcoin / USD', 'exchange': 'CRYPTO',
                'asset_type': AssetType.CRYPTO, 'current_price': Decimal('89450.00'),
                'change': Decimal('2150.00'), 'change_percent': Decimal('2.46'),
                'volume': 28400000000, 'market_cap': Decimal('1760000000000'), 'pe_ratio': None,
                'high_52w': Decimal('93400.00'), 'low_52w': Decimal('38500.00')
            },
            {
                'symbol': 'ETH', 'name': 'Ethereum / USD', 'exchange': 'CRYPTO',
                'asset_type': AssetType.CRYPTO, 'current_price': Decimal('3180.50'),
                'change': Decimal('65.20'), 'change_percent': Decimal('2.09'),
                'volume': 14200000000, 'market_cap': Decimal('382000000000'), 'pe_ratio': None,
                'high_52w': Decimal('4090.00'), 'low_52w': Decimal('2150.00')
            },
            {
                'symbol': 'BND', 'name': 'Vanguard Total Bond Market ETF', 'exchange': 'NASDAQ',
                'asset_type': AssetType.FIXED_INCOME, 'current_price': Decimal('72.40'),
                'change': Decimal('-0.15'), 'change_percent': Decimal('-0.21'),
                'volume': 5400000, 'market_cap': Decimal('108000000000'), 'pe_ratio': None,
                'high_52w': Decimal('75.80'), 'low_52w': Decimal('69.10')
            },
            {
                'symbol': 'GLD', 'name': 'SPDR Gold Shares', 'exchange': 'NYSE Arca',
                'asset_type': AssetType.COMMODITY, 'current_price': Decimal('242.80'),
                'change': Decimal('1.65'), 'change_percent': Decimal('0.68'),
                'volume': 4100000, 'market_cap': Decimal('72000000000'), 'pe_ratio': None,
                'high_52w': Decimal('258.40'), 'low_52w': Decimal('182.50')
            },
            {
                'symbol': 'GOOGL', 'name': 'Alphabet Inc.', 'exchange': 'NASDAQ',
                'asset_type': AssetType.EQUITY, 'current_price': Decimal('178.60'),
                'change': Decimal('2.80'), 'change_percent': Decimal('1.59'),
                'volume': 21400000, 'market_cap': Decimal('2210000000000'), 'pe_ratio': Decimal('25.8'),
                'high_52w': Decimal('191.75'), 'low_52w': Decimal('129.40')
            },
        ]

        inst_objects = {}
        for item in instruments_data:
            inst, _ = Instrument.objects.update_or_create(
                symbol=item['symbol'],
                defaults=item
            )
            inst_objects[inst.symbol] = inst

        self.stdout.write(self.style.SUCCESS(f'Seeded {len(inst_objects)} instruments.'))

        # Seed Benchmark Indices
        indices_data = [
            {'symbol': '^GSPC', 'name': 'S&P 500', 'value': Decimal('5892.40'), 'change': Decimal('24.80'), 'change_percent': Decimal('0.42')},
            {'symbol': '^IXIC', 'name': 'NASDAQ Composite', 'value': Decimal('18780.20'), 'change': Decimal('142.60'), 'change_percent': Decimal('0.77')},
            {'symbol': '^FTSE', 'name': 'FTSE 100', 'value': Decimal('8140.10'), 'change': Decimal('-12.40'), 'change_percent': Decimal('-0.15')},
            {'symbol': '^NSEI', 'name': 'NIFTY 50', 'value': Decimal('23850.50'), 'change': Decimal('110.20'), 'change_percent': Decimal('0.46')},
        ]
        for idx in indices_data:
            BenchmarkIndex.objects.update_or_create(symbol=idx['symbol'], defaults=idx)

        # 3. Seed Portfolio & Transactions
        portfolio, _ = Portfolio.objects.get_or_create(
            user=demo_user,
            is_default=True,
            defaults={
                'name': 'Main Investment Portfolio',
                'base_currency': 'USD',
                'cash_balance': Decimal('22780.03'),
            }
        )

        # Transactions
        now = datetime.now()
        tx_data = [
            {'inst': 'NVDA', 'type': TransactionType.BUY, 'shares': Decimal('450'), 'price': Decimal('105.10'), 'amount': Decimal('47295.00'), 'days': 90},
            {'inst': 'AAPL', 'type': TransactionType.BUY, 'shares': Decimal('220'), 'price': Decimal('210.00'), 'amount': Decimal('46200.00'), 'days': 85},
            {'inst': 'MSFT', 'type': TransactionType.BUY, 'shares': Decimal('100'), 'price': Decimal('415.00'), 'amount': Decimal('41500.00'), 'days': 80},
            {'inst': 'BTC', 'type': TransactionType.BUY, 'shares': Decimal('0.38'), 'price': Decimal('64500.00'), 'amount': Decimal('24510.00'), 'days': 75},
            {'inst': 'BND', 'type': TransactionType.BUY, 'shares': Decimal('650'), 'price': Decimal('74.50'), 'amount': Decimal('48425.00'), 'days': 70},
            {'inst': 'GLD', 'type': TransactionType.BUY, 'shares': Decimal('110'), 'price': Decimal('225.00'), 'amount': Decimal('24750.00'), 'days': 60},
            {'inst': 'NVDA', 'type': TransactionType.BUY, 'shares': Decimal('85'), 'price': Decimal('120.50'), 'amount': Decimal('10242.50'), 'days': 30},
        ]

        Transaction.objects.filter(portfolio=portfolio).delete()
        for tx in tx_data:
            Transaction.objects.create(
                portfolio=portfolio,
                instrument=inst_objects[tx['inst']],
                type=tx['type'],
                shares=tx['shares'],
                price=tx['price'],
                amount=tx['amount'],
                fees=Decimal('0.00'),
                trade_date=now - timedelta(days=tx['days']),
                notes=f"Initial acquisition {tx['inst']}"
            )

        # 4. Seed Watchlists
        wl, _ = Watchlist.objects.get_or_create(user=demo_user, name='Core Tech & Alpha', defaults={'is_default': True})
        WatchlistItem.objects.filter(watchlist=wl).delete()
        for sym in ['NVDA', 'AAPL', 'MSFT', 'GOOGL', 'BTC']:
            WatchlistItem.objects.create(watchlist=wl, instrument=inst_objects[sym], notes='High conviction')

        wl2, _ = Watchlist.objects.get_or_create(user=demo_user, name='Defensive & Fixed Income', defaults={'is_default': False})
        WatchlistItem.objects.filter(watchlist=wl2).delete()
        for sym in ['BND', 'GLD']:
            WatchlistItem.objects.create(watchlist=wl2, instrument=inst_objects[sym], notes='Hedging asset')

        # 5. Seed Behavioural Finance Questionnaire
        Question.objects.all().delete()
        q1 = Question.objects.create(
            order=1,
            category='RISK_CAPACITY',
            text='What is your primary investment time horizon for this portfolio?'
        )
        QuestionOption.objects.create(question=q1, order=1, text='Less than 2 years (Immediate liquidity need)', score=5)
        QuestionOption.objects.create(question=q1, order=2, text='3 to 5 years (Medium-term milestone)', score=15)
        QuestionOption.objects.create(question=q1, order=3, text='5 to 10 years (Long-term growth)', score=25)
        QuestionOption.objects.create(question=q1, order=4, text='10+ years (Multi-decade compounding)', score=30)

        q2 = Question.objects.create(
            order=2,
            category='LOSS_AVERSION',
            text='If your portfolio dropped 20% in a month due to macro turbulence, what is your likely action?'
        )
        QuestionOption.objects.create(question=q2, order=1, text='Sell everything immediately to preserve remaining capital', score=0)
        QuestionOption.objects.create(question=q2, order=2, text='Trim equities and move partially to cash/bonds', score=10)
        QuestionOption.objects.create(question=q2, order=3, text='Hold steady and follow established rebalancing plan', score=25)
        QuestionOption.objects.create(question=q2, order=4, text='Aggressively deploy excess cash to buy discounted assets', score=35)

        q3 = Question.objects.create(
            order=3,
            category='BIAS_OVERCONFIDENCE',
            text='How frequently do you revise asset allocations based on recent headlines or quarterly earnings?'
        )
        QuestionOption.objects.create(question=q3, order=1, text='Daily / Weekly based on active market sentiment', score=5)
        QuestionOption.objects.create(question=q3, order=2, text='Monthly during earnings season', score=15)
        QuestionOption.objects.create(question=q3, order=3, text='Quarterly or annually on systematic thresholds', score=25)
        QuestionOption.objects.create(question=q3, order=4, text='Strict systematic rebalancing only when weights drift > 5%', score=35)

        # Profile
        BehaviouralProfile.objects.update_or_create(
            user=demo_user,
            defaults={
                'composite_score': 72,
                'risk_category': 'Assertive / Growth Oriented',
                'loss_aversion_score': 45,
                'overconfidence_score': 35,
                'panic_selling_propensity': 'Low-Medium',
                'self_reported_score': 75,
                'trade_observed_score': 68,
                'summary': 'Empirical analysis shows disciplined rebalancing with mild upside concentration bias.'
            }
        )

        # 6. Seed Research Models
        ResearchModel.objects.all().delete()
        iem = ResearchModel.objects.create(
            model_id='IEM-FIN',
            name='Information Extraction Model (IEM)',
            architecture='Transformer Entity-Linking with FinBERT Sentiment Head',
            description='Extracts structured guidance, revenue targets, and directional tone from SEC 10-K filings and earnings call transcripts.',
            status=ModelStatus.EXPERIMENTAL,
            version='v1.2-alpha',
            parameters_count='110M',
            dataset_coverage='SEC Edgar, Refinitiv 2018-2025 Transcripts',
            training_cutoff='2025-12-31'
        )
        ModelEvaluation.objects.create(
            research_model=iem,
            benchmark_dataset='FinancialPhraseBank + SEC Guidance 2025 Test Split',
            split='Out-of-sample Test',
            directional_accuracy=Decimal('78.40'),
            f1_score=Decimal('0.82'),
            eval_date='2026-01-15',
            notes='Strong extraction on guidance revisions; occasional ambiguity on non-standard EBITDA definitions.'
        )

        tf = ResearchModel.objects.create(
            model_id='TIMEFORMER-MTS',
            name='TimeFormer Multivariate Forecasting',
            architecture='Patch-based Temporal Cross-Attention Network',
            description='Predicts multi-horizon covariance matrices and conditional volatility regimes across 500 liquid instruments.',
            status=ModelStatus.PROPOSED,
            version='v0.3-research',
            parameters_count='340M',
            dataset_coverage='CRSP Daily Returns, Federal Reserve FRED Macro Data (1990-2025)',
            training_cutoff='2025-10-31'
        )
        ModelEvaluation.objects.create(
            research_model=tf,
            benchmark_dataset='Rolling 60-day Covariance Test 2024-2025',
            split='Walk-forward Validation',
            mae=Decimal('0.0142'),
            sharpe_backtest=Decimal('1.68'),
            eval_date='2026-02-01',
            notes='Outperformed standard GARCH(1,1) in heavy-tailed regime transitions.'
        )

        mtsm = ResearchModel.objects.create(
            model_id='MTSM-MACRO',
            name='Multi-Task Sentiment Model (MTSM)',
            architecture='Hierarchical State-Space Joint Sentiment & Macro Encoder',
            description='Jointly models central bank communications, bond yield curve inversions, and institutional positioning.',
            status=ModelStatus.EXPERIMENTAL,
            version='v0.9-beta',
            parameters_count='220M',
            dataset_coverage='FOMC Minutes, ECB Statements, Treasury Auction Data',
            training_cutoff='2025-12-31'
        )
        ModelEvaluation.objects.create(
            research_model=mtsm,
            benchmark_dataset='FOMC Rate Decision Shocks (2020-2025)',
            split='Event-study Out-of-Sample',
            directional_accuracy=Decimal('73.10'),
            f1_score=Decimal('0.76'),
            eval_date='2026-02-10',
            notes='Demonstrates superior latency in processing real-time press releases.'
        )

        # 7. Seed Alerts
        Alert.objects.filter(user=demo_user).delete()
        Alert.objects.create(
            user=demo_user,
            title='Asset Concentration Warning',
            message='NVIDIA (NVDA) constitutes 48.0% of your total equity allocation, exceeding the recommended 25% threshold.',
            priority=AlertPriority.WARNING,
            category=AlertCategory.RISK,
            is_read=False,
            action_label='Simulate Rebalancing',
            action_route='/wealth'
        )
        Alert.objects.create(
            user=demo_user,
            title='Tax-Loss Harvesting Opportunity Detected',
            message='Vanguard Total Bond ETF (BND) has an unrealized loss of $1,365.00 available to offset 2026 taxable capital gains.',
            priority=AlertPriority.INFO,
            category=AlertCategory.PORTFOLIO,
            is_read=False,
            action_label='View Tax Simulator',
            action_route='/wealth'
        )
        Alert.objects.create(
            user=demo_user,
            title='TimeFormer Model Update Available',
            message='Experimental checkpoint TimeFormer-MTS v0.3 validation metrics updated with 2025 Q4 benchmark splits.',
            priority=AlertPriority.INFO,
            category=AlertCategory.RESEARCH,
            is_read=True,
            action_label='Inspect Evaluation',
            action_route='/research'
        )

        AlertPreference.objects.update_or_create(
            user=demo_user,
            defaults={
                'volatility_alerts': True,
                'drawdown_warning_threshold': Decimal('5.0'),
                'rebalancing_reminders': True,
                'tax_harvest_opportunities': True,
                'daily_digest': False,
            }
        )

        self.stdout.write(self.style.SUCCESS('Successfully seeded complete PLUTUS AI demo data!'))
