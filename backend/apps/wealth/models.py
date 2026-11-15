from django.db import models
from django.contrib.auth.models import User
from apps.common.models import TimeStampedModel

class TaxSimulationRecord(TimeStampedModel):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='tax_simulations')
    jurisdiction = models.CharField(max_length=50, default='US_FEDERAL')
    tax_year = models.IntegerField(default=2026)
    estimated_tax_savings = models.DecimalField(max_digits=12, decimal_places=2, default=0.0)
    harvestable_loss = models.DecimalField(max_digits=12, decimal_places=2, default=0.0)
    details = models.JSONField(default=dict)

    class Meta:
        ordering = ['-created_at']

class WealthGoal(TimeStampedModel):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='wealth_goals')
    name = models.CharField(max_length=150)
    target_amount = models.DecimalField(max_digits=16, decimal_places=2)
    target_year = models.IntegerField(default=2036)
    current_amount = models.DecimalField(max_digits=16, decimal_places=2, default=0.0)
    monthly_contribution = models.DecimalField(max_digits=12, decimal_places=2, default=1500.0)

    class Meta:
        ordering = ['target_year']
