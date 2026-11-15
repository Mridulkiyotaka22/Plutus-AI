from django.urls import path
from .views import WatchlistListCreateView, WatchlistDetailView, WatchlistItemCreateDeleteView

urlpatterns = [
    path('', WatchlistListCreateView.as_view(), name='watchlist_list_create'),
    path('<uuid:pk>/', WatchlistDetailView.as_view(), name='watchlist_detail'),
    path('<uuid:watchlist_id>/items/', WatchlistItemCreateDeleteView.as_view(), name='watchlist_item_create'),
    path('<uuid:watchlist_id>/items/<uuid:item_id>/', WatchlistItemCreateDeleteView.as_view(), name='watchlist_item_delete'),
]
