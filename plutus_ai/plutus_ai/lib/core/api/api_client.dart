import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../config/env_config.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _accessKey = 'plutus_access_token';
  static const String _refreshKey = 'plutus_refresh_token';

  late final Dio dio;
  String? _accessToken;
  String? _refreshToken;
  Future<void>? _initialization;
  Future<bool>? _refreshing;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.normalizedApiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 15),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          await initialize();
          if (_accessToken != null && _accessToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final alreadyRetried = error.requestOptions.extra['authRetry'] == true;
          if (error.response?.statusCode == 401 &&
              !alreadyRetried &&
              _refreshToken != null &&
              _refreshToken!.isNotEmpty) {
            _refreshing ??= _refreshAccessToken();
            final refreshed = await _refreshing!;
            _refreshing = null;
            if (refreshed) {
              final options = error.requestOptions;
              options.extra['authRetry'] = true;
              options.headers['Authorization'] = 'Bearer $_accessToken';
              try {
                final response = await dio.fetch<dynamic>(options);
                handler.resolve(response);
                return;
              } on DioException catch (retryError) {
                handler.next(retryError);
                return;
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<void> initialize() => _initialization ??= _restoreTokens();

  Future<void> _restoreTokens() async {
    try {
      _accessToken = await _storage.read(key: _accessKey);
      _refreshToken = await _storage.read(key: _refreshKey);
    } catch (_) {
      // Authentication remains usable for the current browser session if the
      // platform does not support secure storage. Persistent sessions require
      // the browser's secure context (localhost or HTTPS).
    }
  }

  Future<void> setTokens({required String access, String? refresh}) async {
    await initialize();
    _accessToken = access;
    if (refresh != null && refresh.isNotEmpty) _refreshToken = refresh;
    try {
      await _storage.write(key: _accessKey, value: access);
      if (_refreshToken != null) {
        await _storage.write(key: _refreshKey, value: _refreshToken);
      }
    } catch (_) {
      // Keep tokens in memory if secure storage is unavailable.
    }
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    try {
      await _storage.delete(key: _accessKey);
      await _storage.delete(key: _refreshKey);
    } catch (_) {
      // In-memory authentication is still cleared.
    }
  }

  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;
  String? get accessToken => _accessToken;

  Future<bool> _refreshAccessToken() async {
    try {
      final refresh = _refreshToken;
      if (refresh == null || refresh.isEmpty) return false;
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: EnvConfig.normalizedApiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          headers: const {'Content-Type': 'application/json'},
        ),
      );
      final response = await refreshDio.post<Map<String, dynamic>>(
        'auth/token/refresh/',
        data: {'refresh': refresh},
      );
      final access = response.data?['access'] as String?;
      if (access == null || access.isEmpty) return false;
      final rotatedRefresh = response.data?['refresh'] as String?;
      await setTokens(access: access, refresh: rotatedRefresh ?? refresh);
      return true;
    } catch (_) {
      await clearTokens();
      return false;
    }
  }
}
