import 'package:olam/features/home/domain/entity/sotuv_entity.dart';

class SotuvModel extends SotuvEntity {
  const SotuvModel({
    required super.id,
    required super.nomi,
    required super.mijozId,
    required super.sotuvchiId,
    required super.jamiUsd,
    required super.tolovQilinganUsd,
    required super.qarzUsd,
    required super.tolovTuri,
    required super.holat,
    required super.chegirma,
    required super.sms,
    super.izoh,
    required super.sana,
  });

  factory SotuvModel.fromJson(Map<String, dynamic> json) {
    return SotuvModel(
      id:               json['id'] ?? 0,
      nomi:             json['nomi'] ?? '',
      mijozId:          json['mijoz_id'] ?? 0,
      sotuvchiId:       json['sotuvchi_id'] ?? 0,
      jamiUsd:          (json['jami_usd'] ?? 0).toDouble(),
      tolovQilinganUsd: (json['tolov_qilingan_usd'] ?? 0).toDouble(),
      qarzUsd:          (json['qarz_usd'] ?? 0).toDouble(),
      tolovTuri:        json['tolov_turi'] ?? 'naqd',
      holat:            json['holat'] ?? 'aktiv',
      chegirma:         json['chegirma'] ?? false,
      sms:              json['sms'] ?? false,
      izoh:             json['izoh'],
      sana:             json['sana'] ?? '',
    );
  }
}

class SotuvElementModel extends SotuvElementEntity {
  const SotuvElementModel({
    required super.id,
    required super.sotuvId,
    required super.mahsulotId,
    required super.dona,
    required super.pachtka,
    required super.metr,
    required super.narxUsd,
    required super.jamiUsd,
  });

  factory SotuvElementModel.fromJson(Map<String, dynamic> json) {
    return SotuvElementModel(
      id:         json['id'] ?? 0,
      sotuvId:    json['sotuv_id'] ?? 0,
      mahsulotId: json['mahsulot_id'] ?? 0,
      dona:       (json['dona'] ?? 0).toDouble(),
      pachtka:    (json['pachtka'] ?? 0).toDouble(),
      metr:       (json['metr'] ?? 0).toDouble(),
      narxUsd:    (json['narx_usd'] ?? 0).toDouble(),
      jamiUsd:    (json['jami_usd'] ?? 0).toDouble(),
    );
  }
}