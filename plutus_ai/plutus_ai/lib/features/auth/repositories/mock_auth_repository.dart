import '../models/user_model.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  UserModel? _currentUser = UserModel.demoUser;

  @override
  Future<UserModel> login(
      {required String username, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = UserModel(
      id: 'usr-demo-001',
      username: username.isNotEmpty ? username : 'demo_user',
      email: '$username@plutus.ai',
      firstName: 'Mridul',
      lastName: 'Investor',
    );
    return _currentUser!;
  }

  @override
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = UserModel(
      id: 'usr-new-${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      email: email,
      firstName: firstName ?? 'New',
      lastName: lastName ?? 'Investor',
    );
    return _currentUser!;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser ?? UserModel.demoUser;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _currentUser = null;
  }
}
