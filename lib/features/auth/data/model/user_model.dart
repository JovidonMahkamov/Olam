import 'package:olam/features/auth/domain/entity/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.fish,
    required super.login,
    required super.telefon,
    required super.yaratilgan,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:         json['id'] as int,
      fish:       json['fish'] as String? ?? '',
      login:      json['login'] as String? ?? '',
      telefon:    json['telefon'] as String? ?? '',
      yaratilgan: json['yaratilgan'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id':         id,
      'fish':       fish,
      'login':      login,
      'telefon':    telefon,
      'yaratilgan': yaratilgan,
    };
  }
}