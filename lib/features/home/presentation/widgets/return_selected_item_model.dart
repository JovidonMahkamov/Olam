class ReturnSelectedItemModel {
  final String sotuvId;
  final String productId;
  final String productName;
  final String productCode;
  final String? imageUrl;

  final double returnPachka;
  final double returnDona;
  final double returnMetr;

  final double pricePachkaUsd;
  final double priceDonaUsd;
  final double priceMetrUsd;

  final double returnTotalUsd;

  const ReturnSelectedItemModel({
    required this.sotuvId,
    required this.productId,
    required this.productName,
    required this.productCode,
    this.imageUrl,
    required this.returnPachka,
    required this.returnDona,
    required this.returnMetr,
    required this.pricePachkaUsd,
    required this.priceDonaUsd,
    required this.priceMetrUsd,
    required this.returnTotalUsd,
  });
}