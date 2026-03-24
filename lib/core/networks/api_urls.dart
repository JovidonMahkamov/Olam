abstract class ApiUrls {
  static const String baseUrl = 'https://mobile.olampardalar.uz/api';

  /// Auth
  static const String login = '/auth/kirish';
  static const String refreshToken = '/auth/yangilash';

  /// Mahsulotlar
  static const String getMahsulotlar = '/mahsulotlar/';

  /// Mijozlar
  static const String getMijozlar = '/mijozlar/';
  static const String postMijoz = '/mijozlar/';

  /// Sotuvlar
  static const String getSotuvlar = '/sotuvlar/';
  static const String postSotuv = '/sotuvlar/';
  static const String deleteSotuv = '/sotuvlar/';
  static const String sotuvElementlar = '/sotuvlar/';
  static const String sotuvYakunlash = '/sotuvlar/';

  /// Kassa
  static const String getKassalar = '/kassa/';
  static const String kassaKirim = '/kassa/';
  static const String qaytarishlar = '/qaytarishlar/';
  static const String bugunStat = '/sotuvlar/bugun-stat';


  /// Customer
  static const String getCustomer = '/mijozlar/';
}