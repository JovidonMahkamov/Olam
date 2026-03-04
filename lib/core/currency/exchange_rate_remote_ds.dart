import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeRateRemoteDs {
  //  CBU (Uzbekistan Central Bank) kurslari JSON beradi
  // Odatda USD kod: "USD"
  final Uri url = Uri.parse('https://cbu.uz/uz/arkhiv-kursov-valyut/json/');

  Future<double> fetchUsdToUzs() async {
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('Rate fetch failed: ${res.statusCode}');
    }

    final List data = jsonDecode(res.body) as List;

    // {"Ccy":"USD", "Rate":"12345.67", ...}
    final usd = data.firstWhere((e) => e['Ccy'] == 'USD', orElse: () => null);
    if (usd == null) throw Exception('USD rate not found');

    final rateStr = (usd['Rate'] as String).replaceAll(',', '.');
    return double.parse(rateStr);
  }
}