import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:olam/features/home/domain/usecase/home_use_case.dart';
import 'home_event.dart';
import 'home_state.dart';

String _mapError(dynamic e) {
  if (e is DioException) {
    if (e.type == DioExceptionType.unknown && e.error is SocketException) {
      return 'Internet ulanmagan.';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return "So'rov vaqtida javob kelmadi.";
    }
    final msg = e.response?.data?['message']?.toString();
    if (msg != null) return msg;
  }
  return "Noma'lum xato yuz berdi.";
}

// ===== MAHSULOTLAR =====
class MahsulotlarBloc extends Bloc<HomeEvent, MahsulotlarState> {
  final GetMahsulotlarUseCase useCase;
  MahsulotlarBloc(this.useCase) : super(MahsulotlarInitial()) {
    on<GetMahsulotlarE>((event, emit) async {
      emit(MahsulotlarLoading());
      try {
        // ✅ Barcha sahifalarni yuklab olamiz
        final allMahsulotlar = <dynamic>[];
        int sahifa = 1;
        while (true) {
          final result = await useCase(q: event.q, sahifa: sahifa);
          allMahsulotlar.addAll(result.mahsulotlar);
          // Agar barcha mahsulotlar yuklangan bolsa toxtaymiz
          if (allMahsulotlar.length >= result.jami || result.mahsulotlar.isEmpty) break;
          sahifa++;
        }
        emit(MahsulotlarSuccess(mahsulotlar: List.from(allMahsulotlar)));
      } catch (e) {
        emit(MahsulotlarError(message: _mapError(e)));
      }
    });
  }
}

// ===== MIJOZLAR =====
class MijozlarBloc extends Bloc<HomeEvent, MijozlarState> {
  final GetMijozlarUseCase useCase;
  MijozlarBloc(this.useCase) : super(MijozlarInitial()) {
    on<GetMijozlarE>((event, emit) async {
      emit(MijozlarLoading());
      try {
        final result = await useCase(q: event.q);
        emit(MijozlarSuccess(mijozlar: result.mijozlar));
      } catch (e) {
        emit(MijozlarError(message: _mapError(e)));
      }
    });
  }
}

// ===== POST MIJOZ =====
class PostMijozBloc extends Bloc<HomeEvent, PostMijozState> {
  final PostMijozUseCase useCase;
  PostMijozBloc(this.useCase) : super(PostMijozInitial()) {
    on<PostMijozE>((event, emit) async {
      emit(PostMijozLoading());
      try {
        final result = await useCase(
          fish: event.fish,
          telefon: event.telefon,
          manzil: event.manzil,
        );
        emit(PostMijozSuccess(mijoz: result));
      } catch (e) {
        emit(PostMijozError(message: _mapError(e)));
      }
    });
  }
}

// ===== SOTUVLAR =====
class SotuvlarBloc extends Bloc<HomeEvent, SotuvlarState> {
  final GetSotuvlarUseCase useCase;
  SotuvlarBloc(this.useCase) : super(SotuvlarInitial()) {
    on<GetSotuvlarE>((event, emit) async {
      emit(SotuvlarLoading());
      try {
        final result = await useCase();
        emit(SotuvlarSuccess(sotuvlar: result));
      } catch (e) {
        emit(SotuvlarError(message: _mapError(e)));
      }
    });
  }
}

// ===== POST SOTUV =====
class PostSotuvBloc extends Bloc<HomeEvent, PostSotuvState> {
  final PostSotuvUseCase useCase;
  PostSotuvBloc(this.useCase) : super(PostSotuvInitial()) {
    on<PostSotuvE>((event, emit) async {
      emit(PostSotuvLoading());
      try {
        final result = await useCase(nomi: event.nomi, mijozId: event.mijozId);
        emit(PostSotuvSuccess(sotuv: result));
      } catch (e) {
        emit(PostSotuvError(message: _mapError(e)));
      }
    });
  }
}

// ===== DELETE SOTUV =====
class DeleteSotuvBloc extends Bloc<HomeEvent, DeleteSotuvState> {
  final DeleteSotuvUseCase useCase;
  DeleteSotuvBloc(this.useCase) : super(DeleteSotuvInitial()) {
    on<DeleteSotuvE>((event, emit) async {
      emit(DeleteSotuvLoading());
      try {
        await useCase(id: event.id);
        emit(DeleteSotuvSuccess());
      } catch (e) {
        emit(DeleteSotuvError(message: _mapError(e)));
      }
    });
  }
}

// ===== POST SOTUV ELEMENT =====
class PostSotuvElementBloc extends Bloc<HomeEvent, PostSotuvElementState> {
  final PostSotuvElementUseCase useCase;
  PostSotuvElementBloc(this.useCase) : super(PostSotuvElementInitial()) {
    on<PostSotuvElementE>((event, emit) async {
      emit(PostSotuvElementLoading());
      try {
        final result = await useCase(
          sotuvId:    event.sotuvId,
          mahsulotId: event.mahsulotId,
          dona:       event.dona,
          pachtka:    event.pachtka,
          metr:       event.metr,
          narxUsd:    event.narxUsd,
        );
        emit(PostSotuvElementSuccess(element: result));
      } catch (e) {
        emit(PostSotuvElementError(message: _mapError(e)));
      }
    });
  }
}

// ===== YAKUNLASH =====
class YakunlashSotuvBloc extends Bloc<HomeEvent, YakunlashSotuvState> {
  final YakunlashSotuvUseCase useCase;
  YakunlashSotuvBloc(this.useCase) : super(YakunlashSotuvInitial()) {
    on<YakunlashSotuvE>((event, emit) async {
      emit(YakunlashSotuvLoading());
      try {
        final result = await useCase(
          sotuvId:          event.sotuvId,
          tolovTuri:        event.tolovTuri,
          tolovQilinganUsd: event.tolovQilinganUsd,
          chegirma:         event.chegirma,
          sms:              event.sms,
          izoh:             event.izoh,
        );
        emit(YakunlashSotuvSuccess(sotuv: result));
      } catch (e) {
        emit(YakunlashSotuvError(message: _mapError(e)));
      }
    });
  }
}