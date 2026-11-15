from django.urls import path
from .views import (
    InstrumentListView, InstrumentDetailView, InstrumentQuoteView,
    InstrumentHistoryView, BenchmarkIndexListView,
)

urlpatterns = [
    path('instruments/', InstrumentListView.as_view(), name='instrument_list'),
    path('instruments/<str:symbol>/quote/', InstrumentQuoteView.as_view(), name='instrument_quote'),
    path('instruments/<str:symbol>/history/', InstrumentHistoryView.as_view(), name='instrument_history'),
    path('instruments/<str:symbol>/', InstrumentDetailView.as_view(), name='instrument_detail'),
    path('indices/', BenchmarkIndexListView.as_view(), name='benchmark_indices'),
]
