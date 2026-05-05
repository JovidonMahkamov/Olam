import 'package:flutter/material.dart';
import '../widgets/sale_product_model.dart';
import '../widgets/sale_selected_item_model.dart';

class ProductPriceAdjustDialog extends StatefulWidget {
  final SaleProductModel product;

  const ProductPriceAdjustDialog({
    super.key,
    required this.product,
  });

  static Future<SaleSelectedItemModel?> show(
      BuildContext context, {
        required SaleProductModel product,
      }) {
    return showDialog<SaleSelectedItemModel>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (_) => ProductPriceAdjustDialog(product: product),
    );
  }

  @override
  State<ProductPriceAdjustDialog> createState() => _ProductPriceAdjustDialogState();
}

class _ProductPriceAdjustDialogState extends State<ProductPriceAdjustDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _pachkaCtrl;
  late final TextEditingController _donaCtrl;
  late final TextEditingController _metrCtrl;

  // admin narxlar (readonly)
  late final TextEditingController _adminPriceDonaCtrl;
  late final TextEditingController _adminPricePachkaCtrl;
  late final TextEditingController _adminPriceMetrCtrl;

  // ishchi kiritadigan narxlar (editable)
  late final TextEditingController _sellPriceDonaCtrl;
  late final TextEditingController _sellPricePachkaCtrl;
  late final TextEditingController _sellPriceMetrCtrl;

  // avtomatik hisoblangan summa (readonly)
  late final TextEditingController _summaCtrl;

  @override
  void initState() {
    super.initState();

    _pachkaCtrl = TextEditingController();
    _donaCtrl = TextEditingController();
    _metrCtrl = TextEditingController();

    _adminPriceDonaCtrl = TextEditingController(
      text: widget.product.adminPriceDonaUsd.toStringAsFixed(0),
    );
    _adminPricePachkaCtrl = TextEditingController(
      text: widget.product.adminPricePachkaUsd.toStringAsFixed(0),
    );
    _adminPriceMetrCtrl = TextEditingController(
      text: widget.product.adminPriceMetrUsd.toStringAsFixed(0),
    );

    _sellPriceDonaCtrl = TextEditingController(text: "0");
    _sellPricePachkaCtrl = TextEditingController(text: "0");
    _sellPriceMetrCtrl = TextEditingController(text: "0");

    _summaCtrl = TextEditingController(text: "0");

    // Recalc summa live
    _pachkaCtrl.addListener(_recalc);
    _donaCtrl.addListener(_recalc);
    _metrCtrl.addListener(_recalc);

    _sellPriceDonaCtrl.addListener(_recalc);
    _sellPricePachkaCtrl.addListener(_recalc);
    _sellPriceMetrCtrl.addListener(_recalc);
  }

  @override
  void dispose() {
    _pachkaCtrl.dispose();
    _donaCtrl.dispose();
    _metrCtrl.dispose();

    _adminPriceDonaCtrl.dispose();
    _adminPricePachkaCtrl.dispose();
    _adminPriceMetrCtrl.dispose();

    _sellPriceDonaCtrl.dispose();
    _sellPricePachkaCtrl.dispose();
    _sellPriceMetrCtrl.dispose();

    _summaCtrl.dispose();
    super.dispose();
  }

  // ✅ double — server 43.1, 4.2 kabi decimal qaytaradi
  double _parseOptionalQty(String text) {
    final t = text.trim();
    if (t.isEmpty) return 0;
    return double.tryParse(t.replaceAll(',', '.')) ?? -1;
  }

  double _parseOptionalDouble(String text) {
    final t = text.trim();
    if (t.isEmpty) return 0;
    return double.tryParse(t.replaceAll(',', '.')) ?? double.nan;
  }

  String? _qtyValidator(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return null; // optional
    final n = double.tryParse(t.replaceAll(',', '.'));
    if (n == null) return "Faqat son kiriting";
    if (n < 0) return "Manfiy son bo‘lmaydi";
    return null;
  }

  String? _priceValidator(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return "Narx kiriting (0 bo‘lsa 0 yozing)";
    final d = double.tryParse(t.replaceAll(',', '.'));
    if (d == null) return "To‘g‘ri narx kiriting";
    if (d < 0) return "Manfiy narx bo‘lmaydi";
    return null;
  }

  bool get _hasPachka => _parseOptionalQty(_pachkaCtrl.text) > 0;
  bool get _hasDona => _parseOptionalQty(_donaCtrl.text) > 0;
  bool get _hasMetr => _parseOptionalQty(_metrCtrl.text) > 0;

  int get _unitCount => (_hasPachka ? 1 : 0) + (_hasDona ? 1 : 0) + (_hasMetr ? 1 : 0);

  void _recalc() {
    final soldPachka = _parseOptionalQty(_pachkaCtrl.text);
    final soldDona = _parseOptionalQty(_donaCtrl.text);
    final soldMetr = _parseOptionalQty(_metrCtrl.text);

    // invalid parse bo'lsa chiqib ketamiz
    if (soldPachka < 0 || soldDona < 0 || soldMetr < 0) {
      _summaCtrl.text = "0";
      return;
    }

    final pricePachka = _parseOptionalDouble(_sellPricePachkaCtrl.text);
    final priceDona = _parseOptionalDouble(_sellPriceDonaCtrl.text);
    final priceMetr = _parseOptionalDouble(_sellPriceMetrCtrl.text);

    if (pricePachka.isNaN || priceDona.isNaN || priceMetr.isNaN) {
      _summaCtrl.text = "0";
      return;
    }

    final total = (soldPachka * pricePachka) + (soldDona * priceDona) + (soldMetr * priceMetr);
    _summaCtrl.text = total.toStringAsFixed(0);
    setState(() {}); // UI update (masalan show/hide)
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final soldPachka = _parseOptionalQty(_pachkaCtrl.text);
    final soldDona = _parseOptionalQty(_donaCtrl.text);
    final soldMetr = _parseOptionalQty(_metrCtrl.text);

    if (soldPachka < 0 || soldDona < 0 || soldMetr < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Miqdor maydonlariga to‘g‘ri son kiriting")),
      );
      return;
    }

    if (soldPachka == 0 && soldDona == 0 && soldMetr == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kamida bitta miqdor kiriting (pachka/dona/metr)")),
      );
      return;
    }

    // ❗ Sen aytgandek: faqat 1 ta unit tanlansin
    if (_unitCount != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Faqat bitta tur tanlang: pachka yoki dona yoki metr")),
      );
      return;
    }

    // stock tekshiruv
    if (soldPachka > widget.product.stockPachka) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pachka ko‘pi bilan ${widget.product.stockPachka} ta bo‘lishi mumkin")),
      );
      return;
    }
    if (soldDona > widget.product.stockDona) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Dona ko‘pi bilan ${widget.product.stockDona} ta bo‘lishi mumkin")),
      );
      return;
    }
    if (soldMetr > widget.product.stockMetr) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Metr ko‘pi bilan ${widget.product.stockMetr} bo‘lishi mumkin")),
      );
      return;
    }

    // narxlar
    final pricePachka = _parseOptionalDouble(_sellPricePachkaCtrl.text);
    final priceDona = _parseOptionalDouble(_sellPriceDonaCtrl.text);
    final priceMetr = _parseOptionalDouble(_sellPriceMetrCtrl.text);

    if (pricePachka.isNaN || priceDona.isNaN || priceMetr.isNaN) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Narx maydonlariga to‘g‘ri son kiriting")),
      );
      return;
    }

    // ❗ qaysi miqdor bo‘lsa, faqat o‘sha narx > 0, qolganlari 0 bo‘lsin
    if (_hasPachka) {
      if (pricePachka <= 0 || priceDona != 0 || priceMetr != 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pachka tanlansa: pachka narx > 0, dona/metr narx = 0 bo‘lsin")),
        );
        return;
      }
    }
    if (_hasDona) {
      if (priceDona <= 0 || pricePachka != 0 || priceMetr != 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dona tanlansa: dona narx > 0, pachka/metr narx = 0 bo‘lsin")),
        );
        return;
      }
    }
    if (_hasMetr) {
      if (priceMetr <= 0 || pricePachka != 0 || priceDona != 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Metr tanlansa: metr narx > 0, dona/pachka narx = 0 bo‘lsin")),
        );
        return;
      }
    }

    final total = (soldPachka * pricePachka) + (soldDona * priceDona) + (soldMetr * priceMetr);

    final result = SaleSelectedItemModel(
      productId: widget.product.id,
      productName: widget.product.name,
      productCode: widget.product.code,
      skuTag: widget.product.skuTag,
      imageUrl: widget.product.imageUrl,

      soldPachka: soldPachka,
      soldDona: soldDona,
      soldMetr: soldMetr,

      // admin (ko'rsatish uchun)
      adminPriceDonaUsd: widget.product.adminPriceDonaUsd,
      adminPricePachkaUsd: widget.product.adminPricePachkaUsd,
      adminPriceMetrUsd: widget.product.adminPriceMetrUsd,

      // ishchi kiritgan unit narxlar
      priceDonaUsd: priceDona,
      pricePachkaUsd: pricePachka,
      priceMetrUsd: priceMetr,

      // jami kelishilgan summa
      agreedTotalUsd: total,
    );

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
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
                        widget.product.fullTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4A4A4A),
                        ),
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
                const SizedBox(height: 18),

                _Label("Pachka Miqdor"),
                const SizedBox(height: 6),
                _Field(controller: _pachkaCtrl, hint: "Miqdor kiriting", keyboardType: TextInputType.numberWithOptions(decimal: true), validator: _qtyValidator),
                const SizedBox(height: 10),
                _Label("Metr Miqdor)"),
                const SizedBox(height: 6),
                _Field(controller: _metrCtrl, hint: "Miqdor kiriting", keyboardType: TextInputType.numberWithOptions(decimal: true), validator: _qtyValidator),

                const SizedBox(height: 14),
                const Divider(height: 1),

                const SizedBox(height: 12),
                _Label("Metr narxi"),
                const SizedBox(height: 6),
                _Field(controller: _adminPriceMetrCtrl, hint: "Metr narxi (admin)", readOnly: true),
                _Label("Pachka narxi"),
                const SizedBox(height: 8),
                _Field(controller: _adminPricePachkaCtrl, hint: "Pachka narxi (admin)", readOnly: true),
                const SizedBox(height: 14),
                _Label("Metr narxini kiriting"),
                const SizedBox(height: 8),
                _Field(
                  controller: _sellPriceMetrCtrl,
                  hint: "Metr narxini kiriting",
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: _priceValidator,
                ),
                _Label("Pachka narxini kiriting"),
                const SizedBox(height: 8),
                _Field(
                  controller: _sellPricePachkaCtrl,
                  hint: "Pachka narxini kiriting",
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: _priceValidator,
                ),

                const SizedBox(height: 10),
                _Label("Jami Summa"),
                const SizedBox(height: 6),
                _Field(controller: _summaCtrl, hint: "Jami summa", readOnly: true),

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
                    child: const Text("Yaratish", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF666666),
          fontWeight: FontWeight.w500,
        ),
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