from django.urls import path
from .views import QuestionnaireView, SubmitQuestionnaireView, BehaviouralProfileView

urlpatterns = [
    path('questionnaire/', QuestionnaireView.as_view(), name='questionnaire'),
    path('questionnaire/submit/', SubmitQuestionnaireView.as_view(), name='submit_questionnaire'),
    path('profile/', BehaviouralProfileView.as_view(), name='behavioural_profile'),
]
