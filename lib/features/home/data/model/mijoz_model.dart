import 'package:olam/features/home/domain/entity/mijoz_entity.dart';

class MijozModel extends MijozEntity {
  const MijozModel({
    required super.id,
    required super.fish,
    super.telefon,
    super.manzil,
    required super.qarzdorlik,
    required super.faol,
  });

  factory MijozModel.fromJson(Map<String, dynamic> json) {
    return MijozModel(
      id:          json['id'] ?? 0,
      fish:        json['fish'] ?? '',
      telefon:     json['telefon'],
      manzil:      json['manzil'],
      qarzdorlik:  (json['qarzdorlik'] ?? 0).toDouble(),
      faol:        json['faol'] ?? true,
    );
  }
}

class MijozlarResponseModel extends MijozlarResponseEntity {
  const MijozlarResponseModel({
    required super.mijozlar,
    required super.jami,
  });

  factory MijozlarResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final list = data['mijozlar'] as List<dynamic>? ?? [];
    final meta = data['meta'] as Map<String, dynamic>? ?? {};
    return MijozlarResponseModel(
      mijozlar: list.map((e) => MijozModel.fromJson(e)).toList(),
      jami: meta['jami'] ?? list.length,
    );
  }
}