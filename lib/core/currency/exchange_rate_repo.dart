import 'exchange_rate.dart';
import 'exchange_rate_local_ds.dart';
import 'exchange_rate_remote_ds.dart';

class ExchangeRateRepo {
  final ExchangeRateRemoteDs remote;
  final ExchangeRateLocalDs local;

  const ExchangeRateRepo({
    required this.remote,
    required this.local,
  });

  Future<ExchangeRate> getUsdToUzs() async {
    try {
      final rate = await remote.fetchUsdToUzs();
      await local.save(rate);
      return ExchangeRate(usdToUzs: rate, updatedAt: DateTime.now());
    } catch (_) {
      //  internet yo‘q bo‘lsa cachedan
      final cached = await local.readRate();
      final updatedAt = await local.readUpdatedAt();
      if (cached != null && updatedAt != null) {
        return ExchangeRate(usdToUzs: cached, updatedAt: updatedAt);
      }
      // oxirgi fallback (umuman bo‘lmasa)
      return ExchangeRate(usdToUzs: 12000, updatedAt: DateTime.fromMillisecondsSinceEpoch(0));
    }
  }
}