import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plutus_ai/features/settings/screens/settings_screen.dart';

void main() {
  testWidgets(
      'SettingsScreen renders configuration toggles and profile credentials',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: SettingsScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('System & Account Settings'), findsOneWidget);
    expect(find.text('Offline Demo Mode (Active)'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
  });
}
