import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login({required String username, required String password});
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  });
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
}
