from django.db import models
from apps.common.models import TimeStampedModel
from apps.portfolios.models import Portfolio

class RiskAnalysisSnapshot(TimeStampedModel):
    portfolio = models.ForeignKey(Portfolio, on_delete=models.CASCADE, related_name='risk_snapshots')
    as_of_date = models.DateField(auto_now_add=True)
    risk_score = models.IntegerField(default=68)
    risk_level = models.CharField(max_length=50, default='Moderate-Aggressive')
    annualized_volatility = models.FloatField(default=0.162)
    sharpe_ratio = models.FloatField(default=1.88)
    sortino_ratio = models.FloatField(default=2.42)
    max_drawdown = models.FloatField(default=-0.138)
    var_95_1d = models.FloatField(default=4250.00)
    cvar_95_1d = models.FloatField(default=6100.00)
    beta = models.FloatField(default=1.14)
    hhi_concentration = models.FloatField(default=0.18)
    status = models.CharField(max_length=20, default='ACTIVE')

    class Meta:
        ordering = ['-created_at']
