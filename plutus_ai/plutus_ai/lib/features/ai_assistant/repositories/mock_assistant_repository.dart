import '../fixtures/demo_assistant.dart';
import '../models/ai_message_model.dart';
import 'assistant_repository.dart';

class MockAssistantRepository implements AssistantRepository {
  final List<AIConversationModel> _conversations =
      List.from(DemoAssistant.defaultConversations);

  @override
  Future<List<AIConversationModel>> getConversations() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _conversations;
  }

  @override
  Future<AIMessageModel> sendMessage({
    required String message,
    String? conversationId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final lower = message.toLowerCase();

    // Check domain filter in mock
    final outOfScope = [
      'cook',
      'recipe',
      'movie',
      'football',
      'soccer',
      'poem',
      'weather',
      'dating'
    ];
    for (final word in outOfScope) {
      if (lower.contains(word)) {
        return AIMessageModel(
          id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
          role: 'SYSTEM',
          content:
              'I am PLUTUS AI, an assistant dedicated exclusively to financial intelligence, wealth management, portfolio diagnostics and markets. I cannot assist with non-financial requests. Please ask about your portfolio, markets, risk analysis, or wealth planning.',
          isInScope: false,
          sources: const ['Domain Safety Guardrail'],
          disclaimers: 'PLUTUS AI domain restriction active.',
          createdAt: DateTime.now(),
        );
      }
    }

    String reply;
    List<String> sources = [
      'PLUTUS Portfolio Ledger',
      'Verified Financial Analytics'
    ];

    if (lower.contains('risk') ||
        lower.contains('sharpe') ||
        lower.contains('sortino')) {
      reply =
          '**Portfolio Quantitative Diagnostic:**\n- **Annualized Volatility:** 11.69%\n- **Sharpe Ratio (Rf=4.5%):** 6.30 (Strong risk-adjusted performance)\n- **Sortino Ratio:** 15.41 (Excellent downside protection)\n- **1-Day 95% Historical VaR:** \$1,762.50\n- **Expected Shortfall (CVaR):** \$2,000.00\n- **HHI Concentration Index:** 0.132 (Moderate concentration)\n\nNote: Your position in NVDA constitutes 25.98% of your total assets, which serves as the primary driver of both returns and volatility.';
      sources.add('GARCH & Historical VaR Engine');
    } else if (lower.contains('tax') || lower.contains('harvest')) {
      reply =
          '**Tax-Loss Harvesting Diagnostic (US Federal 2026):**\n- **Harvestable Candidate:** Vanguard Total Bond ETF (BND)\n- **Unrealized Loss:** -\$1,365.00 (650 shares)\n- **Potential Tax Offset:** \$436.80 at 32% marginal rate.\n- **Wash-Sale Substitute:** iShares Core US Aggregate Bond (AGG) with 98% tracking correlation.';
      sources.add('Wealth Optimization Service');
    } else if (lower.contains('allocation') || lower.contains('rebalance')) {
      reply =
          '**Current vs Target Allocation:**\n- **Equities:** 58.7% (Above target 40%)\n- **Fixed Income (BND):** 16.5% (Below target 25%)\n- **Crypto Assets (BTC):** 11.9% (Near target 10%)\n- **Commodities (GLD):** 9.4% (Below target 15%)\n- **Cash:** 8.0% (Near target 10%)\n\nTo rebalance to systematic weights without triggering unnecessary short-term capital gains, consider directing new monthly contributions toward Fixed Income and Commodities.';
    } else {
      reply =
          'I analyzed your query: "$message".\n\nYour portfolio holds 6 core assets totaling \$284,750.40. Cash balance is \$22,780.03. Current daily gain is +\$3,840.20 (+1.37%). You can ask for deeper evaluations on asset concentration, tax harvesting, or benchmark comparisons.';
    }

    return AIMessageModel(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      role: 'ASSISTANT',
      content: reply,
      isInScope: true,
      sources: sources,
      disclaimers:
          'PLUTUS AI provides educational intelligence, not personal financial advice.',
      createdAt: DateTime.now(),
    );
  }
}
