import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olam/core/utils/money_fmt.dart';
import 'package:olam/features/home/presentation/widgets/pay_type.dart';

import 'complete_sale_result.dart';
import 'sale_selected_item_model.dart';

class CompleteSaleDialog extends StatefulWidget {
  final List<SaleSelectedItemModel> items;

  /// SaleDetailPage’dan keladi
  final double totalUsd;
  final double totalUzs;

  /// Kassa card uchun
  final String customerName;
  final String address;

  ///  Yakunlash bosilganda tashqariga natija chiqaramiz
  final ValueChanged<CompleteSaleResult> onFinish;

  const CompleteSaleDialog({
    super.key,
    required this.items,
    required this.totalUsd,
    required this.totalUzs,
    required this.customerName,
    required this.address,
    required this.onFinish,
  });

  static Future<void> show(
      BuildContext context, {
        required List<SaleSelectedItemModel> items,
        required double totalUsd,
        required double totalUzs,
        required String customerName,
        required String address,
        required ValueChanged<CompleteSaleResult> onFinish,
      }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        backgroundColor: Colors.transparent,
        child: CompleteSaleDialog(
          items: items,
          totalUsd: totalUsd,
          totalUzs: totalUzs,
          customerName: customerName,
          address: address,
          onFinish: onFinish,
        ),
      ),
    );
  }

  @override
  State<CompleteSaleDialog> createState() => _CompleteSaleDialogState();
}

class _CompleteSaleDialogState extends State<CompleteSaleDialog> {
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();

  String _paymentType = 'Naqd'; // Naqd/Terminal/Click
  String _currency = '\$'; // $ yoki UZS

  bool _ch = false;
  bool _sms = false;
  double get _enteredAmount {
    final raw = _amountCtrl.text.replaceAll(',', '.').trim();
    return double.tryParse(raw) ?? 0;
  }

  double get _totalCurrentCurrency => _currency == '\$' ? widget.totalUsd : widget.totalUzs;

  double get _qoldiq {
    final value = _totalCurrentCurrency - _enteredAmount;
    return value < 0 ? 0 : value;
  }

  double get _debt {
    final d = _totalCurrentCurrency - _enteredAmount;
    return d > 0 ? d : 0;
  }

  bool get _isOverPay => _enteredAmount > _totalCurrentCurrency;
  bool get _hasDebt => _enteredAmount > 0 && _enteredAmount < _totalCurrentCurrency;

  bool get _canFinish {
    if (_enteredAmount <= 0) return false;
    if (_isOverPay) return false;

    if (_hasDebt) {
      final hasNote = _noteCtrl.text.trim().isNotEmpty;
      return _sms && hasNote; //  qarz bo‘lsa shart
    }
    return true; //  to‘liq to‘langan bo‘lsa
  }

  PayType get _selectedPayType {
    switch (_paymentType) {
      case 'Terminal':
        return PayType.terminal;
      case 'Click':
        return PayType.click;
      case 'Naqd':
      default:
        return PayType.naqd;
    }
  }

  int _toUzsInt(double amount, String currency) {
    if (currency == '\$') return MoneyFmt.usdToUzsInt(amount);
    return amount.round();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  String _fmtNum(num n) {
    if (n % 1 == 0) return n.toInt().toString();
    return n.toStringAsFixed(2);
  }

  String _itemLabel(SaleSelectedItemModel item) {
    String qtyText;

    if (item.soldDona > 0) {
      qtyText = '${item.soldDona} dona';
    } else if (item.soldMetr > 0) {
      qtyText = '${item.soldMetr} metr';
    } else if (item.soldPachka > 0) {
      qtyText = '${item.soldPachka} pachka';
    } else {
      qtyText = '1 dona';
    }

    final sku = item.skuTag.trim().isNotEmpty ? ' ${item.skuTag}' : '';
    return '$qtyText - ${item.productName}$sku';
  }

  Widget _lineRow(String title, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallToggle({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool highlight = false,
  }) {
    const activeColor = Color(0xFFF1C644);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 4),
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => onChanged(!value),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: value ? activeColor : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: value
                    ? activeColor
                    : (highlight ? activeColor.withOpacity(0.7) : Colors.black12),
              ),
            ),
            child: value ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
          ),
        ),
      ],
    );
  }

  void _finish() {
    final totalUzsInt = widget.totalUzs.round();
    final paidUzsInt = _toUzsInt(_enteredAmount, _currency);
    final debtUzsInt = (totalUzsInt - paidUzsInt) > 0 ? (totalUzsInt - paidUzsInt) : 0;

    final res = CompleteSaleResult(
      customerName: widget.customerName,
      address: widget.address,
      items: List<SaleSelectedItemModel>.from(widget.items),
      totalUzs: totalUzsInt,
      paidUzs: paidUzsInt,
      debtUzs: debtUzsInt,
      payType: _selectedPayType,
      discountEnabled: _ch,
      smsEnabled: _sms,
      note: _noteCtrl.text.trim(),
      createdAt: DateTime.now(),
    );

    // ✅ 1) Avval dialogni yopamiz
    Navigator.of(context).pop();

    // ✅ 2) Keyin callbackni keyingi microtaskda chaqiramiz
    Future.microtask(() {
      widget.onFinish(res);
    });
  }

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFF1C644);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Savdoni yakunlash",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, color: Colors.red, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Main card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: yellow.withOpacity(0.75)),
                ),
                child: Column(
                  children: [
                    Text(
                      "Jami: ${_fmtNum(_totalCurrentCurrency)} $_currency",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),

                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 140),
                      child: SingleChildScrollView(
                        child: Column(
                          children: widget.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _itemLabel(item),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    _lineRow(
                      "To’lov:",
                      _enteredAmount > 0 ? "${_fmtNum(_enteredAmount)} $_currency" : "-",
                    ),
                    _lineRow(
                      "Chegirma:",
                      (_ch && _enteredAmount > 0) ? "${_fmtNum(_enteredAmount)} $_currency" : "-",
                    ),
                    _lineRow(
                      "Qoldiq:",
                      "${_fmtNum(_qoldiq)} $_currency",
                      bold: true,
                    ),

                    const SizedBox(height: 6),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "To’lov turi:",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // left side
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 36,
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.black12),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _paymentType,
                                          isExpanded: true,
                                          icon: const Icon(Icons.keyboard_arrow_down),
                                          style: const TextStyle(color: Colors.black87, fontSize: 13),
                                          items: const [
                                            DropdownMenuItem(value: 'Naqd', child: Text('Naqd')),
                                            DropdownMenuItem(value: 'Terminal', child: Text('Terminal')),
                                            DropdownMenuItem(value: 'Click', child: Text('Click')),
                                          ],
                                          onChanged: (v) {
                                            if (v == null) return;
                                            setState(() => _paymentType = v);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 72,
                                    child: Container(
                                      height: 36,
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.black12),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _currency,
                                          isExpanded: true,
                                          icon: const Icon(Icons.keyboard_arrow_down),
                                          style: const TextStyle(color: Colors.black87, fontSize: 13),
                                          items: const [
                                            DropdownMenuItem(value: '\$', child: Text('\$')),
                                            DropdownMenuItem(value: 'UZS', child: Text('UZS')),
                                          ],
                                          onChanged: (v) {
                                            if (v == null) return;
                                            setState(() => _currency = v);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              SizedBox(
                                height: 36,
                                child: TextField(
                                  controller: _amountCtrl,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
                                  ],
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    hintText: "Summa kiriting",
                                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    filled: true,
                                    fillColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Colors.black12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: yellow),
                                    ),
                                  ),
                                ),
                              ),

                              if (_isOverPay)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Xatolik: kiritilgan summa jami summadan katta bo‘lishi mumkin emas!",
                                      style: TextStyle(fontSize: 12, color: Colors.red.shade600),
                                    ),
                                  ),
                                ),

                              if (_hasDebt)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Yetmagan (qarz): ${_fmtNum(_debt)} $_currency",
                                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 10),

                              SizedBox(
                                height: 36,
                                child: TextField(
                                  controller: _noteCtrl,
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    hintText: "Izoh qoldiring...",
                                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    filled: true,
                                    fillColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Colors.black12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: yellow),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // toggles
                        Column(
                          children: [
                            _smallToggle(
                              label: 'Ch',
                              value: _ch,
                              onChanged: (v) => setState(() => _ch = v),
                            ),
                            const SizedBox(height: 8),
                            _smallToggle(
                              label: 'SMS',
                              value: _sms,
                              highlight: _hasDebt && !_sms,
                              onChanged: (v) => setState(() => _sms = v),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yellow,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  ),
                  onPressed: _canFinish ? _finish : null,
                  child: const Text(
                    "Yakunlash",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}