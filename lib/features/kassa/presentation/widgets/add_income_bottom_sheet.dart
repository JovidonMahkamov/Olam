import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olam/core/utils/money_fmt.dart';
import 'package:olam/features/home/presentation/widgets/pay_type.dart';
import 'package:olam/features/kassa/presentation/widgets/kassa_card_shell.dart';
import 'package:olam/features/kassa/presentation/widgets/kassa_store.dart';

class AddIncomeBottomSheet extends StatefulWidget {
  final KassaStore store;
  final PayType payType;

  const AddIncomeBottomSheet({
    super.key,
    required this.store,
    required this.payType,
  });

  static Future<void> show(
      BuildContext context, {
        required KassaStore store,
        required PayType payType,
      }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddIncomeBottomSheet(store: store, payType: payType),
    );
  }

  @override
  State<AddIncomeBottomSheet> createState() => _AddIncomeBottomSheetState();
}

class _AddIncomeBottomSheetState extends State<AddIncomeBottomSheet> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  bool _sendSms = true; // default yoq bo‘lsin
  bool _conversion = false; // hozircha UI uchun
  bool _profit = false;     // hozircha UI uchun

  _DebtorView? _selected;

  double get _enteredUsd {
    final t = _amountCtrl.text.trim().replaceAll(',', '.');
    return double.tryParse(t) ?? 0.0;
  }
  int get _enteredUzs => MoneyFmt.usdToUzsInt(_enteredUsd);

  int get _remainingDebtUzs {
    if (_selected == null) return 0;
    final left = _selected!.debtUzs - _enteredUzs;
    return left > 0 ? left : 0;
  }

  List<_DebtorView> get _debtors {
    //  faqat qarzdorlar
    final list = widget.store.entries.where((e) => e.hasDebt).toList();
    // xohlasang createdAt bo‘yicha ham sort qilamiz:
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return list
        .map((e) => _DebtorView(
      entryId: e.id,
      customerName: e.customerName,
      productName: e.productName,
      address: e.address,
      imageAsset: e.imageAsset,
      totalUzs: e.totalUzs,
      paidUzs: e.paidUzs,
      debtUzs: e.debtUzs,
    ))
        .toList();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _pickDebtor() async {
    final selected = await showModalBottomSheet<_DebtorView>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DebtorPickerSheet(items: _debtors, initial: _selected),
    );

    if (!mounted) return;
    if (selected != null) {
      setState(() {
        _selected = selected;
        _amountCtrl.clear();
        _noteCtrl.clear();
      });
    }
  }

  void _submit() {
    final debtor = _selected;
    if (debtor == null) {
      _toast("Mijozni tanlang");
      return;
    }

    if (_enteredUsd <= 0) {
      _toast("Summani kiriting (\$)");
      return;
    }

    final payUzs = _enteredUzs;

    const int eps = 5;

    if (payUzs > debtor.debtUzs + eps) {
      _toast("Kiritilgan summa qarzdan katta bo‘lmasin");
      return;
    }

// agar 1-5 so‘m farq bo‘lsa, qarzni to‘liq yopish uchun payUzs ni qarzga tenglab qo‘yamiz
    final fixedPayUzs = (payUzs > debtor.debtUzs) ? debtor.debtUzs : payUzs;

    final remainingUzs = debtor.debtUzs - payUzs;

    final note = (_noteCtrl.text.trim().isEmpty)
        ? (remainingUzs == 0
        ? "To‘liq to‘ladi"
        : "Qoldiq qarz: ${MoneyFmt.usdFromUzs(remainingUzs)}")
        : _noteCtrl.text.trim();

    widget.store.applyDebtPayment(
      entryId: debtor.entryId,
      payAmount: fixedPayUzs,
      payType: widget.payType,
      note: note,
      sendSms: _sendSms,
    );

    Navigator.pop(context);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.only(top: 60),
        padding: EdgeInsets.fromLTRB(14, 14, 14, 14 + bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(
              title: "Yangi kirim qo‘shish",
              onClose: () => Navigator.pop(context),
            ),

            const SizedBox(height: 12),

            //  click / naqd / terminal title ko‘rsatish
            Align(
              alignment: Alignment.center,
              child: Text(
                widget.payType.label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),

            const SizedBox(height: 12),

            _DebtorField(
              hint: "Mijozni tanlang",
              value: _selected?.customerName,
              onTap: _pickDebtor,
            ),

            const SizedBox(height: 10),

            if (_selected != null) ...[
              _DebtorPreviewCard(item: _selected!),
              const SizedBox(height: 10),
            ],

            _AmountRow(
              controller: _amountCtrl,
              onChanged: (_) => setState(() {}),
            ),

            if (_selected != null) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
    _remainingDebtUzs == 0
    ? "Qarz yopildi ✅"
        : "Yana qoladi: ${MoneyFmt.usdFromUzs(_remainingDebtUzs)}",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _remainingDebtUzs == 0 ? Colors.green : Colors.redAccent,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 10),

            _ToggleRow(
              conversion: _conversion,
              profit: _profit,
              sms: _sendSms,
              onConversion: (v) => setState(() => _conversion = v),
              onProfit: (v) => setState(() => _profit = v),
              onSms: (v) => setState(() => _sendSms = v),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _noteCtrl,
              decoration: InputDecoration(
                hintText: "Izoh qoldiring...",
                filled: true,
                fillColor: const Color(0xFFF3F3F3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              minLines: 1,
              maxLines: 2,
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE7C66A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                ),
                child: const Text(
                  "Qo‘shish",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(' ');
    }
    return "$buf so‘m";
  }
}

// =====================
//   Small UI widgets
// =====================

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  const _Header({required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 40),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close, color: Colors.redAccent),
        ),
      ],
    );
  }
}

class _DebtorField extends StatelessWidget {
  final String hint;
  final String? value;
  final VoidCallback onTap;

  const _DebtorField({
    required this.hint,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                (value == null || value!.isEmpty) ? hint : value!,
                style: TextStyle(
                  color: (value == null || value!.isEmpty) ? Colors.grey : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _AmountRow({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              hintText: "Summa kiriting",
              filled: true,
              fillColor: const Color(0xFFF3F3F3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              "\$",
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final bool conversion;
  final bool profit;
  final bool sms;
  final ValueChanged<bool> onConversion;
  final ValueChanged<bool> onProfit;
  final ValueChanged<bool> onSms;

  const _ToggleRow({
    required this.conversion,
    required this.profit,
    required this.sms,
    required this.onConversion,
    required this.onProfit,
    required this.onSms,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CheckChip(label: "Konvertatsiya", value: conversion, onChanged: onConversion),
        const SizedBox(width: 10),
        _CheckChip(label: "Foyda", value: profit, onChanged: onProfit),
        const SizedBox(width: 10),
        _CheckChip(label: "SMS", value: sms, onChanged: onSms, highlight: true),
      ],
    );
  }
}

class _CheckChip extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool highlight;

  const _CheckChip({
    required this.label,
    required this.value,
    required this.onChanged,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = highlight ? const Color(0xFFE7C66A) : Colors.grey.shade300;

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: value ? activeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: value ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _DebtorPickerSheet extends StatelessWidget {
  final List<_DebtorView> items;
  final _DebtorView? initial;

  const _DebtorPickerSheet({
    required this.items,
    required this.initial,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.only(top: 80),
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Qarzdor mijozlar",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Text("Hozircha qarzdor mijoz yo‘q"),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final it = items[i];
                    return InkWell(
                      onTap: () => Navigator.pop(context, it),
                      child: _DebtorPreviewCard(item: it, selectable: true),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DebtorPreviewCard extends StatelessWidget {
  final _DebtorView item;
  final bool selectable;

  const _DebtorPreviewCard({
    required this.item,
    this.selectable = false,
  });

  @override
  Widget build(BuildContext context) {
    return KassaCardShell(
      borderColor: Colors.redAccent,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Thumb(imageAsset: item.imageAsset),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  item.productName,
                  style: const TextStyle(color: Color(0xFF6A6A6A), fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(item.address, style: const TextStyle(color: Color(0xFF8A8A8A))),
                const SizedBox(height: 10),

                _Line("Jami", MoneyFmt.usdFromUzs(item.totalUzs)),
                _Line("To‘lagan", MoneyFmt.usdFromUzs(item.paidUzs)),
                _Line("Qolgan", MoneyFmt.usdFromUzs(item.debtUzs)),

                if (selectable)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text("Tanlash uchun bosing", style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String l;
  final String v;
  const _Line(this.l, this.v);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text("$l: ", style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6F6F6F))),
          Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6F6F6F)))),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String? imageAsset;
  const _Thumb({required this.imageAsset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFE0E0E0),
        image: imageAsset == null
            ? null
            : DecorationImage(image: AssetImage(imageAsset!), fit: BoxFit.cover),
      ),
      child: imageAsset == null ? const Icon(Icons.image, color: Colors.white70, size: 22) : null,
    );
  }
}

class _DebtorView {
  final String entryId;
  final String customerName;
  final String productName;
  final String address;
  final String? imageAsset;
  final int totalUzs;
  final int paidUzs;
  final int debtUzs;

  const _DebtorView({
    required this.customerName,
    required this.productName,
    required this.address,
    required this.imageAsset,
    required this.totalUzs,
    required this.paidUzs,
    required this.debtUzs,
    required this.entryId
  });
}