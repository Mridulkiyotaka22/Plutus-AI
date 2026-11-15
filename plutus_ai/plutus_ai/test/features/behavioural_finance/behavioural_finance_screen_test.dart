import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plutus_ai/features/behavioural_finance/screens/behavioural_finance_screen.dart';

void main() {
  testWidgets(
      'BehaviouralFinanceScreen renders composite risk psychology profile',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: BehaviouralFinanceScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Behavioural Finance & Risk Psychology'), findsOneWidget);
    expect(find.text('Assertive / Growth Oriented'), findsOneWidget);
    expect(find.text('Loss Aversion Index'), findsOneWidget);
    expect(find.text('Retake Assessment'), findsOneWidget);
  });
}
