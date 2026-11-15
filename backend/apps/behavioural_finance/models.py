from django.db import models
from django.contrib.auth.models import User
from apps.common.models import TimeStampedModel

class Question(TimeStampedModel):
    order = models.IntegerField(default=1)
    text = models.CharField(max_length=300)
    category = models.CharField(max_length=50, default='RISK_TOLERANCE')  # TOLERANCE, CAPACITY, BIAS

    class Meta:
        ordering = ['order']

    def __str__(self):
        return f"Q{self.order}: {self.text[:50]}"

class QuestionOption(TimeStampedModel):
    question = models.ForeignKey(Question, on_delete=models.CASCADE, related_name='options')
    text = models.CharField(max_length=200)
    score = models.IntegerField(default=10)
    order = models.IntegerField(default=1)

    class Meta:
        ordering = ['order']

class QuestionnaireResponse(TimeStampedModel):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='questionnaire_responses')
    total_score = models.IntegerField(default=0)
    answers = models.JSONField(default=dict)

    class Meta:
        ordering = ['-created_at']

class BehaviouralProfile(TimeStampedModel):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='behavioural_profile')
    composite_score = models.IntegerField(default=72)
    risk_category = models.CharField(max_length=50, default='Assertive / Growth Oriented')
    loss_aversion_score = models.IntegerField(default=45)      # 0-100 (lower means less panic)
    overconfidence_score = models.IntegerField(default=35)     # 0-100
    panic_selling_propensity = models.CharField(max_length=30, default='Low-Medium')
    self_reported_score = models.IntegerField(default=75)
    trade_observed_score = models.IntegerField(default=68)
    summary = models.TextField(blank=True, default='')

    def __str__(self):
        return f"{self.user.username} - {self.risk_category}"
