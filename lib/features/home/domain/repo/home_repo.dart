import 'package:olam/features/home/domain/entity/mahsulot_entity.dart';
import 'package:olam/features/home/domain/entity/mijoz_entity.dart';
import 'package:olam/features/home/domain/entity/sotuv_entity.dart';

abstract class HomeRepository {
  Future<MahsulotlarResponseEntity> getMahsulotlar({String? q, int sahifa});
  Future<MijozlarResponseEntity> getMijozlar({String? q});
  Future<MijozEntity> postMijoz({required String fish, String? telefon, String? manzil});
  Future<List<SotuvEntity>> getSotuvlar();
  Future<SotuvEntity> postSotuv({required String nomi, required int mijozId});
  Future<void> deleteSotuv({required int id});
  Future<SotuvElementEntity> postSotuvElement({
    required int sotuvId,
    required int mahsulotId,
    double dona,
    double pachtka,
    double metr,
    required double narxUsd,
  });
  Future<SotuvEntity> yakunlashSotuv({
    required int sotuvId,
    required String tolovTuri,
    required double tolovQilinganUsd,
    bool chegirma,
    bool sms,
    String? izoh,
  });
}