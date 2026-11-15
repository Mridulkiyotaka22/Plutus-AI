from django.urls import path
from .views import TaxHarvestSimulationView, RebalanceSimulationView, WealthProjectionView

urlpatterns = [
    path('tax-harvest/', TaxHarvestSimulationView.as_view(), name='wealth_tax_harvest'),
    path('rebalance/', RebalanceSimulationView.as_view(), name='wealth_rebalance'),
    path('projections/', WealthProjectionView.as_view(), name='wealth_projections'),
]
