import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plutus_ai/features/portfolio/screens/portfolio_screen.dart';

void main() {
  testWidgets('PortfolioScreen renders holdings ledger and KPI summaries',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: PortfolioScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Main Investment Portfolio'), findsOneWidget);
    expect(find.text('Holdings Ledger'), findsOneWidget);
    expect(find.text('Add Transaction'), findsOneWidget);
    expect(find.text('NVDA'), findsWidgets);
  });
}
