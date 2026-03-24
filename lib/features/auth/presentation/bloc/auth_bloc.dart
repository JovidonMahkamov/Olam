import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:olam/features/auth/domain/usecase/login_use_case.dart';
import 'package:olam/features/auth/presentation/bloc/auth_event.dart';
import 'package:olam/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;

  AuthBloc(this.loginUseCase) : super(AuthInitial()) {
    on<LoginEvent>(onLogInUser);
  }

  Future<void> onLogInUser(event, emit) async {
    emit(AuthLoading());
    try {
      final result = await loginUseCase(
        login: event.login,
        password: event.password,
      );
      emit(AuthSuccess(auth: result));
    } on DioException catch (e) {
      String errorMessage = _mapDioErrorToMessage(e);
      emit(AuthFailure(message: errorMessage));
    } catch (e) {
      emit(AuthFailure(message: "Noma'lum xato yuz berdi"));
    }
  }

  String _mapDioErrorToMessage(DioException error) {
    if (error.type == DioExceptionType.unknown &&
        error.error is SocketException) {
      return "Internet ulanmagan. Iltimos, tarmoqni tekshiring.";
    } else if (error.response?.statusCode == 401) {
      return "Login yoki parol xato. Qayta urinib ko'ring.";
    } else if (error.response?.statusCode == 400) {
      return "So'rov noto'g'ri yuborildi.";
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return "So'rov vaqtida javob kelmadi. Keyinroq urinib ko'ring.";
    } else if (error.response?.statusCode == 500) {
      return "Serverda nosozlik bor. Iltimos, keyinroq urinib ko'ring.";
    }
    return "Noma'lum xato yuz berdi. Iltimos, qayta urinib ko'ring.";
  }
}