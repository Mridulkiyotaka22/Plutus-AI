from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.shortcuts import get_object_or_404
from .models import Alert, AlertPreference
from .serializers import AlertSerializer, AlertPreferenceSerializer

class AlertListView(generics.ListAPIView):
    serializer_class = AlertSerializer
    permission_classes = (permissions.IsAuthenticated,)

    def get_queryset(self):
        qs = Alert.objects.filter(user=self.request.user)
        category = self.request.query_params.get('category')
        priority = self.request.query_params.get('priority')
        unread_only = self.request.query_params.get('unread')

        if category:
            qs = qs.filter(category=category)
        if priority:
            qs = qs.filter(priority=priority)
        if unread_only and unread_only.lower() in ('true', '1'):
            qs = qs.filter(is_read=False)
        return qs

class MarkAlertReadView(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request, pk):
        alert = get_object_or_404(Alert, id=pk, user=request.user)
        alert.is_read = True
        alert.save(update_fields=['is_read'])
        return Response({'success': True, 'id': str(alert.id), 'is_read': True})

class MarkAllAlertsReadView(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        updated_count = Alert.objects.filter(user=request.user, is_read=False).update(is_read=True)
        return Response({'success': True, 'updated_count': updated_count})

class AlertPreferenceView(generics.RetrieveUpdateAPIView):
    serializer_class = AlertPreferenceSerializer
    permission_classes = (permissions.IsAuthenticated,)

    def get_object(self):
        obj, _ = AlertPreference.objects.get_or_create(user=self.request.user)
        return obj
