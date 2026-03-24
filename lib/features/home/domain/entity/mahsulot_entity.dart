class MahsulotEntity {
  final int id;
  final String nomi;
  final String kodi;
  final double? narxDona;      // narx_dona
  final double? narxPochka;    // narx_pochka
  final double? narxMetr;      // narx_metr
  final double narxUsd;        // narx_usd (umumiy narx)
  final String? rasmUrl;
  final bool faol;
  final double metr;           // ombordagi metr miqdori
  final double pochka;         // ombordagi pochka miqdori
  final double miqdor;         // ombordagi dona miqdori
  final double kelganNarx;     // kelgan narx (tannarx)
  final double jamiNarx;       // jami narx
  final String? qrKod;

  const MahsulotEntity({
    required this.id,
    required this.nomi,
    required this.kodi,
    this.narxDona,
    this.narxPochka,
    this.narxMetr,
    required this.narxUsd,
    this.rasmUrl,
    required this.faol,
    required this.metr,
    required this.pochka,
    required this.miqdor,
    required this.kelganNarx,
    required this.jamiNarx,
    this.qrKod,
  });
}

class MahsulotlarResponseEntity {
  final List<MahsulotEntity> mahsulotlar;
  final int jami;

  const MahsulotlarResponseEntity({
    required this.mahsulotlar,
    required this.jami,
  });
}