import 'package:olam/features/kassa/domain/entity/kassa_entity.dart';

// Kassa balansi
abstract class KassaState {}
class KassaInitial extends KassaState {}
class KassaLoading extends KassaState {}
class KassaSuccess extends KassaState {
  final List<KassaEntity> kassalar;
  KassaSuccess({required this.kassalar});
}
class KassaError extends KassaState {
  final String message;
  KassaError({required this.message});
}

// Bugungi sotuvlar
abstract class BugungiSotuvState {}
class BugungiSotuvInitial extends BugungiSotuvState {}
class BugungiSotuvLoading extends BugungiSotuvState {}
class BugungiSotuvSuccess extends BugungiSotuvState {
  final BugungiSotuvStat stat;
  BugungiSotuvSuccess({required this.stat});
}
class BugungiSotuvError extends BugungiSotuvState {
  final String message;
  BugungiSotuvError({required this.message});
}

// Qarzdor mijozlar
abstract class QarzdorState {}
class QarzdorInitial extends QarzdorState {}
class QarzdorLoading extends QarzdorState {}
class QarzdorSuccess extends QarzdorState {
  final List<QarzdorMijozEntity> mijozlar;
  QarzdorSuccess({required this.mijozlar});
}
class QarzdorError extends QarzdorState {
  final String message;
  QarzdorError({required this.message});
}

// Kirim qo'shish
abstract class KirimState {}
class KirimInitial extends KirimState {}
class KirimLoading extends KirimState {}
class KirimSuccess extends KirimState {}
class KirimError extends KirimState {
  final String message;
  KirimError({required this.message});
}