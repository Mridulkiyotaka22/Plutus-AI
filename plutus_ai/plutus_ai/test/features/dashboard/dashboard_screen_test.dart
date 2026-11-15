import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plutus_ai/features/dashboard/screens/dashboard_screen.dart';
import 'package:plutus_ai/config/env_config.dart';
import 'package:plutus_ai/config/environment_provider.dart';
import 'package:plutus_ai/features/dashboard/widgets/dashboard_header.dart';
import 'package:plutus_ai/features/dashboard/widgets/metric_card.dart';
import 'package:plutus_ai/features/dashboard/widgets/portfolio_chart_card.dart';
import 'package:plutus_ai/features/dashboard/widgets/asset_allocation_card.dart';
import 'package:plutus_ai/features/dashboard/widgets/market_indices_card.dart';
import 'package:plutus_ai/features/dashboard/widgets/top_holdings_card.dart';
import 'package:plutus_ai/features/dashboard/widgets/recent_transactions_card.dart';
import 'package:plutus_ai/features/dashboard/widgets/risk_summary_card.dart';
import 'package:plutus_ai/features/dashboard/widgets/ai_insight_card.dart';

void main() {
  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        appEnvironmentProvider.overrideWith((ref) => Environment.demo),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: DashboardScreen(),
        ),
      ),
    );
  }

  testWidgets('DashboardScreen renders all financial command center components',
      (WidgetTester tester) async {
    // Set a wide screen size for desktop layout
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify Header is rendered with DEMO tag
    expect(find.byType(DashboardHeader), findsOneWidget);
    expect(find.text('FINANCIAL COMMAND CENTER'), findsOneWidget);
    expect(find.text('DEMO DATA'), findsOneWidget);

    // Verify Metric Cards
    expect(find.byType(MetricCard), findsNWidgets(4));
    expect(find.text('PORTFOLIO VALUE'), findsOneWidget);
    expect(find.text('INVESTED CAPITAL'), findsOneWidget);
    expect(find.text('DAILY P&L'), findsOneWidget);
    expect(find.text('OVERALL RETURN'), findsOneWidget);

    // Verify Core Visual Cards
    expect(find.byType(PortfolioChartCard), findsOneWidget);
    expect(find.byType(AssetAllocationCard), findsOneWidget);
    expect(find.byType(MarketIndicesCard), findsOneWidget);
    expect(find.byType(TopHoldingsCard), findsOneWidget);
    expect(find.byType(RecentTransactionsCard), findsOneWidget);
    expect(find.byType(RiskSummaryCard), findsOneWidget);
    expect(find.byType(AiInsightCard), findsOneWidget);

    // Verify Timeframe Selectors in Performance Chart
    expect(find.text('1W'), findsOneWidget);
    expect(find.text('1M'), findsOneWidget);
    expect(find.text('3M'), findsOneWidget);
    expect(find.text('6M'), findsOneWidget);
    expect(find.text('1Y'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(PortfolioChartCard),
        matching: find.text('ALL'),
      ),
      findsOneWidget,
    );

    // Test tapping 1Y timeframe
    await tester.tap(find.text('1Y'));
    await tester.pumpAndSettle();

    // Verify Market Indices Card has sample label
    expect(find.text('DEMO DATA'), findsWidgets);

    // Verify AI preview
    expect(find.text('PLUTUS AI PREVIEW'), findsOneWidget);
    expect(find.text('Ask PLUTUS AI'), findsWidgets);
  });
}
