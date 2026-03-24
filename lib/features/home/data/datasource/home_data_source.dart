import 'package:olam/features/home/data/model/mahsulot_model.dart';
import 'package:olam/features/home/data/model/mijoz_model.dart';
import 'package:olam/features/home/data/model/sotuv_model.dart';

abstract class HomeDataSource {
  /// Mahsulotlar
  Future<MahsulotlarResponseModel> getMahsulotlar({String? q, int sahifa});

  /// Mijozlar
  Future<MijozlarResponseModel> getMijozlar({String? q});
  Future<MijozModel> postMijoz({required String fish, String? telefon, String? manzil});

  /// Sotuvlar
  Future<List<SotuvModel>> getSotuvlar();
  Future<SotuvModel> postSotuv({required String nomi, required int mijozId});
  Future<void> deleteSotuv({required int id});
  Future<SotuvElementModel> postSotuvElement({
    required int sotuvId,
    required int mahsulotId,
    double dona,
    double pachtka,
    double metr,
    required double narxUsd,
  });
  Future<SotuvModel> yakunlashSotuv({
    required int sotuvId,
    required String tolovTuri,
    required double tolovQilinganUsd,
    bool chegirma,
    bool sms,
    String? izoh,
  });
}