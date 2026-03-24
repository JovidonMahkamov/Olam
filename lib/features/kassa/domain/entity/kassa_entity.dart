import 'package:olam/features/home/presentation/widgets/pay_type.dart';

class KassaEntity {
  final int id;
  final String turi;
  final double balansUsd;

  const KassaEntity({
    required this.id,
    required this.turi,
    required this.balansUsd,
  });

  PayType get payType {
    switch (turi.toLowerCase()) {
      case 'terminal': return PayType.terminal;
      case 'click':    return PayType.click;
      default:         return PayType.naqd;
    }
  }
}

// Bugungi sotuv statistikasi
class BugungiSotuvStat {
  final double naqdJami;
  final double terminalJami;
  final double clickJami;
  final double qarzJami;
  final int sotuvlarSoni;
  final List<BugungiSotuvEntity> sotuvlar;

  // Kirimlar (qarz to'lovlari)
  final double kirimNaqd;
  final double kirimTerminal;
  final double kirimClick;
  final double kirimJami;

  final List<BugungiQaytarishEntity> qaytarishlar;

  const BugungiSotuvStat({
    required this.naqdJami,
    required this.terminalJami,
    required this.clickJami,
    required this.qarzJami,
    required this.sotuvlarSoni,
    required this.sotuvlar,
    this.kirimNaqd = 0,
    this.kirimTerminal = 0,
    this.kirimClick = 0,
    this.kirimJami = 0,
    this.qaytarishlar = const [],
  });

  double get jamiUsd => naqdJami + terminalJami + clickJami;
}

class BugungiSotuvEntity {
  final int id;
  final int mijozId;
  final String? mijozFish;
  final double jamiUsd;
  final double tolovQilinganUsd;
  final double qarzUsd;
  final String tolovTuri;
  final String sana;

  const BugungiSotuvEntity({
    required this.id,
    required this.mijozId,
    this.mijozFish,
    required this.jamiUsd,
    required this.tolovQilinganUsd,
    required this.qarzUsd,
    required this.tolovTuri,
    required this.sana,
  });
}

// Bugungi qaytarish
class BugungiQaytarishEntity {
  final int id;
  final int mijozId;
  final String? mijozFish;
  final double jamiUsd;
  final String tolovTuri;
  final String sana;

  const BugungiQaytarishEntity({
    required this.id,
    required this.mijozId,
    this.mijozFish,
    required this.jamiUsd,
    required this.tolovTuri,
    required this.sana,
  });
}

// Qarzdor mijoz
class QarzdorMijozEntity {
  final int id;
  final String fish;
  final String? telefon;
  final double qarzdorlik;

  const QarzdorMijozEntity({
    required this.id,
    required this.fish,
    this.telefon,
    required this.qarzdorlik,
  });
}