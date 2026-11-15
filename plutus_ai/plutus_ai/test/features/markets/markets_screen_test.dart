import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plutus_ai/features/markets/screens/markets_screen.dart';
import 'package:plutus_ai/config/env_config.dart';
import 'package:plutus_ai/config/environment_provider.dart';

void main() {
  testWidgets('MarketsScreen renders market terminal components and tickers',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvironmentProvider.overrideWith((ref) => Environment.demo),
        ],
        child: const MaterialApp(
          home: Scaffold(body: MarketsScreen()),
        ),
      ),
    );

    // This widget uses asynchronous providers and chart transitions. A bounded
    // pump avoids hanging on indeterminate loading animations.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.text('Market Terminal'), findsOneWidget);
    expect(find.text('NVDA'), findsWidgets);
    expect(find.text('AAPL'), findsWidgets);
    expect(find.text('DEMO MARKET DATA'), findsOneWidget);
  });
}
