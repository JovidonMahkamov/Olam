import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:olam/core/currency/exchange_rate_local_ds.dart';
import 'package:olam/core/currency/exchange_rate_remote_ds.dart';
import 'package:olam/core/currency/exchange_rate_repo.dart';
import 'package:olam/core/currency/rate_store.dart';
import 'package:olam/core/utils/money_fmt.dart';
import 'my_app.dart';
Future<void> main()async{
  WidgetsFlutterBinding.ensureInitialized();
  final rateStore = RateStore(
    ExchangeRateRepo(
      remote: ExchangeRateRemoteDs(),
      local: ExchangeRateLocalDs(),
    ),
  );

  await rateStore.refresh();
  MoneyFmt.usdToUzs = rateStore.usdToUzs;
  debugPrint("USD->UZS rate: ${rateStore.usdToUzs}  updatedAt: ${rateStore.updatedAt}");
  debugPrint("MoneyFmt.usdToUzs: ${MoneyFmt.usdToUzs}");


  await Hive.initFlutter();
  final box = await Hive.openBox("authBox");
  runApp( MyApp(box: box,));
}

