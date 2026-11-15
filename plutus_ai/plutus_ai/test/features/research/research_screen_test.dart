import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plutus_ai/features/research/screens/research_screen.dart';

void main() {
  testWidgets('ResearchScreen renders research models and backtest metrics',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: ResearchScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Quantitative Research & AI Models'), findsOneWidget);
    expect(find.text('Information Extraction Model (IEM)'), findsOneWidget);
    expect(find.text('TimeFormer Multivariate Forecasting'), findsOneWidget);
    expect(find.text('RESEARCH / NON-PRODUCTION'), findsOneWidget);
  });
}
