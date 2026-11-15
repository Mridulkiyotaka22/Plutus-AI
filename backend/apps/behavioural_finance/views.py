from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Question, QuestionnaireResponse, BehaviouralProfile
from .serializers import QuestionSerializer, BehaviouralProfileSerializer

class QuestionnaireView(generics.ListAPIView):
    queryset = Question.objects.all()
    serializer_class = QuestionSerializer
    permission_classes = (permissions.AllowAny,)

class SubmitQuestionnaireView(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def post(self, request):
        answers = request.data.get('answers', {})
        total_score = sum(int(score) for score in answers.values()) if answers else 70

        # Classify risk category deterministically
        if total_score >= 80:
            category = 'Aggressive Growth'
        elif total_score >= 60:
            category = 'Assertive / Growth Oriented'
        elif total_score >= 40:
            category = 'Balanced Growth'
        else:
            category = 'Conservative Capital Preservation'

        # Save response record
        QuestionnaireResponse.objects.create(
            user=request.user,
            total_score=total_score,
            answers=answers
        )

        # Update or create BehaviouralProfile
        profile, _ = BehaviouralProfile.objects.update_or_create(
            user=request.user,
            defaults={
                'composite_score': total_score,
                'risk_category': category,
                'self_reported_score': total_score,
                'trade_observed_score': max(10, total_score - 4),
                'loss_aversion_score': 100 - total_score,
                'summary': f"Survey indicates an {category} psychological disposition with measured loss aversion."
            }
        )

        return Response({
            'success': True,
            'message': 'Questionnaire submitted successfully.',
            'profile': BehaviouralProfileSerializer(profile).data
        }, status=status.HTTP_201_CREATED)

class BehaviouralProfileView(APIView):
    permission_classes = (permissions.IsAuthenticated,)

    def get(self, request):
        profile, created = BehaviouralProfile.objects.get_or_create(
            user=request.user,
            defaults={
                'composite_score': 72,
                'risk_category': 'Assertive / Growth Oriented',
                'loss_aversion_score': 42,
                'overconfidence_score': 38,
                'panic_selling_propensity': 'Low-Medium',
                'self_reported_score': 75,
                'trade_observed_score': 68,
                'summary': 'Consistent willingness to absorb intermediate volatility in pursuit of real capital appreciation.'
            }
        )
        return Response(BehaviouralProfileSerializer(profile).data)
