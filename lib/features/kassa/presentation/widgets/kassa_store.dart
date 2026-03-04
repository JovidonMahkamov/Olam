import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:olam/features/home/presentation/widgets/pay_type.dart';
import 'package:olam/features/kassa/presentation/widgets/kassa_entry_model.dart';

class KassaStore extends ChangeNotifier {
  final List<KassaEntryModel> _entries = [];

  //  tashqariga faqat o‘qish uchun
  UnmodifiableListView<KassaEntryModel> get entries => UnmodifiableListView(_entries);

  void addEntry(KassaEntryModel entry) {
    _entries.add(entry);
    notifyListeners();
  }

  void applyDebtPayment({
    required String entryId,
    required int payAmount,
    required PayType payType,
    required String note,
    required bool sendSms,
  }) {
    final idx = _entries.indexWhere((e) => e.id == entryId);
    if (idx == -1) return;

    final old = _entries[idx];

    // --- 1) hisoblash
    int newPaid = old.paidUzs + payAmount;
    int newDebt = old.totalUzs - newPaid;

    // --- 2) round xatoliklari uchun 1-5 so‘m tolerans
    const int eps = 5;

    if (newDebt <= eps) {
      // qarz deyarli 0: to‘liq yopamiz
      newPaid = old.totalUzs;
      newDebt = 0;
    } else if (newDebt < 0) {
      // himoya (umuman manfiy bo‘lib ketmasin)
      newPaid = old.totalUzs;
      newDebt = 0;
    }

    _entries[idx] = KassaEntryModel(
      id: old.id,
      customerName: old.customerName,
      productName: old.productName,
      address: old.address,
      imageAsset: old.imageAsset,
      totalUzs: old.totalUzs,
      paidUzs: newPaid,
      debtUzs: newDebt,
      payType: payType,
      createdAt: DateTime.now(),
      note: note,
      sendSms: sendSms,
    );

    notifyListeners();
  }
}