import 'package:flutter/material.dart';

class MoneyFmt {
  static double _usdToUzs = 12000;

  static double get usdToUzs => _usdToUzs;

  static set usdToUzs(double v) {
    _usdToUzs = v;
    debugPrint("🔥 MoneyFmt.usdToUzs SET => $_usdToUzs");
  }

  static double uzsToUsd(int uzs) => uzs / _usdToUzs;
  static int usdToUzsInt(double usd) => (usd * _usdToUzs).round();

  static String usd(double v) => '\$${v.toStringAsFixed(2)}';
  static String usdFromUzs(int uzs) {
    final usdValue = uzs / _usdToUzs;
    final cents = (usdValue * 100).round();
    return usd(cents / 100.0);
  }
}