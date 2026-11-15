from rest_framework import generics, permissions
from .models import ResearchModel, ModelEvaluation
from .serializers import ResearchModelSerializer, ModelEvaluationSerializer

class ResearchModelListView(generics.ListAPIView):
    queryset = ResearchModel.objects.prefetch_related('evaluations').all()
    serializer_class = ResearchModelSerializer
    permission_classes = (permissions.AllowAny,)

class ResearchModelDetailView(generics.RetrieveAPIView):
    queryset = ResearchModel.objects.prefetch_related('evaluations').all()
    serializer_class = ResearchModelSerializer
    permission_classes = (permissions.AllowAny,)
    lookup_field = 'model_id'
