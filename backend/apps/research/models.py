from django.db import models
from apps.common.models import TimeStampedModel

class ModelStatus(models.TextChoices):
    PROPOSED = 'PROPOSED', 'Proposed / In Research'
    IN_DEVELOPMENT = 'IN_DEVELOPMENT', 'In Development'
    EXPERIMENTAL = 'EXPERIMENTAL', 'Experimental Offline Testing'
    DEPRECATED = 'DEPRECATED', 'Deprecated'

class ResearchModel(TimeStampedModel):
    model_id = models.CharField(max_length=50, unique=True)
    name = models.CharField(max_length=150)
    architecture = models.CharField(max_length=150)
    description = models.TextField()
    status = models.CharField(max_length=30, choices=ModelStatus.choices, default=ModelStatus.EXPERIMENTAL)
    version = models.CharField(max_length=20, default='v0.1-alpha')
    parameters_count = models.CharField(max_length=30, default='110M')
    dataset_coverage = models.CharField(max_length=200, default='SEC 10-K, Earnings Calls, Bloomberg/Refinitiv transcripts')
    training_cutoff = models.CharField(max_length=50, default='2025-12-31')

    def __str__(self):
        return f"{self.name} ({self.model_id}) - [{self.status}]"

class ModelEvaluation(TimeStampedModel):
    research_model = models.ForeignKey(ResearchModel, on_delete=models.CASCADE, related_name='evaluations')
    benchmark_dataset = models.CharField(max_length=150)
    split = models.CharField(max_length=50, default='Out-of-sample Test (2025)')
    directional_accuracy = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    mae = models.DecimalField(max_digits=8, decimal_places=4, null=True, blank=True)
    f1_score = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    sharpe_backtest = models.DecimalField(max_digits=6, decimal_places=2, null=True, blank=True)
    eval_date = models.DateField()
    notes = models.TextField(blank=True, default='')

    class Meta:
        ordering = ['-eval_date']
