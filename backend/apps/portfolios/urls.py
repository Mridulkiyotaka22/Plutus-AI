from django.urls import path
from .views import (
    PortfolioListCreateView, PortfolioDetailView,
    PortfolioSummaryView, PortfolioHoldingsView,
    TransactionListCreateView, PortfolioAllocationView
)

urlpatterns = [
    path('', PortfolioListCreateView.as_view(), name='portfolio_list_create'),
    path('<uuid:pk>/', PortfolioDetailView.as_view(), name='portfolio_detail'),
    path('<uuid:pk>/summary/', PortfolioSummaryView.as_view(), name='portfolio_summary'),
    path('<uuid:pk>/holdings/', PortfolioHoldingsView.as_view(), name='portfolio_holdings'),
    path('<uuid:pk>/allocation/', PortfolioAllocationView.as_view(), name='portfolio_allocation'),
    path('<uuid:portfolio_id>/transactions/', TransactionListCreateView.as_view(), name='transaction_list_create'),
]
