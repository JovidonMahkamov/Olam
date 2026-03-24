import 'package:olam/features/auth/domain/entity/auth_entity.dart';

abstract class AuthRepository {
  Future<AuthEntity> loginWorker({
    required String login,
    required String password,
  });
}
