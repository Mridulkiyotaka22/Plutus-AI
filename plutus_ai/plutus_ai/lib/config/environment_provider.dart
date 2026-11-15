import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'env_config.dart';

/// Reactive runtime mode shared by feature repositories and Settings.
final appEnvironmentProvider = StateProvider<Environment>(
  (ref) => EnvConfig.environment,
);
