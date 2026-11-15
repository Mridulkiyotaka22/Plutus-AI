from django.db import models
from django.contrib.auth.models import User
from apps.common.models import TimeStampedModel

class AlertPriority(models.TextChoices):
    INFO = 'INFO', 'Informational'
    WARNING = 'WARNING', 'Warning'
    CRITICAL = 'CRITICAL', 'Critical Attention'

class AlertCategory(models.TextChoices):
    RISK = 'RISK', 'Risk & Exposure'
    PORTFOLIO = 'PORTFOLIO', 'Portfolio & Rebalancing'
    MARKET = 'MARKET', 'Market Price & Volatility'
    RESEARCH = 'RESEARCH', 'AI Research & Models'
    SYSTEM = 'SYSTEM', 'System & Security'

class Alert(TimeStampedModel):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='alerts')
    title = models.CharField(max_length=200)
    message = models.TextField()
    priority = models.CharField(max_length=20, choices=AlertPriority.choices, default=AlertPriority.INFO)
    category = models.CharField(max_length=20, choices=AlertCategory.choices, default=AlertCategory.PORTFOLIO)
    is_read = models.BooleanField(default=False)
    action_label = models.CharField(max_length=100, blank=True, default='')
    action_route = models.CharField(max_length=150, blank=True, default='')

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"[{self.priority}] {self.title} ({self.user.username})"

class AlertPreference(TimeStampedModel):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='alert_preferences')
    volatility_alerts = models.BooleanField(default=True)
    drawdown_warning_threshold = models.DecimalField(max_digits=5, decimal_places=2, default=5.0) # percent
    rebalancing_reminders = models.BooleanField(default=True)
    tax_harvest_opportunities = models.BooleanField(default=True)
    daily_digest = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.user.username} Alert Preferences"
