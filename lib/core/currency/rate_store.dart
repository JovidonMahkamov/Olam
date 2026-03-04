import 'package:flutter/foundation.dart';
import 'exchange_rate_repo.dart';

class RateStore extends ChangeNotifier {
  final ExchangeRateRepo repo;

  RateStore(this.repo);

  double usdToUzs = 12000;
  DateTime? updatedAt;

  Future<void> refresh() async {
    final r = await repo.getUsdToUzs();
    usdToUzs = r.usdToUzs;
    updatedAt = r.updatedAt;
    notifyListeners();
  }
}