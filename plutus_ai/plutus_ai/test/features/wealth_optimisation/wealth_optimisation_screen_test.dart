import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plutus_ai/features/wealth_optimisation/screens/wealth_optimisation_screen.dart';
import 'package:plutus_ai/config/env_config.dart';
import 'package:plutus_ai/config/environment_provider.dart';

void main() {
  testWidgets(
      'WealthOptimisationScreen renders tax harvest simulator and rebalancing table',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvironmentProvider.overrideWith((ref) => Environment.demo),
        ],
        child: const MaterialApp(
          home: Scaffold(body: WealthOptimisationScreen()),
        ),
      ),
    );

    // Use deterministic in-memory test repositories; do not wait for a local
    // Django server or indeterminate loading animations.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.text('Wealth & Tax Optimisation'), findsOneWidget);
    expect(find.text('Tax-Loss Harvesting Opportunities'), findsOneWidget);
    expect(find.text('Systematic Rebalancing Simulator'), findsOneWidget);
    expect(find.text('AGG'), findsWidgets);
  });
}
