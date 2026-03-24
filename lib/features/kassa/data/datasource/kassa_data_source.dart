import 'package:olam/core/networks/api_urls.dart';
import 'package:olam/core/networks/dio_client.dart';
import 'package:olam/features/kassa/data/model/kassa_model.dart';
import 'package:olam/features/kassa/domain/entity/kassa_entity.dart';

class KassaDataSource {
  final DioClient dioClient;
  KassaDataSource({required this.dioClient});

  // Kassalar balansi
  Future<List<KassaModel>> getKassalar() async {
    final response = await dioClient.get(ApiUrls.getKassalar);
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) => KassaModel.fromJson(e)).toList();
  }

  // Bugungi stat (sotuvlar + kirimlar) — yangi endpoint
  Future<BugungiSotuvStat> getBugungiSotuvlar() async {
    final response = await dioClient.get(ApiUrls.bugunStat);
    final data = response.data['data'] as Map<String, dynamic>;
    final list = (data['sotuvlar'] as List<dynamic>? ?? []);
    final sotuvlar = list.map((e) => BugungiSotuvModel.fromJson(e)).toList();

    return BugungiSotuvStat(
      naqdJami:     (data['naqd'] ?? 0).toDouble(),
      terminalJami: (data['terminal'] ?? 0).toDouble(),
      clickJami:    (data['click'] ?? 0).toDouble(),
      qarzJami:     (data['qarz'] ?? 0).toDouble(),
      sotuvlarSoni: data['sotuvlar_soni'] ?? 0,
      sotuvlar:     sotuvlar,
      kirimNaqd:    (data['kirim_naqd'] ?? 0).toDouble(),
      kirimTerminal:(data['kirim_terminal'] ?? 0).toDouble(),
      kirimClick:   (data['kirim_click'] ?? 0).toDouble(),
      kirimJami:    (data['kirim_jami'] ?? 0).toDouble(),
    );
  }

  // Qarzdor mijozlar
  Future<List<QarzdorMijozModel>> getQarzdorMijozlar() async {
    final response = await dioClient.get(
      ApiUrls.getMijozlar,
      queryParams: {'qarzdorlar': 'true'},
    );
    final list = response.data['data']['mijozlar'] as List<dynamic>? ?? [];
    return list
        .where((m) => (m['qarzdorlik'] ?? 0) > 0)
        .map((m) => QarzdorMijozModel.fromJson(m))
        .toList();
  }

  // Kassaga kirim qo'shish
  Future<void> addKirim({
    required int kassaId,
    required int mijozId,
    required double summaUsd,
    required bool smsYuborildi,
    String? izoh,
  }) async {
    await dioClient.post(
      '${ApiUrls.kassaKirim}$kassaId/kirim',
      data: {
        'mijoz_id':      mijozId,
        'summa_usd':     summaUsd,
        'sms_yuborildi': smsYuborildi,
        'izoh':          izoh,
      },
    );
  }

  // Mijoz qarzini yangilash
  Future<void> updateMijozQarz({
    required int mijozId,
    required double yangiQarz,
  }) async {
    await dioClient.patch(
      '${ApiUrls.getMijozlar}$mijozId',
      data: {'qarzdorlik': yangiQarz < 0.01 ? 0 : yangiQarz},
    );
  }
}