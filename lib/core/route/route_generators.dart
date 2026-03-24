import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:olam/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:olam/core/di/services_locator.dart';
import 'package:olam/core/route/route_names.dart';
import 'package:olam/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olam/features/auth/presentation/pages/login_page.dart';
import 'package:olam/features/auth/presentation/pages/splash_page.dart';
import 'package:olam/features/customer/presentation/pages/customers_page.dart';

class AppRoute {
  Route onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());

      case RouteNames.login:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            //  har safar yangi instance - login sahifasiga qaytganda eski state qolmaydi
            create: (_) => sl<AuthBloc>(),
            child: const LoginPage(),
          ),
        );

      case RouteNames.bottomNavBar:
        return MaterialPageRoute(builder: (_) => const BottomNavBarPage());
      case RouteNames.customerPage:
        return MaterialPageRoute(builder: (_) => const CustomersPage());

      default:
        return _errorRoute();
    }
  }

  Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Page not found')),
      ),
    );
  }
}