import 'package:olam/features/home/domain/entity/mahsulot_entity.dart';

class MahsulotModel extends MahsulotEntity {
  const MahsulotModel({
    required super.id,
    required super.nomi,
    required super.kodi,
    super.narxDona,
    super.narxPochka,
    super.narxMetr,
    required super.narxUsd,
    super.rasmUrl,
    required super.faol,
    required super.metr,
    required super.pochka,
    required super.miqdor,
    required super.kelganNarx,
    required super.jamiNarx,
    super.qrKod,
  });

  factory MahsulotModel.fromJson(Map<String, dynamic> json) {
    return MahsulotModel(
      id:          json['id'] ?? 0,
      nomi:        json['nomi'] ?? '',
      kodi:        json['kodi'] ?? '',
      narxDona:    json['narx_dona'] != null ? (json['narx_dona'] as num).toDouble() : null,
      narxPochka:  json['narx_pochka'] != null ? (json['narx_pochka'] as num).toDouble() : null,
      narxMetr:    json['narx_metr'] != null ? (json['narx_metr'] as num).toDouble() : null,
      narxUsd:     (json['narx_usd'] ?? 0).toDouble(),
      rasmUrl:     json['rasm_url'],
      faol:        json['aktiv'] ?? json['faol'] ?? true,
      metr:        (json['metr'] ?? 0).toDouble(),
      pochka:      (json['pochka'] ?? 0).toDouble(),
      miqdor:      (json['miqdor'] ?? 0).toDouble(),
      kelganNarx:  (json['kelgan_narx'] ?? 0).toDouble(),
      jamiNarx:    (json['jami_narx'] ?? 0).toDouble(),
      qrKod:       json['qr_kod'],
    );
  }
}

class MahsulotlarResponseModel extends MahsulotlarResponseEntity {
  const MahsulotlarResponseModel({
    required super.mahsulotlar,
    required super.jami,
  });

  factory MahsulotlarResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final list = data['mahsulotlar'] as List<dynamic>? ?? [];
    final meta = data['meta'] as Map<String, dynamic>? ?? {};
    return MahsulotlarResponseModel(
      mahsulotlar: list.map((e) => MahsulotModel.fromJson(e as Map<String, dynamic>)).toList(),
      jami: meta['jami'] ?? list.length,
    );
  }
}