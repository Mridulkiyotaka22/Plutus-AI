from django.urls import path
from .views import PortfolioRiskView, PortfolioCorrelationView

urlpatterns = [
    path('portfolio/<uuid:portfolio_id>/risk/', PortfolioRiskView.as_view(), name='portfolio_risk'),
    path('portfolio/<uuid:portfolio_id>/correlation/', PortfolioCorrelationView.as_view(), name='portfolio_correlation'),
]
