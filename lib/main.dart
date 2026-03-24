import 'package:flutter/material.dart';
import 'package:olam/bloc_provider.dart';
import 'package:olam/core/currency/exchange_rate_local_ds.dart';
import 'package:olam/core/currency/exchange_rate_remote_ds.dart';
import 'package:olam/core/currency/exchange_rate_repo.dart';
import 'package:olam/core/currency/rate_store.dart';
import 'package:olam/core/utils/money_fmt.dart';
import 'core/di/services_locator.dart';
import 'my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final rateStore = RateStore(
    ExchangeRateRepo(
      remote: ExchangeRateRemoteDs(),
      local: ExchangeRateLocalDs(),
    ),
  );

  await rateStore.refresh();
  MoneyFmt.usdToUzs = rateStore.usdToUzs;

  await setup();

  runApp(const MyBlocProvider(child: MyApp()));
}