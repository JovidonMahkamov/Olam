import 'package:flutter/material.dart';
import 'package:olam/features/home/presentation/widgets/return_selected_item_model.dart';

class ReturnablePurchaseVM {
  // Sizning history itemingizdan keladigan data (prefill uchun)
  final String purchaseId;
  final String productId;
  final String name;
  final String code;
  final String imageUrl;

  final int boughtPachka;
  final int boughtDona;
  final int boughtMetr;

  final double sellPricePachkaUsd;
  final double sellPriceDonaUsd;
  final double sellPriceMetrUsd;

  const ReturnablePurchaseVM({
    required this.purchaseId,
    required this.productId,
    required this.name,
    required this.code,
    required this.imageUrl,
    required this.boughtPachka,
    required this.boughtDona,
    required this.boughtMetr,
    required this.sellPricePachkaUsd,
    required this.sellPriceDonaUsd,
    required this.sellPriceMetrUsd,
  });
}

class ReturnPriceAdjustDialog extends StatefulWidget {
  final ReturnablePurchaseVM purchase;

  const ReturnPriceAdjustDialog({
    super.key,
    required this.purchase,
  });

  static Future<ReturnSelectedItemModel?> show(
      BuildContext context, {
        required ReturnablePurchaseVM purchase,
      }) {
    return showDialog<ReturnSelectedItemModel>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (_) => ReturnPriceAdjustDialog(purchase: purchase),
    );
  }

  @override
  State<ReturnPriceAdjustDialog> createState() => _ReturnPriceAdjustDialogState();
}

class _ReturnPriceAdjustDialogState extends State<ReturnPriceAdjustDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _pachkaCtrl;
  late final TextEditingController _donaCtrl;
  late final TextEditingController _metrCtrl;

  // oldingi (sotilgan) narxlar (readonly)
  late final TextEditingController _oldPricePachkaCtrl;
  late final TextEditingController _oldPriceDonaCtrl;
  late final TextEditingController _oldPriceMetrCtrl;

  // qaytarish narxlari (editable) - default sotilgan narx bilan keladi
  late final TextEditingController _returnPricePachkaCtrl;
  late final TextEditingController _returnPriceDonaCtrl;
  late final TextEditingController _returnPriceMetrCtrl;

  late final TextEditingController _summaCtrl;

  @override
  void initState() {
    super.initState();

    // Qaytarish miqdorlari default 0
    _pachkaCtrl = TextEditingController(text: "0");
    _donaCtrl = TextEditingController(text: "0");
    _metrCtrl = TextEditingController(text: "0");

    // Sotilgandagi narxlar
    _oldPricePachkaCtrl = TextEditingController(text: widget.purchase.sellPricePachkaUsd.toStringAsFixed(0));
    _oldPriceDonaCtrl = TextEditingController(text: widget.purchase.sellPriceDonaUsd.toStringAsFixed(0));
    _oldPriceMetrCtrl = TextEditingController(text: widget.purchase.sellPriceMetrUsd.toStringAsFixed(0));

    // Qaytarish narxlari default sotilgandagi narx bilan
    _returnPricePachkaCtrl = TextEditingController(text: widget.purchase.sellPricePachkaUsd.toStringAsFixed(0));
    _returnPriceDonaCtrl = TextEditingController(text: widget.purchase.sellPriceDonaUsd.toStringAsFixed(0));
    _returnPriceMetrCtrl = TextEditingController(text: widget.purchase.sellPriceMetrUsd.toStringAsFixed(0));

    _summaCtrl = TextEditingController(text: "0");

    _pachkaCtrl.addListener(_recalc);
    _donaCtrl.addListener(_recalc);
    _metrCtrl.addListener(_recalc);
    _returnPricePachkaCtrl.addListener(_recalc);
    _returnPriceDonaCtrl.addListener(_recalc);
    _returnPriceMetrCtrl.addListener(_recalc);
  }

  @override
  void dispose() {
    _pachkaCtrl.dispose();
    _donaCtrl.dispose();
    _metrCtrl.dispose();

    _oldPricePachkaCtrl.dispose();
    _oldPriceDonaCtrl.dispose();
    _oldPriceMetrCtrl.dispose();

    _returnPricePachkaCtrl.dispose();
    _returnPriceDonaCtrl.dispose();
    _returnPriceMetrCtrl.dispose();

    _summaCtrl.dispose();
    super.dispose();
  }

  int _toInt(String v) => int.tryParse(v.trim()) ?? 0;
  double _toDouble(String v) => double.tryParse(v.trim().replaceAll(',', '.')) ?? 0;

  bool get _hasPachka => _toInt(_pachkaCtrl.text) > 0;
  bool get _hasDona => _toInt(_donaCtrl.text) > 0;
  bool get _hasMetr => _toInt(_metrCtrl.text) > 0;

  int get _unitCount => (_hasPachka ? 1 : 0) + (_hasDona ? 1 : 0) + (_hasMetr ? 1 : 0);

  void _recalc() {
    final rp = _toInt(_pachkaCtrl.text);
    final rd = _toInt(_donaCtrl.text);
    final rm = _toInt(_metrCtrl.text);

    final pp = _toDouble(_returnPricePachkaCtrl.text);
    final pd = _toDouble(_returnPriceDonaCtrl.text);
    final pm = _toDouble(_returnPriceMetrCtrl.text);

    final total = (rp * pp) + (rd * pd) + (rm * pm);
    _summaCtrl.text = total.toStringAsFixed(0);
    setState(() {});
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final rp = _toInt(_pachkaCtrl.text);
    final rd = _toInt(_donaCtrl.text);
    final rm = _toInt(_metrCtrl.text);

    if (rp == 0 && rd == 0 && rm == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kamida bitta miqdor kiriting (pachka/dona/metr)")),
      );
      return;
    }

    if (_unitCount != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Faqat bitta tur tanlang: pachka yoki dona yoki metr")),
      );
      return;
    }

    // ❗ Qaytarish miqdori sotib olingandan oshmasin
    if (rp > widget.purchase.boughtPachka) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pachka ko‘pi bilan ${widget.purchase.boughtPachka} ta bo‘lishi mumkin")),
      );
      return;
    }
    if (rd > widget.purchase.boughtDona) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Dona ko‘pi bilan ${widget.purchase.boughtDona} ta bo‘lishi mumkin")),
      );
      return;
    }
    if (rm > widget.purchase.boughtMetr) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Metr ko‘pi bilan ${widget.purchase.boughtMetr} bo‘lishi mumkin")),
      );
      return;
    }

    final pp = _toDouble(_returnPricePachkaCtrl.text);
    final pd = _toDouble(_returnPriceDonaCtrl.text);
    final pm = _toDouble(_returnPriceMetrCtrl.text);

    // faqat tanlangan unit narxi > 0 bo‘lsin, qolganlari 0 bo‘lsin
    if (_hasPachka && (pp <= 0 || pd != 0 || pm != 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pachka tanlansa: pachka narx > 0, dona/metr narx = 0 bo‘lsin")),
      );
      return;
    }
    if (_hasDona && (pd <= 0 || pp != 0 || pm != 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dona tanlansa: dona narx > 0, pachka/metr narx = 0 bo‘lsin")),
      );
      return;
    }
    if (_hasMetr && (pm <= 0 || pp != 0 || pd != 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Metr tanlansa: metr narx > 0, dona/pachka narx = 0 bo‘lsin")),
      );
      return;
    }

    final total = (rp * pp) + (rd * pd) + (rm * pm);

    Navigator.pop(
      context,
      ReturnSelectedItemModel(
        purchaseId: widget.purchase.purchaseId,
        productId: widget.purchase.productId,
        productName: widget.purchase.name,
        productCode: widget.purchase.code,
        imageUrl: widget.purchase.imageUrl,
        returnPachka: rp,
        returnDona: rd,
        returnMetr: rm,
        pricePachkaUsd: pp,
        priceDonaUsd: pd,
        priceMetrUsd: pm,
        returnTotalUsd: total,
      ),
    );
  }

  String? _qtyValidator(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return null;
    final n = int.tryParse(t);
    if (n == null) return "Faqat son kiriting";
    if (n < 0) return "Manfiy son bo‘lmaydi";
    return null;
  }

  String? _priceValidator(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return "Narx kiriting";
    final d = double.tryParse(t.replaceAll(',', '.'));
    if (d == null) return "To‘g‘ri narx kiriting";
    if (d < 0) return "Manfiy narx bo‘lmaydi";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.purchase;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "${p.name}  ${p.code}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF4A4A4A)),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.close, color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // old info
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Sotib olingan: pachka ${p.boughtPachka}, dona ${p.boughtDona}, metr ${p.boughtMetr}",
                    style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),

                _Label("Qaytariladigan miqdor (Pachka)"),
                const SizedBox(height: 6),
                _Field(controller: _pachkaCtrl, hint: "0", keyboardType: TextInputType.number, validator: _qtyValidator),
                const SizedBox(height: 10),

                _Label("Qaytariladigan miqdor (Dona)"),
                const SizedBox(height: 6),
                _Field(controller: _donaCtrl, hint: "0", keyboardType: TextInputType.number, validator: _qtyValidator),
                const SizedBox(height: 10),

                _Label("Qaytariladigan miqdor (Metr)"),
                const SizedBox(height: 6),
                _Field(controller: _metrCtrl, hint: "0", keyboardType: TextInputType.number, validator: _qtyValidator),

                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),

                _Label("Sotilgandagi narxlar (readonly)"),
                const SizedBox(height: 8),
                _Field(controller: _oldPriceMetrCtrl, hint: "Metr (old)", readOnly: true),
                const SizedBox(height: 8),
                _Field(controller: _oldPriceDonaCtrl, hint: "Dona (old)", readOnly: true),
                const SizedBox(height: 8),
                _Field(controller: _oldPricePachkaCtrl, hint: "Pachka (old)", readOnly: true),

                const SizedBox(height: 14),
                _Label("Qaytarish narxlari (o‘zgartirish mumkin)"),
                const SizedBox(height: 8),
                _Field(
                  controller: _returnPriceMetrCtrl,
                  hint: "Metr narxi",
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: _priceValidator,
                ),
                const SizedBox(height: 8),
                _Field(
                  controller: _returnPriceDonaCtrl,
                  hint: "Dona narxi",
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: _priceValidator,
                ),
                const SizedBox(height: 8),
                _Field(
                  controller: _returnPricePachkaCtrl,
                  hint: "Pachka narxi",
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: _priceValidator,
                ),

                const SizedBox(height: 10),
                _Label("Qaytarish summasi"),
                const SizedBox(height: 6),
                _Field(controller: _summaCtrl, hint: "0", readOnly: true),

                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFFF4C747),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text("Saqlash", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Color(0xFF666666), fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool readOnly;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.hint,
    this.readOnly = false,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: readOnly ? const Color(0xFFF0F0F0) : const Color(0xFFF9F9F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0A52C)),
        ),
      ),
    );
  }
}