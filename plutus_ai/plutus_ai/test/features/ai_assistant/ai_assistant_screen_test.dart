import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plutus_ai/features/ai_assistant/screens/ai_assistant_screen.dart';

void main() {
  testWidgets('AiAssistantScreen renders copilot header and initial guidance',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: AiAssistantScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('PLUTUS AI Copilot'), findsOneWidget);
    expect(find.text('PLUTUS AI'), findsWidgets);
    expect(find.byType(TextField), findsOneWidget);
  });
}
