abstract class HomeEvent {
  const HomeEvent();
}

// Mahsulotlar
class GetMahsulotlarE extends HomeEvent {
  final String? q;
  final int sahifa;
  const GetMahsulotlarE({this.q, this.sahifa = 1});
}

// Mijozlar
class GetMijozlarE extends HomeEvent {
  final String? q;
  const GetMijozlarE({this.q});
}

class PostMijozE extends HomeEvent {
  final String fish;
  final String? telefon;
  final String? manzil;
  const PostMijozE({required this.fish, this.telefon, this.manzil});
}

// Sotuvlar
class GetSotuvlarE extends HomeEvent {
  const GetSotuvlarE();
}

class PostSotuvE extends HomeEvent {
  final String nomi;
  final int mijozId;
  const PostSotuvE({required this.nomi, required this.mijozId});
}

class DeleteSotuvE extends HomeEvent {
  final int id;
  const DeleteSotuvE({required this.id});
}

class PostSotuvElementE extends HomeEvent {
  final int sotuvId;
  final int mahsulotId;
  final double dona;
  final double pachtka;
  final double metr;
  final double narxUsd;
  const PostSotuvElementE({
    required this.sotuvId,
    required this.mahsulotId,
    this.dona = 0,
    this.pachtka = 0,
    this.metr = 0,
    required this.narxUsd,
  });
}

class YakunlashSotuvE extends HomeEvent {
  final int sotuvId;
  final String tolovTuri;
  final double tolovQilinganUsd;
  final bool chegirma;
  final bool sms;
  final String? izoh;
  const YakunlashSotuvE({
    required this.sotuvId,
    required this.tolovTuri,
    required this.tolovQilinganUsd,
    this.chegirma = false,
    this.sms = false,
    this.izoh,
  });
}