import 'package:flutter/material.dart';
import 'package:olam/features/home/presentation/widgets/product_price_adjust_dialog.dart';
import '../widgets/sale_product_model.dart';
import '../widgets/sale_selected_item_model.dart';

class SaleProductDetailPage extends StatelessWidget {
  final SaleProductModel product;

  const SaleProductDetailPage({
    super.key,
    required this.product,
  });

  static Future<SaleSelectedItemModel?> open(
      BuildContext context, {
        required SaleProductModel product,
      }) {
    return Navigator.push<SaleSelectedItemModel>(
      context,
      MaterialPageRoute(
        builder: (_) => SaleProductDetailPage(product: product),
      ),
    );
  }

  Future<void> _onTapCard(BuildContext context) async {
    final result = await ProductPriceAdjustDialog.show(context, product: product);
    if (result == null) return;
    if (!context.mounted) return;

    Navigator.pop(context, result); // SaleDetailPage ga qaytaramiz
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFFB96D00),
                Color(0xFFD8921A),
                Color(0xFFE0A52C),
                Color(0xFFC97D08),
              ],
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
          children: [
            Container(
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade300,
                image: product.imageUrl != null
                    ? DecorationImage(
                  image: AssetImage(product.imageUrl!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: product.imageUrl == null
                  ? const Center(child: Icon(Icons.image, size: 48, color: Colors.white70))
                  : null,
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                "derjatel ${product.name}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF505050),
                ),
              ),
            ),
            const SizedBox(height: 14),

            /// Faqat bitta container
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _onTapCard(context),
              child: Ink(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE7C66A), width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          product.skuTag,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          product.code,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF666666),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _kvRow("Nomi", product.name),
                    const SizedBox(height: 6),
                    _twoColRow("Miqdor", "${product.stockDona} dona", "Pachka", "${product.stockPachka}"),
                    const SizedBox(height: 6),
                    _twoColRow("Metr", "${product.stockMetr}", "Metr narx", "${product.adminPriceMetrUsd.toStringAsFixed(0)}\$"),
                    const SizedBox(height: 6),
                    _twoColRow("Dona", "${product.stockDona}", "Dona narx", "${product.adminPriceDonaUsd.toStringAsFixed(0)}\$"),
                    const SizedBox(height: 6),
                    _twoColRow("Pachka", "${product.stockPachka}", "Pachka narx", "${product.adminPricePachkaUsd.toStringAsFixed(0)}\$"),                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kvRow(String key, String value) {
    return Text(
      "$key: $value",
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF505050),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _twoColRow(String lKey, String lVal, String rKey, String rVal) {
    return Row(
      children: [
        Expanded(
          child: Text(
            "$lKey: $lVal",
            style: const TextStyle(fontSize: 14, color: Color(0xFF505050)),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              "$rKey: $rVal",
              style: const TextStyle(fontSize: 14, color: Color(0xFF505050)),
            ),
          ),
        ),
      ],
    );
  }
}