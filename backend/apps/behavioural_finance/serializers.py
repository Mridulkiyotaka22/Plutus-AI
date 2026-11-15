from rest_framework import serializers
from .models import Question, QuestionOption, QuestionnaireResponse, BehaviouralProfile

class QuestionOptionSerializer(serializers.ModelSerializer):
    class Meta:
        model = QuestionOption
        fields = ['id', 'text', 'score', 'order']

class QuestionSerializer(serializers.ModelSerializer):
    options = QuestionOptionSerializer(many=True, read_only=True)

    class Meta:
        model = Question
        fields = ['id', 'order', 'text', 'category', 'options']

class BehaviouralProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = BehaviouralProfile
        fields = [
            'composite_score', 'risk_category', 'loss_aversion_score',
            'overconfidence_score', 'panic_selling_propensity',
            'self_reported_score', 'trade_observed_score', 'summary',
            'updated_at'
        ]
