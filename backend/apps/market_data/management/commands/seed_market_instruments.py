from django.core.management.base import BaseCommand
from apps.market_data.models import Instrument, AssetType


CATALOG = [
    # US equities (Yahoo Finance symbols)
    ('AAPL', 'Apple Inc.', 'NASDAQ', AssetType.EQUITY, 'USD'),
    ('MSFT', 'Microsoft Corporation', 'NASDAQ', AssetType.EQUITY, 'USD'),
    ('NVDA', 'NVIDIA Corporation', 'NASDAQ', AssetType.EQUITY, 'USD'),
    ('AMZN', 'Amazon.com, Inc.', 'NASDAQ', AssetType.EQUITY, 'USD'),
    ('GOOGL', 'Alphabet Inc.', 'NASDAQ', AssetType.EQUITY, 'USD'),
    ('META', 'Meta Platforms, Inc.', 'NASDAQ', AssetType.EQUITY, 'USD'),
    ('TSLA', 'Tesla, Inc.', 'NASDAQ', AssetType.EQUITY, 'USD'),
    # Indian equities (NSE Yahoo Finance suffix)
    ('RELIANCE.NS', 'Reliance Industries Limited', 'NSE', AssetType.EQUITY, 'INR'),
    ('TCS.NS', 'Tata Consultancy Services Limited', 'NSE', AssetType.EQUITY, 'INR'),
    ('HDFCBANK.NS', 'HDFC Bank Limited', 'NSE', AssetType.EQUITY, 'INR'),
    ('INFY.NS', 'Infosys Limited', 'NSE', AssetType.EQUITY, 'INR'),
    ('ICICIBANK.NS', 'ICICI Bank Limited', 'NSE', AssetType.EQUITY, 'INR'),
    ('SBIN.NS', 'State Bank of India', 'NSE', AssetType.EQUITY, 'INR'),
    ('ITC.NS', 'ITC Limited', 'NSE', AssetType.EQUITY, 'INR'),
    ('LT.NS', 'Larsen & Toubro Limited', 'NSE', AssetType.EQUITY, 'INR'),
    # Common indices
    ('^NSEI', 'NIFTY 50', 'NSE INDEX', AssetType.EQUITY, 'INR'),
    ('^BSESN', 'BSE SENSEX', 'BSE INDEX', AssetType.EQUITY, 'INR'),
    ('^GSPC', 'S&P 500', 'S&P INDEX', AssetType.EQUITY, 'USD'),
    # Crypto and commodities supported by Yahoo Finance symbols
    ('BTC-USD', 'Bitcoin USD', 'CRYPTO', AssetType.CRYPTO, 'USD'),
    ('ETH-USD', 'Ethereum USD', 'CRYPTO', AssetType.CRYPTO, 'USD'),
    ('GC=F', 'Gold Futures', 'COMEX', AssetType.COMMODITY, 'USD'),
    ('CL=F', 'WTI Crude Oil Futures', 'NYMEX', AssetType.COMMODITY, 'USD'),
]


class Command(BaseCommand):
    help = 'Create the supported instrument symbol catalogue. No prices or demo quotes are inserted.'

    def handle(self, *args, **options):
        created = 0
        updated = 0
        for symbol, name, exchange, asset_type, currency in CATALOG:
            _, was_created = Instrument.objects.update_or_create(
                symbol=symbol,
                defaults={
                    'name': name,
                    'exchange': exchange,
                    'asset_type': asset_type,
                    'quote_currency': currency,
                    'is_active': True,
                },
            )
            created += int(was_created)
            updated += int(not was_created)
        self.stdout.write(self.style.SUCCESS(
            f'Market catalogue ready: {created} created, {updated} updated. '
            'Only symbol metadata was inserted; market prices come from the provider.'
        ))
