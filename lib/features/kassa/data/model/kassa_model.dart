import 'package:olam/features/kassa/domain/entity/kassa_entity.dart';

class KassaModel extends KassaEntity {
  const KassaModel({
    required super.id,
    required super.turi,
    required super.balansUsd,
  });

  factory KassaModel.fromJson(Map<String, dynamic> json) {
    return KassaModel(
      id:        json['id'] ?? 0,
      turi:      json['turi'] ?? '',
      balansUsd: (json['balans_usd'] ?? 0).toDouble(),
    );
  }
}

class BugungiSotuvModel extends BugungiSotuvEntity {
  const BugungiSotuvModel({
    required super.id,
    required super.mijozId,
    super.mijozFish,
    required super.jamiUsd,
    required super.tolovQilinganUsd,
    required super.qarzUsd,
    required super.tolovTuri,
    required super.sana,
  });

  factory BugungiSotuvModel.fromJson(Map<String, dynamic> json) {
    return BugungiSotuvModel(
      id:               json['id'] ?? 0,
      mijozId:          json['mijoz_id'] ?? 0,
      mijozFish:        json['mijoz_fish'],
      jamiUsd:          (json['jami_usd'] ?? 0).toDouble(),
      tolovQilinganUsd: (json['tolov_qilingan_usd'] ?? 0).toDouble(),
      qarzUsd:          (json['qarz_usd'] ?? 0).toDouble(),
      tolovTuri:        json['tolov_turi'] ?? 'naqd',
      sana:             json['sana'] ?? '',
    );
  }
}

class BugungiQaytarishModel extends BugungiQaytarishEntity {
  const BugungiQaytarishModel({
    required super.id,
    required super.mijozId,
    super.mijozFish,
    required super.jamiUsd,
    required super.tolovTuri,
    required super.sana,
  });

  factory BugungiQaytarishModel.fromJson(Map<String, dynamic> json) {
    return BugungiQaytarishModel(
      id:        json['id'] ?? 0,
      mijozId:   json['mijoz_id'] ?? 0,
      mijozFish: json['mijoz_fish'],
      jamiUsd:   (json['jami_usd'] ?? 0).toDouble(),
      tolovTuri: json['tolov_turi'] ?? 'naqd',
      sana:      json['sana'] ?? '',
    );
  }
}

class QarzdorMijozModel extends QarzdorMijozEntity {
  const QarzdorMijozModel({
    required super.id,
    required super.fish,
    super.telefon,
    required super.qarzdorlik,
  });

  factory QarzdorMijozModel.fromJson(Map<String, dynamic> json) {
    return QarzdorMijozModel(
      id:          json['id'] ?? 0,
      fish:        json['fish'] ?? '',
      telefon:     json['telefon'],
      qarzdorlik:  (json['qarzdorlik'] ?? 0).toDouble(),
    );
  }
}