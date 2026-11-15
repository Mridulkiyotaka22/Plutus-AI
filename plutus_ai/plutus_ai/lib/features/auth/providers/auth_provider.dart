import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/env_config.dart';
import '../../../config/environment_provider.dart';
import '../models/user_model.dart';
import '../repositories/api_auth_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/mock_auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  if (environment == Environment.demo) {
    return MockAuthRepository();
  }
  return ApiAuthRepository();
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository, {required bool isDemo})
      : super(AuthState(
          user: isDemo ? UserModel.demoUser : null,
          isAuthenticated: isDemo,
          isLoading: !isDemo,
        )) {
    _init();
  }

  Future<void> _init() async {
    try {
      final user = await _repository.getCurrentUser();
      state = AuthState(
        user: user,
        isAuthenticated: user != null,
        isLoading: false,
      );
    } catch (error) {
      state = AuthState(
        isLoading: false,
        errorMessage: _friendlyError(error),
      );
    }
  }

  String _friendlyError(Object error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        return 'Cannot connect to the PLUTUS backend. Make sure Django is running.';
      }
      final data = error.response?.data;
      if (data is Map && data['detail'] is String) return data['detail'] as String;
    }
    return error.toString().replaceFirst('Exception: ', '');
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user =
          await _repository.login(username: username, password: password);
      state =
          state.copyWith(user: user, isLoading: false, isAuthenticated: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _friendlyError(e));
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repository.register(
        username: username,
        email: email,
        password: password,
      );
      state =
          state.copyWith(user: user, isLoading: false, isAuthenticated: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _friendlyError(e));
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(user: null, isAuthenticated: false);
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo, isDemo: environment == Environment.demo);
});
