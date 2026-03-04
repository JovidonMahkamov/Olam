import 'package:shared_preferences/shared_preferences.dart';

class ExchangeRateLocalDs {
  static const _kRate = 'usd_to_uzs_rate';
  static const _kUpdatedAt = 'usd_to_uzs_updated_at';

  Future<void> save(double rate) async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kRate, rate);
    await p.setString(_kUpdatedAt, DateTime.now().toIso8601String());
  }

  Future<double?> readRate() async {
    final p = await SharedPreferences.getInstance();
    return p.getDouble(_kRate);
  }

  Future<DateTime?> readUpdatedAt() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_kUpdatedAt);
    return s == null ? null : DateTime.tryParse(s);
  }
}