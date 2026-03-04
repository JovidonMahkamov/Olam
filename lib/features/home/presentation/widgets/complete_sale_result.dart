import 'package:flutter/foundation.dart';
import 'package:olam/features/home/presentation/widgets/pay_type.dart';
import 'sale_selected_item_model.dart';

/// CompleteSaleDialog yakunlanganda tashqariga qaytariladigan natija.
/// Widget emas — oddiy model.
@immutable
class CompleteSaleResult {
  /// Kassa kartochkasi uchun
  final String customerName;
  final String address;

  /// Sotilgan mahsulotlar (chek/istory uchun)
  final List<SaleSelectedItemModel> items;

  /// Jami savdo (UZS)
  final int totalUzs;

  /// Mijoz hozir to'lagan (UZS)
  final int paidUzs;

  /// Qarz (UZS) = totalUzs - paidUzs
  final int debtUzs;

  /// To'lov turi: Naqd/Terminal/Click
  final PayType payType;

  /// Ch (chegirma) yoqilganmi
  final bool discountEnabled;

  /// SMS yuborilsinmi (qarz bo'lsa majburiy)
  final bool smsEnabled;

  /// Izoh (qarz bo'lsa majburiy)
  final String note;

  /// Vaqt
  final DateTime createdAt;

  const CompleteSaleResult({
    required this.customerName,
    required this.address,
    required this.items,
    required this.totalUzs,
    required this.paidUzs,
    required this.debtUzs,
    required this.payType,
    required this.discountEnabled,
    required this.smsEnabled,
    required this.note,
    required this.createdAt,
  });

  bool get hasDebt => debtUzs > 0;
}

