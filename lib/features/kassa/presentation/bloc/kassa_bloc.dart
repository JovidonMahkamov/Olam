import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:olam/features/kassa/data/datasource/kassa_data_source.dart';
import 'kassa_event.dart';
import 'kassa_state.dart';

class KassaBloc extends Bloc<KassaEvent, KassaState> {
  final KassaDataSource dataSource;
  KassaBloc({required this.dataSource}) : super(KassaInitial()) {
    on<GetKassalarE>((event, emit) async {
      emit(KassaLoading());
      try {
        final kassalar = await dataSource.getKassalar();
        emit(KassaSuccess(kassalar: kassalar));
      } catch (e) {
        emit(KassaError(message: "Kassa ma'lumotlarini olishda xato"));
      }
    });
  }
}

class BugungiSotuvBloc extends Bloc<KassaEvent, BugungiSotuvState> {
  final KassaDataSource dataSource;
  BugungiSotuvBloc({required this.dataSource}) : super(BugungiSotuvInitial()) {
    on<GetBugungiSotuvlarE>((event, emit) async {
      emit(BugungiSotuvLoading());
      try {
        final stat = await dataSource.getBugungiSotuvlar();
        emit(BugungiSotuvSuccess(stat: stat));
      } catch (e) {
        emit(BugungiSotuvError(message: "Bugungi sotuvlarni olishda xato"));
      }
    });
  }
}

class QarzdorBloc extends Bloc<KassaEvent, QarzdorState> {
  final KassaDataSource dataSource;
  QarzdorBloc({required this.dataSource}) : super(QarzdorInitial()) {
    on<GetQarzdorMijozlarE>((event, emit) async {
      emit(QarzdorLoading());
      try {
        final mijozlar = await dataSource.getQarzdorMijozlar();
        emit(QarzdorSuccess(mijozlar: mijozlar));
      } catch (e) {
        emit(QarzdorError(message: "Qarzdor mijozlarni olishda xato"));
      }
    });
  }
}

class KirimBloc extends Bloc<KassaEvent, KirimState> {
  final KassaDataSource dataSource;
  KirimBloc({required this.dataSource}) : super(KirimInitial()) {
    on<AddKirimE>((event, emit) async {
      emit(KirimLoading());
      try {
        await dataSource.addKirim(
          kassaId:      event.kassaId,
          mijozId:      event.mijozId,
          summaUsd:     event.summaUsd,
          smsYuborildi: event.smsYuborildi,
          izoh:         event.izoh,
        );
        emit(KirimSuccess());
      } catch (e) {
        emit(KirimError(message: "Kirim qo'shishda xato"));
      }
    });

    on<UpdateMijozQarzE>((event, emit) async {
      try {
        await dataSource.updateMijozQarz(
          mijozId:    event.mijozId,
          yangiQarz:  event.yangiQarz,
        );
      } catch (e) {
        // silent
      }
    });
  }
}