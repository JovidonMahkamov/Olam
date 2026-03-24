class SotuvEntity {
  final int id;
  final String nomi;
  final int mijozId;
  final int sotuvchiId;
  final double jamiUsd;
  final double tolovQilinganUsd;
  final double qarzUsd;
  final String tolovTuri;
  final String holat;
  final bool chegirma;
  final bool sms;
  final String? izoh;
  final String sana;

  const SotuvEntity({
    required this.id,
    required this.nomi,
    required this.mijozId,
    required this.sotuvchiId,
    required this.jamiUsd,
    required this.tolovQilinganUsd,
    required this.qarzUsd,
    required this.tolovTuri,
    required this.holat,
    required this.chegirma,
    required this.sms,
    this.izoh,
    required this.sana,
  });
}

class SotuvElementEntity {
  final int id;
  final int sotuvId;
  final int mahsulotId;
  final double dona;
  final double pachtka;
  final double metr;
  final double narxUsd;
  final double jamiUsd;

  const SotuvElementEntity({
    required this.id,
    required this.sotuvId,
    required this.mahsulotId,
    required this.dona,
    required this.pachtka,
    required this.metr,
    required this.narxUsd,
    required this.jamiUsd,
  });
}