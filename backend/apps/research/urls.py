from django.urls import path
from .views import ResearchModelListView, ResearchModelDetailView

urlpatterns = [
    path('models/', ResearchModelListView.as_view(), name='research_model_list'),
    path('models/<str:model_id>/', ResearchModelDetailView.as_view(), name='research_model_detail'),
]
