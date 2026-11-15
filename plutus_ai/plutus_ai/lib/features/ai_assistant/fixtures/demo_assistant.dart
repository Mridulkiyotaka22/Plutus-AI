import '../models/ai_message_model.dart';

class DemoAssistant {
  static List<AIMessageModel> get initialMessages => [
        AIMessageModel(
          id: 'msg-001',
          role: 'ASSISTANT',
          content:
              'Hello Mridul. I am PLUTUS AI, your specialized financial intelligence assistant.\n\nI have authorized access to your **Main Investment Portfolio** (\$284,750.40 total net worth, 6 active positions). You can ask me to evaluate portfolio risk metrics, diagnose asset concentration, simulate tax-loss harvesting scenarios, or explain quantitative concepts like Sharpe, Sortino and VaR.',
          isInScope: true,
          sources: const [
            'User Portfolio Ledger',
            'Verified Risk Analytics Engine',
            'PLUTUS DB Cache'
          ],
          disclaimers:
              'Educational intelligence only. Not formal investment advice.',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ];

  static List<AIConversationModel> get defaultConversations => [
        AIConversationModel(
          id: 'conv-001',
          title: 'Portfolio Concentration & Risk',
          isPinned: true,
          messages: initialMessages,
        ),
        AIConversationModel(
          id: 'conv-002',
          title: '2026 Tax Loss Harvesting Plan',
          isPinned: false,
          messages: [
            AIMessageModel(
              id: 'msg-002',
              role: 'USER',
              content:
                  'What tax loss harvesting opportunities do I have right now?',
              createdAt: DateTime.now().subtract(const Duration(days: 1)),
            ),
            AIMessageModel(
              id: 'msg-003',
              role: 'ASSISTANT',
              content:
                  'Based on current market valuations, your **Vanguard Total Bond Market ETF (BND)** holding is showing an unrealized loss of **-\$1,365.00** across 650 shares.\n\nUnder US Federal tax guidelines, you can harvest this loss to offset realized capital gains. To maintain duration and bond yield exposure without violating the 30-day IRS Wash-Sale rule, PLUTUS recommends **iShares Core U.S. Aggregate Bond ETF (AGG)** (98% historical tracking correlation).',
              sources: const [
                'Holdings Ledger',
                'Tax Optimization Engine (US_FEDERAL)'
              ],
              createdAt: DateTime.now().subtract(const Duration(days: 1)),
            ),
          ],
        ),
      ];
}
