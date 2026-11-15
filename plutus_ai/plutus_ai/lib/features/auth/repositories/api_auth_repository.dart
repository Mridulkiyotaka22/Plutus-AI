import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  final ApiClient _client = ApiClient();

  @override
  Future<UserModel> login({required String username, required String password}) async {
    await _client.initialize();
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        'auth/token/',
        data: {'username': username.trim(), 'password': password},
      );
      final data = response.data ?? <String, dynamic>{};
      final access = data['access'] as String?;
      final refresh = data['refresh'] as String?;
      if (access == null || access.isEmpty) {
        throw const FormatException('The server did not return an access token.');
      }
      await _client.setTokens(access: access, refresh: refresh);
      final userJson = data['user'];
      if (userJson is Map<String, dynamic>) {
        return UserModel.fromJson(userJson);
      }
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw const FormatException('Signed in, but the user profile could not be loaded.');
      }
      return currentUser;
    } on DioException catch (error) {
      throw Exception(_friendlyMessage(error));
    }
  }

  @override
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    await _client.initialize();
    try {
      await _client.dio.post<Map<String, dynamic>>(
        'auth/register/',
        data: {
          'username': username.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
          'password2': password,
          'first_name': firstName ?? '',
          'last_name': lastName ?? '',
        },
      );
      return login(username: username.trim(), password: password);
    } on DioException catch (error) {
      throw Exception(_friendlyMessage(error));
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    await _client.initialize();
    if (!_client.isAuthenticated) return null;
    try {
      final response = await _client.dio.get<Map<String, dynamic>>('profile/');
      final data = response.data;
      return data == null ? null : UserModel.fromJson(data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        await _client.clearTokens();
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<void> logout() => _client.clearTokens();

  String _friendlyMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      final detail = data['detail'];
      if (detail is String && detail.isNotEmpty) return detail;
      final messages = <String>[];
      data.forEach((key, value) {
        if (value is List) {
          messages.addAll(value.map((item) => '$item'));
        } else if (value is String) {
          messages.add(value);
        } else if (value is Map) {
          messages.addAll(value.values.expand((v) => v is List ? v : [v]).map((v) => '$v'));
        }
      });
      if (messages.isNotEmpty) return messages.join('\n');
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Cannot reach the PLUTUS server. Start Django at ${_client.dio.options.baseUrl} and try again.';
    }
    if (error.response?.statusCode == 401) return 'Invalid username/email or password.';
    return error.message ?? 'The request failed. Please try again.';
  }
}
