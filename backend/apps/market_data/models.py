from django.db import models
from django.contrib.auth.models import User
from apps.common.models import TimeStampedModel

class AssetType(models.TextChoices):
    EQUITY = 'EQUITY', 'Equities / Stocks'
    FIXED_INCOME = 'FIXED_INCOME', 'Fixed Income / Bonds'
    CRYPTO = 'CRYPTO', 'Crypto Assets'
    COMMODITY = 'COMMODITY', 'Commodities'
    CASH = 'CASH', 'Cash & Equivalents'

class Instrument(TimeStampedModel):
    symbol = models.CharField(max_length=20, unique=True, db_index=True)
    name = models.CharField(max_length=150)
    exchange = models.CharField(max_length=50, default='NASDAQ')
    asset_type = models.CharField(max_length=20, choices=AssetType.choices, default=AssetType.EQUITY)
    quote_currency = models.CharField(max_length=10, default='USD')
    current_price = models.DecimalField(max_digits=16, decimal_places=4, default=0.0)
    change = models.DecimalField(max_digits=12, decimal_places=4, default=0.0)
    change_percent = models.DecimalField(max_digits=8, decimal_places=4, default=0.0)
    volume = models.BigIntegerField(default=0)
    market_cap = models.DecimalField(max_digits=20, decimal_places=2, null=True, blank=True)
    pe_ratio = models.DecimalField(max_digits=8, decimal_places=2, null=True, blank=True)
    high_52w = models.DecimalField(max_digits=16, decimal_places=4, null=True, blank=True)
    low_52w = models.DecimalField(max_digits=16, decimal_places=4, null=True, blank=True)
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.symbol} - {self.name}"

class MarketPrice(TimeStampedModel):
    instrument = models.ForeignKey(Instrument, on_delete=models.CASCADE, related_name='price_history')
    timestamp = models.DateTimeField(db_index=True)
    open = models.DecimalField(max_digits=16, decimal_places=4)
    high = models.DecimalField(max_digits=16, decimal_places=4)
    low = models.DecimalField(max_digits=16, decimal_places=4)
    close = models.DecimalField(max_digits=16, decimal_places=4)
    volume = models.BigIntegerField(default=0)
    source = models.CharField(max_length=50, default='HISTORICAL_CACHE')

    class Meta:
        ordering = ['timestamp']
        unique_together = ('instrument', 'timestamp')

class BenchmarkIndex(TimeStampedModel):
    symbol = models.CharField(max_length=20, unique=True)
    name = models.CharField(max_length=100)
    value = models.DecimalField(max_digits=14, decimal_places=2)
    change = models.DecimalField(max_digits=10, decimal_places=2)
    change_percent = models.DecimalField(max_digits=8, decimal_places=2)
    sparkline = models.JSONField(default=list)
    source_label = models.CharField(max_length=100, default='UNVERIFIED / NO PROVIDER DATA')

    def __str__(self):
        return f"{self.name} ({self.symbol})"

class Watchlist(TimeStampedModel):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='watchlists')
    name = models.CharField(max_length=100)
    is_default = models.BooleanField(default=False)

    class Meta:
        ordering = ['created_at']

    def __str__(self):
        return f"{self.user.username} - {self.name}"

class WatchlistItem(TimeStampedModel):
    watchlist = models.ForeignKey(Watchlist, on_delete=models.CASCADE, related_name='items')
    instrument = models.ForeignKey(Instrument, on_delete=models.CASCADE)
    notes = models.CharField(max_length=255, blank=True, default='')

    class Meta:
        unique_together = ('watchlist', 'instrument')
        ordering = ['created_at']
