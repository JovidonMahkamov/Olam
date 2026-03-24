import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'return_selected_item_model.dart';
import 'customer_purchase_model.dart';

class ReturnPriceAdjustDialog extends StatefulWidget {
  final CustomerPurchaseModel purchase;

  const ReturnPriceAdjustDialog({super.key, required this.purchase});

  static Future<ReturnSelectedItemModel?> show(
      BuildContext context, {
        required CustomerPurchaseModel purchase,
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
  late final TextEditingController _pachkaCtrl;
  late final TextEditingController _metrCtrl;
  late final TextEditingController _narxMetrCtrl;
  late final TextEditingController _narxPachkaCtrl;
  late final TextEditingController _summaCtrl;

  @override
  void initState() {
    super.initState();
    final p = widget.purchase;
    _pachkaCtrl    = TextEditingController(text: '0');
    _metrCtrl      = TextEditingController(text: '0');
    _narxMetrCtrl  = TextEditingController(text: p.narxMetrUsd > 0 ? p.narxMetrUsd.toStringAsFixed(2) : '0');
    _narxPachkaCtrl= TextEditingController(text: p.narxPachkaUsd > 0 ? p.narxPachkaUsd.toStringAsFixed(2) : '0');
    _summaCtrl     = TextEditingController(text: '0');

    _pachkaCtrl.addListener(_recalc);
    _metrCtrl.addListener(_recalc);
    _narxMetrCtrl.addListener(_recalc);
    _narxPachkaCtrl.addListener(_recalc);
  }

  @override
  void dispose() {
    _pachkaCtrl.dispose();
    _metrCtrl.dispose();
    _narxMetrCtrl.dispose();
    _narxPachkaCtrl.dispose();
    _summaCtrl.dispose();
    super.dispose();
  }

  double _toDouble(String v) => double.tryParse(v.trim().replaceAll(',', '.')) ?? 0;

  void _recalc() {
    final pachka   = _toDouble(_pachkaCtrl.text);
    final metr     = _toDouble(_metrCtrl.text);
    final narxMetr = _toDouble(_narxMetrCtrl.text);
    final narxPachka = _toDouble(_narxPachkaCtrl.text);
    final total = (pachka * narxPachka) + (metr * narxMetr);
    _summaCtrl.text = total.toStringAsFixed(2);
    setState(() {});
  }

  void _submit() {
    final p        = widget.purchase;
    final pachka   = _toDouble(_pachkaCtrl.text);
    final metr     = _toDouble(_metrCtrl.text);
    final narxMetr = _toDouble(_narxMetrCtrl.text);
    final narxPachka = _toDouble(_narxPachkaCtrl.text);

    if (pachka == 0 && metr == 0) {
      _toast("Kamida bitta miqdor kiriting");
      return;
    }
    if (pachka > p.qtyPachka) {
      _toast("Pachka ko'pi bilan ${p.qtyPachka} bo'lishi mumkin");
      return;
    }
    if (metr > p.qtyMetr) {
      _toast("Metr ko'pi bilan ${p.qtyMetr} bo'lishi mumkin");
      return;
    }

    final total = (pachka * narxPachka) + (metr * narxMetr);

    Navigator.pop(context, ReturnSelectedItemModel(
      sotuvId:       p.id,
      productId:     p.productId,
      productName:   p.productName,
      productCode:   p.productCode,
      imageUrl:      p.imageUrl,
      returnPachka:  pachka,
      returnDona:    0,
      returnMetr:    metr,
      pricePachkaUsd: narxPachka,
      priceDonaUsd:  0,
      priceMetrUsd:  narxMetr,
      returnTotalUsd: total,
    ));
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.purchase;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(p.productName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.redAccent),
                  ),
                ],
              ),

              // Sotib olingan miqdor
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE7C66A).withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Sotib olingan:",
                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
                    const SizedBox(height: 4),
                    if (p.qtyMetr > 0)
                      Text("Metr: ${p.qtyMetr}",
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    if (p.qtyPachka > 0)
                      Text("Pachka: ${p.qtyPachka}",
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text("Jami: \$${p.jamiUsd.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),

              // Metr
              if (p.qtyMetr > 0) ...[
                const Text("Qaytariladigan metr",
                    style: TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 6),
                _Field(
                  controller: _metrCtrl,
                  hint: "0",
                  suffix: "metr (max ${p.qtyMetr})",
                ),
                const SizedBox(height: 10),
                const Text("Narx (metr)",
                    style: TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 6),
                _Field(controller: _narxMetrCtrl, hint: "0", suffix: "\$"),
                const SizedBox(height: 12),
              ],

              // Pachka
              if (p.qtyPachka > 0) ...[
                const Text("Qaytariladigan pachka",
                    style: TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 6),
                _Field(
                  controller: _pachkaCtrl,
                  hint: "0",
                  suffix: "pachka (max ${p.qtyPachka})",
                ),
                const SizedBox(height: 10),
                const Text("Narx (pachka)",
                    style: TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 6),
                _Field(controller: _narxPachkaCtrl, hint: "0", suffix: "\$"),
                const SizedBox(height: 12),
              ],

              // Jami
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Qaytarish summasi:",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Text("\$${_summaCtrl.text}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Color(0xFFB96D00))),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF4C747),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text("Yaratish",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? suffix;

  const _Field({required this.controller, required this.hint, this.suffix});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        hintText: hint,
        suffixText: suffix,
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
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