from django.db import models
from django.contrib.auth.models import User
from django.db.models.signals import post_save
from django.dispatch import receiver
from apps.common.models import TimeStampedModel

class UserProfile(TimeStampedModel):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    base_currency = models.CharField(max_length=3, default='USD')
    locale = models.CharField(max_length=10, default='en_US')
    tax_jurisdiction = models.CharField(max_length=50, default='US_FEDERAL')
    theme_preference = models.CharField(max_length=20, default='DARK_FINTECH')
    email_alerts = models.BooleanField(default=True)
    in_app_alerts = models.BooleanField(default=True)
    bio = models.TextField(blank=True, default='')

    def __str__(self):
        return f"{self.user.username} Profile ({self.base_currency})"

@receiver(post_save, sender=User)
def create_or_update_user_profile(sender, instance, created, **kwargs):
    if created:
        UserProfile.objects.create(user=instance)
    else:
        if hasattr(instance, 'profile'):
            instance.profile.save()
