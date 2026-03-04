import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:olam/core/route/route_names.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    // Navigate to RegisterPage after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed(RouteNames.login);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // light gray
      body: Stack(
        children: [
          // Top-left golden shape
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/splash/parda.png',
              width: 210,
              fit: BoxFit.contain,
            ),
          ),

          // Bottom-right golden shape
          Positioned(
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/splash/parda2.png',
              width: 220,
              fit: BoxFit.contain,
            ),
          ),

          // Center logo + text
           Center(
            child: SvgPicture.asset("assets/splash/logo.svg"),
          ),
        ],
      ),
    );
  }
}



