from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.shortcuts import get_object_or_404
from .models import AIConversation, AIMessage
from .serializers import AIConversationSerializer, AIMessageSerializer
from .services import FinanceAssistantService

class AIConversationListCreateView(generics.ListCreateAPIView):
    serializer_class = AIConversationSerializer
    permission_classes = (permissions.IsAuthenticated,)

    def get_queryset(self):
        return AIConversation.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class AIConversationDetailView(generics.RetrieveDestroyAPIView):
    serializer_class = AIConversationSerializer
    permission_classes = (permissions.IsAuthenticated,)

    def get_queryset(self):
        return AIConversation.objects.filter(user=self.request.user)

class AIMessageListView(generics.ListAPIView):
    serializer_class = AIMessageSerializer
    permission_classes = (permissions.IsAuthenticated,)

    def get_queryset(self):
        convo_id = self.kwargs.get('conversation_id')
        convo = get_object_or_404(AIConversation, id=convo_id, user=self.request.user)
        return convo.messages.all()

class ChatView(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        query = request.data.get('message', '').strip()
        if not query:
            return Response(
                {'error': {'message': 'Message parameter is required.'}},
                status=status.HTTP_400_BAD_REQUEST
            )

        conversation_id = request.data.get('conversation_id')
        if conversation_id:
            convo = get_object_or_404(AIConversation, id=conversation_id, user=request.user)
        else:
            title = (query[:35] + '...') if len(query) > 35 else query
            convo = AIConversation.objects.create(user=request.user, title=title)

        # Record User Message
        user_msg = AIMessage.objects.create(
            conversation=convo,
            role='USER',
            content=query,
            is_in_scope=True
        )

        # Generate Response via FinanceAssistantService (with server-side guardrails)
        result = FinanceAssistantService.answer_query(request.user, query, str(convo.id))

        # Record Assistant Message
        bot_msg = AIMessage.objects.create(
            conversation=convo,
            role='ASSISTANT' if result['is_in_scope'] else 'SYSTEM',
            content=result['answer'],
            is_in_scope=result['is_in_scope'],
            sources=result['sources'],
            disclaimers=result['disclaimers']
        )

        convo.save()  # update updated_at

        return Response({
            'conversation_id': str(convo.id),
            'reply': result['answer'],
            'answer': result['answer'],
            'user_message': AIMessageSerializer(user_msg).data,
            'assistant_message': AIMessageSerializer(bot_msg).data,
            'is_in_scope': result['is_in_scope'],
            'sources': result['sources'],
            'disclaimers': result['disclaimers'],
        })
