import 'package:olam/features/auth/domain/entity/user_entity.dart';

class AuthEntity {
  final String accessToken;
  final String refreshToken;
  final UserEntity foydalanuvchi;

  const AuthEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.foydalanuvchi,
  });
}
