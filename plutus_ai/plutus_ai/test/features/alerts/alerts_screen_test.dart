import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plutus_ai/features/alerts/screens/alerts_screen.dart';

void main() {
  testWidgets('AlertsScreen renders alert feed and filter chips',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: AlertsScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Alerts & Real-Time Intelligence'), findsOneWidget);
    expect(find.text('Asset Concentration Warning'), findsOneWidget);
    expect(find.text('Mark All Read'), findsOneWidget);
  });
}
