class ReturnSelectedItemModel {
  final String purchaseId; // history list item id
  final String productId;
  final String productName;
  final String productCode;
  final String imageUrl;

  // qaytariladigan miqdorlar (faqat bittasi >0 bo‘lsin)
  final int returnPachka;
  final int returnDona;
  final int returnMetr;

  // qaytarish unit narxlari (faqat tanlangan unit >0)
  final double pricePachkaUsd;
  final double priceDonaUsd;
  final double priceMetrUsd;

  final double returnTotalUsd;

  const ReturnSelectedItemModel({
    required this.purchaseId,
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.imageUrl,
    required this.returnPachka,
    required this.returnDona,
    required this.returnMetr,
    required this.pricePachkaUsd,
    required this.priceDonaUsd,
    required this.priceMetrUsd,
    required this.returnTotalUsd,
  });
}