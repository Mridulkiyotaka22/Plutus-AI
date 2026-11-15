import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plutus_ai/features/risk_intelligence/screens/risk_intelligence_screen.dart';

void main() {
  testWidgets(
      'RiskIntelligenceScreen renders quantitative risk ratios and correlation heatmap',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: RiskIntelligenceScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Quantitative Risk Intelligence'), findsOneWidget);
    expect(find.text('Annualized Volatility'), findsOneWidget);
    expect(find.text('Sharpe Ratio'), findsOneWidget);
    expect(find.text('Cross-Asset Correlation Matrix'), findsOneWidget);
  });
}
