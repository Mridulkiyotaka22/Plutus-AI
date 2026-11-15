/// Runtime configuration for PLUTUS AI.
///
/// API mode is the default. Set PLUTUS_ENV=demo only for explicit UI prototyping.
enum Environment { demo, api }

class EnvConfig {
  EnvConfig._();

  static Environment _environment = Environment.api;

  static Future<void> initialize(Environment environment) async {
    _environment = environment;
  }

  static Environment get environment => _environment;
  static bool get isDemo => _environment == Environment.demo;

  /// Override at build time with:
  /// --dart-define=PLUTUS_API_BASE_URL=https://your-domain.example/api/v1
  static const String apiBaseUrl = String.fromEnvironment(
    'PLUTUS_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1/',
  );

  /// Select the initial mode at launch. Defaults to the Django API.
  static const String _launchMode = String.fromEnvironment(
    'PLUTUS_ENV',
    defaultValue: 'api',
  );

  static Environment get launchEnvironment =>
      _launchMode.toLowerCase() == 'api' ? Environment.api : Environment.demo;

  /// Dio resolves relative paths against a base URL ending in a slash.
  static String get normalizedApiBaseUrl {
    final value = apiBaseUrl.trim();
    return value.endsWith('/') ? value : '$value/';
  }
}
