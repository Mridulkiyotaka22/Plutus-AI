from rest_framework import serializers
from .models import Alert, AlertPreference

class AlertSerializer(serializers.ModelSerializer):
    class Meta:
        model = Alert
        fields = [
            'id', 'title', 'message', 'priority', 'category',
            'is_read', 'action_label', 'action_route', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']

class AlertPreferenceSerializer(serializers.ModelSerializer):
    class Meta:
        model = AlertPreference
        fields = [
            'volatility_alerts', 'drawdown_warning_threshold',
            'rebalancing_reminders', 'tax_harvest_opportunities', 'daily_digest'
        ]
