import 'package:olam/features/auth/domain/entity/auth_entity.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final AuthEntity auth;

  AuthSuccess({required this.auth});
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure({required this.message});
}