import 'package:flutter/foundation.dart';

enum ProductUnitType { dona, metr }

@immutable
class SaleProductModel {
  final int id;
  final String name;
  final String code;
  final String skuTag;
  final String? imageUrl;

  final double stockPachka;
  final double stockDona;
  final double stockMetr;

  final double adminPriceMetrUsd;
  final double adminPriceDonaUsd;
  final double adminPricePachkaUsd;

  const SaleProductModel({
    required this.id,
    required this.name,
    required this.code,
    required this.skuTag,
    required this.imageUrl,
    required this.stockPachka,
    required this.stockDona,
    required this.stockMetr,
    required this.adminPriceDonaUsd,
    required this.adminPriceMetrUsd,
    required this.adminPricePachkaUsd,
  });

  String get fullTitle => "$name $skuTag";

  SaleProductModel copyWith({
    int? id,
    String? name,
    String? code,
    String? skuTag,
    String? imageUrl,
    double? stockPachka,
    double? stockDona,
    double? stockMetr,
    double? adminPriceDonaUsd,
    double? adminPriceMetrUsd,
    double? adminPricePachkaUsd,
  }) {
    return SaleProductModel(
      id:                  id ?? this.id,
      name:                name ?? this.name,
      code:                code ?? this.code,
      skuTag:              skuTag ?? this.skuTag,
      imageUrl:            imageUrl ?? this.imageUrl,
      stockPachka:         stockPachka ?? this.stockPachka,
      stockDona:           stockDona ?? this.stockDona,
      stockMetr:           stockMetr ?? this.stockMetr,
      adminPriceMetrUsd:   adminPriceMetrUsd ?? this.adminPriceMetrUsd,
      adminPricePachkaUsd: adminPricePachkaUsd ?? this.adminPricePachkaUsd,
      adminPriceDonaUsd:   adminPriceDonaUsd ?? this.adminPriceDonaUsd,
    );
  }
}