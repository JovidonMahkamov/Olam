
import 'package:olam/features/customer/domain/entity/meta_entity.dart';

class MetaModel extends MetaEntity {
  MetaModel({
    required super.sahifa,
    required super.harSahifa,
    required super.jami,
    required super.sahifalar,
    required super.keyingisiBor,
    required super.oldingisiBor,
  });

  factory MetaModel.fromJson(Map<String, dynamic> json) {
    return MetaModel(
      sahifa: json['sahifa'],
      harSahifa: json['har_sahifa'],
      jami: json['jami'],
      sahifalar: json['sahifalar'],
      keyingisiBor: json['keyingisi_bor'],
      oldingisiBor: json['oldingisi_bor'],
    );
  }
}