import '../models/behavioural_models.dart';

class DemoBehavioural {
  static const BehaviouralProfileModel defaultProfile = BehaviouralProfileModel(
    compositeScore: 72,
    riskCategory: 'Assertive / Growth Oriented',
    lossAversionScore: 45,
    overconfidenceScore: 35,
    panicSellingPropensity: 'Low-Medium',
    selfReportedScore: 75,
    tradeObservedScore: 68,
    summary:
        'Survey diagnostic indicates an Assertive Growth disposition. Trade execution logs corroborate disciplined rebalancing with an observed 7-point gap reflecting minor reluctance to trim profitable equity positions during drawdowns.',
  );

  static const List<QuestionModel> defaultQuestions = [
    QuestionModel(
      id: 'q-1',
      order: 1,
      text: 'What is your primary investment time horizon for this portfolio?',
      category: 'RISK_CAPACITY',
      options: [
        QuestionOptionModel(
            id: 'opt-1-1',
            text: 'Less than 2 years (Immediate capital preservation)',
            score: 5),
        QuestionOptionModel(
            id: 'opt-1-2',
            text: '3 to 5 years (Medium-term growth with moderate safety)',
            score: 15),
        QuestionOptionModel(
            id: 'opt-1-3',
            text: '5 to 10 years (Long-term compounding focus)',
            score: 25),
        QuestionOptionModel(
            id: 'opt-1-4',
            text: '10+ years (Multi-decade wealth generation)',
            score: 35),
      ],
    ),
    QuestionModel(
      id: 'q-2',
      order: 2,
      text:
          'If your portfolio dropped 20% in a month due to macro turbulence, what is your most likely response?',
      category: 'LOSS_AVERSION',
      options: [
        QuestionOptionModel(
            id: 'opt-2-1',
            text: 'Sell all risk assets to protect remaining capital',
            score: 0),
        QuestionOptionModel(
            id: 'opt-2-2',
            text: 'Trim equities by 30% and increase defensive cash allocation',
            score: 10),
        QuestionOptionModel(
            id: 'opt-2-3',
            text: 'Hold steady and execute disciplined scheduled rebalancing',
            score: 25),
        QuestionOptionModel(
            id: 'opt-2-4',
            text: 'Aggressively buy discounted equities with cash reserves',
            score: 35),
      ],
    ),
    QuestionModel(
      id: 'q-3',
      order: 3,
      text:
          'How frequently do you reallocate based on breaking financial headlines or earnings surprises?',
      category: 'BIAS_OVERCONFIDENCE',
      options: [
        QuestionOptionModel(
            id: 'opt-3-1',
            text: 'Daily / Weekly based on active market sentiment',
            score: 5),
        QuestionOptionModel(
            id: 'opt-3-2',
            text: 'Monthly around quarterly earnings releases',
            score: 15),
        QuestionOptionModel(
            id: 'opt-3-3',
            text: 'Quarterly or bi-annually on predefined dates',
            score: 25),
        QuestionOptionModel(
            id: 'opt-3-4',
            text: 'Only when systematic asset weights drift by more than 5%',
            score: 35),
      ],
    ),
  ];
}
