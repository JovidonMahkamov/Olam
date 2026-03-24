import 'package:olam/features/auth/data/model/user_model.dart';
import 'package:olam/features/auth/domain/entity/auth_entity.dart';

class AuthModel extends AuthEntity {
  const AuthModel({
    required super.accessToken,
    required super.refreshToken,
    required super.foydalanuvchi,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return AuthModel(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
      foydalanuvchi: UserModel.fromJson(
        data['foydalanuvchi'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'foydalanuvchi': (foydalanuvchi as UserModel).toJson(),
    };
  }
}
