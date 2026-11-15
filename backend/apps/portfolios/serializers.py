from rest_framework import serializers
from .models import Portfolio, Transaction, PortfolioSnapshot
from apps.market_data.serializers import InstrumentSerializer
from apps.market_data.models import Instrument

class PortfolioSerializer(serializers.ModelSerializer):
    class Meta:
        model = Portfolio
        fields = ['id', 'name', 'base_currency', 'is_default', 'cash_balance', 'created_at']
        read_only_fields = ['id', 'created_at']

class TransactionSerializer(serializers.ModelSerializer):
    instrument = InstrumentSerializer(read_only=True)
    instrument_id = serializers.PrimaryKeyRelatedField(
        queryset=Instrument.objects.all(), source='instrument', write_only=True, required=False, allow_null=True
    )

    class Meta:
        model = Transaction
        fields = [
            'id', 'portfolio', 'instrument', 'instrument_id',
            'type', 'shares', 'price', 'amount', 'fees',
            'trade_date', 'notes', 'created_at'
        ]
        read_only_fields = ['id', 'portfolio', 'created_at']

class PortfolioSnapshotSerializer(serializers.ModelSerializer):
    class Meta:
        model = PortfolioSnapshot
        fields = ['timestamp', 'total_value', 'invested_capital', 'daily_change', 'daily_change_pct']
