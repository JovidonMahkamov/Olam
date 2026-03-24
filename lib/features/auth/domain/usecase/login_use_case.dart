import 'package:olam/features/auth/domain/entity/auth_entity.dart';
import 'package:olam/features/auth/domain/repo/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthEntity> call({
    required String login,
    required String password,
  }) {
    return repository.loginWorker(login: login, password: password);
  }
}