import 'package:olam/features/home/data/datasource/home_data_source.dart';
import 'package:olam/features/home/domain/entity/mahsulot_entity.dart';
import 'package:olam/features/home/domain/entity/mijoz_entity.dart';
import 'package:olam/features/home/domain/entity/sotuv_entity.dart';
import 'package:olam/features/home/domain/repo/home_repo.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeDataSource remote;

  HomeRepositoryImpl({required this.remote});

  @override
  Future<MahsulotlarResponseEntity> getMahsulotlar({String? q, int sahifa = 1}) =>
      remote.getMahsulotlar(q: q, sahifa: sahifa);

  @override
  Future<MijozlarResponseEntity> getMijozlar({String? q}) =>
      remote.getMijozlar(q: q);

  @override
  Future<MijozEntity> postMijoz({required String fish, String? telefon, String? manzil}) =>
      remote.postMijoz(fish: fish, telefon: telefon, manzil: manzil);

  @override
  Future<List<SotuvEntity>> getSotuvlar() => remote.getSotuvlar();

  @override
  Future<SotuvEntity> postSotuv({required String nomi, required int mijozId}) =>
      remote.postSotuv(nomi: nomi, mijozId: mijozId);

  @override
  Future<void> deleteSotuv({required int id}) => remote.deleteSotuv(id: id);

  @override
  Future<SotuvElementEntity> postSotuvElement({
    required int sotuvId,
    required int mahsulotId,
    double dona = 0,
    double pachtka = 0,
    double metr = 0,
    required double narxUsd,
  }) =>
      remote.postSotuvElement(
        sotuvId: sotuvId,
        mahsulotId: mahsulotId,
        dona: dona,
        pachtka: pachtka,
        metr: metr,
        narxUsd: narxUsd,
      );

  @override
  Future<SotuvEntity> yakunlashSotuv({
    required int sotuvId,
    required String tolovTuri,
    required double tolovQilinganUsd,
    bool chegirma = false,
    bool sms = false,
    String? izoh,
  }) =>
      remote.yakunlashSotuv(
        sotuvId: sotuvId,
        tolovTuri: tolovTuri,
        tolovQilinganUsd: tolovQilinganUsd,
        chegirma: chegirma,
        sms: sms,
        izoh: izoh,
      );
}