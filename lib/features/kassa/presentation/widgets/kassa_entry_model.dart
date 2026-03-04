import 'package:flutter/foundation.dart';
import 'package:olam/features/home/presentation/widgets/pay_type.dart';

@immutable
class KassaEntryModel {
  final String customerName;
  final String productName;
  final String address;
  final String? imageAsset;
  final String? note;
  final bool sendSms;
  final String id;

  /// Jami kelishilgan summa (USD yoki UZS sizda qanday bo‘lsa).
  /// Hozir siz Sale’da USD ishlatyapsiz, Kassa UI esa sum ko‘rsatadi.
  /// Shuning uchun UZS saqlash qulayroq.
  final int totalUzs;

  /// Mijoz shu payt to‘lagan (UZS)
  final int paidUzs;

  /// Qarz (UZS) = total - paid
  final int debtUzs;

  final PayType payType;

  /// vaqt (keyin sort uchun)
  final DateTime createdAt;

  const KassaEntryModel( {
    required this.customerName,
    required this.productName,
    required this.address,
    required this.imageAsset,
    required this.totalUzs,
    required this.paidUzs,
    required this.debtUzs,
    required this.payType,
    required this.createdAt,
    required this.id,
    this.note,
    this.sendSms = false,
  });

  bool get hasDebt => debtUzs > 0;
}