from django.db import models
from django.contrib.auth.models import User
from decimal import Decimal
from apps.common.models import TimeStampedModel
from apps.market_data.models import Instrument

class Portfolio(TimeStampedModel):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='portfolios')
    name = models.CharField(max_length=100, default='Main Investment Portfolio')
    base_currency = models.CharField(max_length=10, default='INR')
    is_default = models.BooleanField(default=True)
    cash_balance = models.DecimalField(max_digits=16, decimal_places=2, default=Decimal('0.00'))

    class Meta:
        ordering = ['-is_default', 'created_at']

    def __str__(self):
        return f"{self.user.username} - {self.name}"

class TransactionType(models.TextChoices):
    BUY = 'BUY', 'Buy Asset'
    SELL = 'SELL', 'Sell Asset'
    DIVIDEND = 'DIVIDEND', 'Dividend Payout'
    DEPOSIT = 'DEPOSIT', 'Cash Deposit'
    WITHDRAWAL = 'WITHDRAWAL', 'Cash Withdrawal'

class Transaction(TimeStampedModel):
    portfolio = models.ForeignKey(Portfolio, on_delete=models.CASCADE, related_name='transactions')
    instrument = models.ForeignKey(Instrument, on_delete=models.SET_NULL, null=True, blank=True)
    type = models.CharField(max_length=20, choices=TransactionType.choices)
    shares = models.DecimalField(max_digits=16, decimal_places=4, default=Decimal('0'))
    price = models.DecimalField(max_digits=16, decimal_places=4, default=Decimal('0'))
    amount = models.DecimalField(max_digits=16, decimal_places=2)
    fees = models.DecimalField(max_digits=8, decimal_places=2, default=Decimal('0'))
    trade_date = models.DateTimeField()
    notes = models.CharField(max_length=255, blank=True, default='')

    class Meta:
        ordering = ['-trade_date']

    def __str__(self):
        return f"{self.type} {self.shares} {self.instrument.symbol if self.instrument else 'CASH'} - {self.portfolio.name}"

class PortfolioSnapshot(TimeStampedModel):
    portfolio = models.ForeignKey(Portfolio, on_delete=models.CASCADE, related_name='snapshots')
    timestamp = models.DateTimeField(db_index=True)
    total_value = models.DecimalField(max_digits=16, decimal_places=2)
    invested_capital = models.DecimalField(max_digits=16, decimal_places=2)
    daily_change = models.DecimalField(max_digits=12, decimal_places=2, default=Decimal('0'))
    daily_change_pct = models.DecimalField(max_digits=8, decimal_places=4, default=Decimal('0'))

    class Meta:
        ordering = ['timestamp']
        unique_together = ('portfolio', 'timestamp')
