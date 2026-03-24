import 'package:olam/features/home/domain/entity/mahsulot_entity.dart';
import 'package:olam/features/home/domain/entity/mijoz_entity.dart';
import 'package:olam/features/home/domain/entity/sotuv_entity.dart';

// ===== MAHSULOTLAR =====
abstract class MahsulotlarState {}
class MahsulotlarInitial extends MahsulotlarState {}
class MahsulotlarLoading extends MahsulotlarState {}
class MahsulotlarSuccess extends MahsulotlarState {
  final List<MahsulotEntity> mahsulotlar;
  MahsulotlarSuccess({required this.mahsulotlar});
}
class MahsulotlarError extends MahsulotlarState {
  final String message;
  MahsulotlarError({required this.message});
}

// ===== MIJOZLAR =====
abstract class MijozlarState {}
class MijozlarInitial extends MijozlarState {}
class MijozlarLoading extends MijozlarState {}
class MijozlarSuccess extends MijozlarState {
  final List<MijozEntity> mijozlar;
  MijozlarSuccess({required this.mijozlar});
}
class MijozlarError extends MijozlarState {
  final String message;
  MijozlarError({required this.message});
}

// ===== POST MIJOZ =====
abstract class PostMijozState {}
class PostMijozInitial extends PostMijozState {}
class PostMijozLoading extends PostMijozState {}
class PostMijozSuccess extends PostMijozState {
  final MijozEntity mijoz;
  PostMijozSuccess({required this.mijoz});
}
class PostMijozError extends PostMijozState {
  final String message;
  PostMijozError({required this.message});
}

// ===== SOTUVLAR =====
abstract class SotuvlarState {}
class SotuvlarInitial extends SotuvlarState {}
class SotuvlarLoading extends SotuvlarState {}
class SotuvlarSuccess extends SotuvlarState {
  final List<SotuvEntity> sotuvlar;
  SotuvlarSuccess({required this.sotuvlar});
}
class SotuvlarError extends SotuvlarState {
  final String message;
  SotuvlarError({required this.message});
}

// ===== POST SOTUV =====
abstract class PostSotuvState {}
class PostSotuvInitial extends PostSotuvState {}
class PostSotuvLoading extends PostSotuvState {}
class PostSotuvSuccess extends PostSotuvState {
  final SotuvEntity sotuv;
  PostSotuvSuccess({required this.sotuv});
}
class PostSotuvError extends PostSotuvState {
  final String message;
  PostSotuvError({required this.message});
}

// ===== DELETE SOTUV =====
abstract class DeleteSotuvState {}
class DeleteSotuvInitial extends DeleteSotuvState {}
class DeleteSotuvLoading extends DeleteSotuvState {}
class DeleteSotuvSuccess extends DeleteSotuvState {}
class DeleteSotuvError extends DeleteSotuvState {
  final String message;
  DeleteSotuvError({required this.message});
}

// ===== POST SOTUV ELEMENT =====
abstract class PostSotuvElementState {}
class PostSotuvElementInitial extends PostSotuvElementState {}
class PostSotuvElementLoading extends PostSotuvElementState {}
class PostSotuvElementSuccess extends PostSotuvElementState {
  final SotuvElementEntity element;
  PostSotuvElementSuccess({required this.element});
}
class PostSotuvElementError extends PostSotuvElementState {
  final String message;
  PostSotuvElementError({required this.message});
}

// ===== YAKUNLASH =====
abstract class YakunlashSotuvState {}
class YakunlashSotuvInitial extends YakunlashSotuvState {}
class YakunlashSotuvLoading extends YakunlashSotuvState {}
class YakunlashSotuvSuccess extends YakunlashSotuvState {
  final SotuvEntity sotuv;
  YakunlashSotuvSuccess({required this.sotuv});
}
class YakunlashSotuvError extends YakunlashSotuvState {
  final String message;
  YakunlashSotuvError({required this.message});
}