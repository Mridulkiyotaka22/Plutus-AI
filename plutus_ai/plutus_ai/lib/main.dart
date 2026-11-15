import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'config/env_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Environment Configuration (API mode by default)
  await EnvConfig.initialize(EnvConfig.launchEnvironment);

  runApp(
    const ProviderScope(
      child: PlutusApp(),
    ),
  );
}
