class CustomerPurchaseModel {
  final String id;
  final String productId;

  // mahsulot
  final String productName;
  final String productCode; // masalan: Q 10 (A001738)
  final String imageAssetOrUrl; // hozircha asset ishlatamiz

  // miqdorlar
  final int qtyDona;
  final int qtyPachka;

  // narxlar
  final double priceUsd; // NARX
  double get totalUsd => priceUsd * qtyDona; // soddalashtirib: dona bo‘yicha

  // qarz info (shu mahsulot savdosida qarz bo‘lganmi)
  final bool hasDebt;

  const CustomerPurchaseModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.imageAssetOrUrl,
    required this.qtyDona,
    required this.qtyPachka,
    required this.priceUsd,
    required this.hasDebt,
  });
}