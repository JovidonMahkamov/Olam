class CustomerPurchaseModel {
  final String id;         // sotuv_id
  final String productId;  // mahsulot_id
  final String productName;
  final String productCode;
  final String? imageUrl;

  // miqdorlar (sotib olingan)
  final double qtyDona;
  final double qtyPachka;
  final double qtyMetr;

  // narxlar
  final double narxMetrUsd;
  final double narxPachkaUsd;
  final double narxDonaUsd;
  final double jamiUsd;

  final bool hasDebt;

  const CustomerPurchaseModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productCode,
    this.imageUrl,
    required this.qtyDona,
    required this.qtyPachka,
    required this.qtyMetr,
    required this.narxMetrUsd,
    required this.narxPachkaUsd,
    required this.narxDonaUsd,
    required this.jamiUsd,
    this.hasDebt = false,
  });

  factory CustomerPurchaseModel.fromElementJson(
      Map<String, dynamic> e,
      Map<String, dynamic> sotuv,
      ) {
    return CustomerPurchaseModel(
      id:           sotuv['id'].toString(),
      productId:    e['mahsulot_id'].toString(),
      productName:  e['mahsulot_nomi'] ?? '',
      productCode:  '',
      imageUrl:     e['rasm_url'],
      qtyDona:      (e['dona'] ?? 0).toDouble(),
      qtyPachka:    (e['pachtka'] ?? 0).toDouble(),
      qtyMetr:      (e['metr'] ?? 0).toDouble(),
      narxMetrUsd:  (e['narx_metr'] ?? e['narx_usd'] ?? 0).toDouble(),
      narxPachkaUsd:(e['narx_pochka'] ?? e['narx_usd'] ?? 0).toDouble(),
      narxDonaUsd:  (e['narx_usd'] ?? 0).toDouble(),
      jamiUsd:      (e['jami_usd'] ?? 0).toDouble(),
      hasDebt:      (sotuv['qarz_usd'] ?? 0) > 0,
    );
  }
}