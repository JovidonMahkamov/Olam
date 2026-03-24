import 'package:flutter/foundation.dart';
import 'package:olam/core/utils/money_fmt.dart';

@immutable
class SaleSelectedItemModel {
  final int productId;
  final String productName;
  final String productCode;
  final String skuTag;
  final String? imageUrl;

  /// Miqdorlar
  final double soldPachka;
  final double soldDona;
  final double soldMetr;

  /// Admin narxlar (readonly ko‘rsatish uchun)
  final double adminPriceDonaUsd;
  final double adminPricePachkaUsd;
  final double adminPriceMetrUsd;

  /// Ishchi kiritgan narxlar (unit price)
  /// Qoidang bo‘yicha faqat bittasi > 0 bo‘ladi, qolganlari 0.
  final double priceDonaUsd;
  final double pricePachkaUsd;
  final double priceMetrUsd;

  /// Jami kelishilgan summa (USD)
  final double agreedTotalUsd;

  const SaleSelectedItemModel({
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.skuTag,
    required this.imageUrl,

    required this.soldPachka,
    required this.soldDona,
    required this.soldMetr,

    required this.adminPriceDonaUsd,
    required this.adminPricePachkaUsd,
    required this.adminPriceMetrUsd,

    required this.priceDonaUsd,
    required this.pricePachkaUsd,
    required this.priceMetrUsd,

    required this.agreedTotalUsd,
  });

  /// Qaysi turda sotilganini aniqlash
  bool get isMetrSale => soldMetr > 0;

  bool get isDonaSale => soldDona > 0;

  bool get isPachkaSale => soldPachka > 0;

  /// UI uchun: qaysi unit narx ishlatilgan
  double get usedUnitPriceUsd {
    if (isMetrSale) return priceMetrUsd;
    if (isDonaSale) return priceDonaUsd;
    if (isPachkaSale) return pricePachkaUsd;
    return 0;
  }

  /// UI uchun: qaysi admin narx tegishli
  double get usedAdminPriceUsd {
    if (isMetrSale) return adminPriceMetrUsd;
    if (isDonaSale) return adminPriceDonaUsd;
    if (isPachkaSale) return adminPricePachkaUsd;
    return 0;
  }

  /// UI uchun: label
  String get unitLabel {
    if (isMetrSale) return "metr";
    if (isDonaSale) return "dona";
    if (isPachkaSale) return "pachka";
    return "-";
  }

  /// Valyuta konvertatsiya (hozircha fixed)
  int get totalUzs => MoneyFmt.usdToUzsInt(agreedTotalUsd);

  double get totalUsd => agreedTotalUsd;

  /// Xohlasang debug/print uchun
  @override
  String toString() {
    return 'SaleSelectedItemModel(productId: $productId, sold: pachka=$soldPachka, dona=$soldDona, metr=$soldMetr, agreedTotalUsd: $agreedTotalUsd)';
  }
}