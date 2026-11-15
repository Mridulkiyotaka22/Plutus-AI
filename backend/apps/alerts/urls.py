from django.urls import path
from .views import AlertListView, MarkAlertReadView, MarkAllAlertsReadView, AlertPreferenceView

urlpatterns = [
    path('', AlertListView.as_view(), name='alert_list'),
    path('<uuid:pk>/read/', MarkAlertReadView.as_view(), name='alert_mark_read'),
    path('read-all/', MarkAllAlertsReadView.as_view(), name='alert_mark_all_read'),
    path('preferences/', AlertPreferenceView.as_view(), name='alert_preferences'),
]
