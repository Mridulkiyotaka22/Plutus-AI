from django.urls import path
from .views import AIConversationListCreateView, AIConversationDetailView, AIMessageListView, ChatView

urlpatterns = [
    path('conversations/', AIConversationListCreateView.as_view(), name='conversation_list_create'),
    path('conversations/<uuid:pk>/', AIConversationDetailView.as_view(), name='conversation_detail'),
    path('conversations/<uuid:conversation_id>/messages/', AIMessageListView.as_view(), name='conversation_messages'),
    path('chat/', ChatView.as_view(), name='assistant_chat'),
]
