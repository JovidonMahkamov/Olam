import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:olam/core/route/route_names.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  StreamSubscription<InternetConnectionStatus>? _internetSub;

  bool _hasNavigated = false;
  bool _snackShown = false;

  final InternetConnectionChecker _checker = InternetConnectionChecker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initialCheck();
      _listenNetworkChanges();
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _internetSub?.cancel();
    super.dispose();
  }

  Future<void> _initialCheck() async {
    final hasInternet = await _checker.hasConnection;
    if (!mounted) return;

    if (hasInternet) {
      await _navigateToNextPage();
    } else {
      _showNoInternetSnackBar();
    }
  }

  void _listenNetworkChanges() {
    _connectivitySub =
        Connectivity().onConnectivityChanged.listen((results) async {
          if (!mounted || _hasNavigated) return;

          final hasAnyNetwork =
              results.isNotEmpty && !results.contains(ConnectivityResult.none);

          if (!hasAnyNetwork) {
            _showNoInternetSnackBar();
            return;
          }

          final hasInternet = await _checker.hasConnection;
          if (!mounted || _hasNavigated) return;

          if (hasInternet) {
            await _navigateToNextPage();
          } else {
            _showNoInternetSnackBar();
          }
        });

    _internetSub = _checker.onStatusChange.listen((status) async {
      if (!mounted || _hasNavigated) return;

      if (status == InternetConnectionStatus.connected) {
        await _navigateToNextPage();
      } else {
        _showNoInternetSnackBar();
      }
    });
  }

  void _showNoInternetSnackBar() {
    if (!mounted || _snackShown) return;
    _snackShown = true;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Internet mavjud emas. Iltimos, tarmoqni yoqing!"),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      _snackShown = false;
    });
  }

  Future<void> _navigateToNextPage() async {
    if (_hasNavigated) return;
    _hasNavigated = true;

    await _connectivitySub?.cancel();
    await _internetSub?.cancel();

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final box = await Hive.openBox('authBox');
    final accessToken = box.get('accessToken');
    final refreshToken = box.get('refreshToken');

    final hasAccess =
        accessToken != null && accessToken.toString().trim().isNotEmpty;
    final hasRefresh =
        refreshToken != null && refreshToken.toString().trim().isNotEmpty;

    if (!mounted) return;

    if (hasAccess && hasRefresh) {
      // ✅ Token bor → asosiy sahifaga
      Navigator.pushReplacementNamed(context, RouteNames.bottomNavBar);
    } else {
      // ✅ Token yo'q → login sahifasiga (oldin bu qism yo'q edi!)
      Navigator.pushReplacementNamed(context, RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/splash/parda.png',
              width: 210,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/splash/parda2.png',
              width: 220,
              fit: BoxFit.contain,
            ),
          ),
          Center(
            child: SvgPicture.asset("assets/splash/logo.svg"),
          ),
        ],
      ),
    );
  }
}