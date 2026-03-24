class MijozEntity {
  final int id;
  final String fish;
  final String? telefon;
  final String? manzil;
  final double qarzdorlik;
  final bool faol;

  const MijozEntity({
    required this.id,
    required this.fish,
    this.telefon,
    this.manzil,
    required this.qarzdorlik,
    required this.faol,
  });
}

class MijozlarResponseEntity {
  final List<MijozEntity> mijozlar;
  final int jami;

  const MijozlarResponseEntity({
    required this.mijozlar,
    required this.jami,
  });
}