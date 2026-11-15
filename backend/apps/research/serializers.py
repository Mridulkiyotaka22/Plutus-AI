from rest_framework import serializers
from .models import ResearchModel, ModelEvaluation

class ModelEvaluationSerializer(serializers.ModelSerializer):
    class Meta:
        model = ModelEvaluation
        fields = [
            'id', 'benchmark_dataset', 'split', 'directional_accuracy',
            'mae', 'f1_score', 'sharpe_backtest', 'eval_date', 'notes'
        ]

class ResearchModelSerializer(serializers.ModelSerializer):
    evaluations = ModelEvaluationSerializer(many=True, read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)

    class Meta:
        model = ResearchModel
        fields = [
            'id', 'model_id', 'name', 'architecture', 'description',
            'status', 'status_display', 'version', 'parameters_count',
            'dataset_coverage', 'training_cutoff', 'evaluations', 'updated_at'
        ]
