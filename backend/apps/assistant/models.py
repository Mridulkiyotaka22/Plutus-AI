from django.db import models
from django.contrib.auth.models import User
from apps.common.models import TimeStampedModel

class AIConversation(TimeStampedModel):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='ai_conversations')
    title = models.CharField(max_length=150, default='New Financial Query')
    is_pinned = models.BooleanField(default=False)

    class Meta:
        ordering = ['-updated_at']

    def __str__(self):
        return f"{self.user.username} - {self.title}"

class AIMessage(TimeStampedModel):
    ROLE_CHOICES = (
        ('USER', 'User'),
        ('ASSISTANT', 'Assistant'),
        ('SYSTEM', 'System Guardrail'),
    )

    conversation = models.ForeignKey(AIConversation, on_delete=models.CASCADE, related_name='messages')
    role = models.CharField(max_length=10, choices=ROLE_CHOICES)
    content = models.TextField()
    is_in_scope = models.BooleanField(default=True)
    sources = models.JSONField(default=list, blank=True)
    disclaimers = models.CharField(
        max_length=255,
        default='PLUTUS AI provides educational intelligence and analytics, not formal financial advice.'
    )

    class Meta:
        ordering = ['created_at']
