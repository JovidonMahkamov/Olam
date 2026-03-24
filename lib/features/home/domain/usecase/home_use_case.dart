import 'package:olam/features/home/domain/entity/mahsulot_entity.dart';
import 'package:olam/features/home/domain/entity/mijoz_entity.dart';
import 'package:olam/features/home/domain/entity/sotuv_entity.dart';
import 'package:olam/features/home/domain/repo/home_repo.dart';

class GetMahsulotlarUseCase {
  final HomeRepository repo;
  GetMahsulotlarUseCase(this.repo);
  Future<MahsulotlarResponseEntity> call({String? q, int sahifa = 1}) =>
      repo.getMahsulotlar(q: q, sahifa: sahifa);
}

class GetMijozlarUseCase {
  final HomeRepository repo;
  GetMijozlarUseCase(this.repo);
  Future<MijozlarResponseEntity> call({String? q}) => repo.getMijozlar(q: q);
}

class PostMijozUseCase {
  final HomeRepository repo;
  PostMijozUseCase(this.repo);
  Future<MijozEntity> call({required String fish, String? telefon, String? manzil}) =>
      repo.postMijoz(fish: fish, telefon: telefon, manzil: manzil);
}

class GetSotuvlarUseCase {
  final HomeRepository repo;
  GetSotuvlarUseCase(this.repo);
  Future<List<SotuvEntity>> call() => repo.getSotuvlar();
}

class PostSotuvUseCase {
  final HomeRepository repo;
  PostSotuvUseCase(this.repo);
  Future<SotuvEntity> call({required String nomi, required int mijozId}) =>
      repo.postSotuv(nomi: nomi, mijozId: mijozId);
}

class DeleteSotuvUseCase {
  final HomeRepository repo;
  DeleteSotuvUseCase(this.repo);
  Future<void> call({required int id}) => repo.deleteSotuv(id: id);
}

class PostSotuvElementUseCase {
  final HomeRepository repo;
  PostSotuvElementUseCase(this.repo);
  Future<SotuvElementEntity> call({
    required int sotuvId,
    required int mahsulotId,
    double dona = 0,
    double pachtka = 0,
    double metr = 0,
    required double narxUsd,
  }) =>
      repo.postSotuvElement(
        sotuvId: sotuvId,
        mahsulotId: mahsulotId,
        dona: dona,
        pachtka: pachtka,
        metr: metr,
        narxUsd: narxUsd,
      );
}

class YakunlashSotuvUseCase {
  final HomeRepository repo;
  YakunlashSotuvUseCase(this.repo);
  Future<SotuvEntity> call({
    required int sotuvId,
    required String tolovTuri,
    required double tolovQilinganUsd,
    bool chegirma = false,
    bool sms = false,
    String? izoh,
  }) =>
      repo.yakunlashSotuv(
        sotuvId: sotuvId,
        tolovTuri: tolovTuri,
        tolovQilinganUsd: tolovQilinganUsd,
        chegirma: chegirma,
        sms: sms,
        izoh: izoh,
      );
}