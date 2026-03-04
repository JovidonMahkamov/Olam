import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/adapters.dart';

import 'core/navigation/app_navigation.dart';
import 'core/route/route_generators.dart';
import 'core/route/route_names.dart';

class MyApp extends StatefulWidget {
  Box box;
   MyApp({super.key,required this.box});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize:  Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: appNavigatorKey,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          initialRoute: RouteNames.splash,
          onGenerateRoute: AppRoute().onGenerateRoute,
        );
      },
    );
  }
}