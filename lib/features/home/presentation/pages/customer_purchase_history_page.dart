import 'package:flutter/material.dart';
import 'package:olam/features/home/presentation/widgets/customer_model.dart';
import 'package:olam/features/home/presentation/widgets/customer_purchase_model.dart';
import 'package:olam/features/home/presentation/widgets/return_price_adjust_dialog.dart';

class CustomerPurchaseHistoryPage extends StatelessWidget {
  const CustomerPurchaseHistoryPage({
    super.key,
    required this.customer,
    required this.items,
  });

  final CustomerModel customer;
  final List<CustomerPurchaseModel> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        titleSpacing: 0,
        title: Text(
          customer.name,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
      ),
      body: items.isEmpty
          ? const Center(
        child: Text(
          "Bu mijozda hali savdo yo‘q",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final p = items[index];
          return _PurchaseCard(
            item: p,
            onTap: () async {
              final vm = ReturnablePurchaseVM(
                purchaseId: p.id,
                productId: p.productId ?? p.id, // sizda bo‘lmasa vaqtincha
                name: p.productName,
                code: p.productCode,
                imageUrl: p.imageAssetOrUrl,
                boughtPachka: p.qtyPachka,
                boughtDona: p.qtyDona,
                boughtMetr: 0,
                sellPricePachkaUsd: 0,
                sellPriceDonaUsd: p.priceUsd,
                sellPriceMetrUsd: 0,
              );

              final ret = await ReturnPriceAdjustDialog.show(context, purchase: vm);
              if (ret == null) return;

              Navigator.pop(context, ret); // ✅ TovarQaytarishPage ga qaytadi
            },
          );
        },
      ),
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  const _PurchaseCard({
    required this.item,
    required this.onTap,
  });

  final CustomerPurchaseModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: item.hasDebt ? Colors.redAccent : const Color(0xFFFFD58A),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 14,
              offset: Offset(0, 6),
              color: Color(0x14000000),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _ProductImage(path: item.imageAssetOrUrl),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.productName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        item.productCode,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // left info
                  Text(
                    "Miqdor: ${item.qtyDona} dona",
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Narx: ${_fmtUsd(item.priceUsd)}\$",
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // right info
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Pachka: ${item.qtyPachka}",
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 14),
                Text(
                  "Jami: ${_fmtUsd(item.totalUsd)} \$",
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                if (item.hasDebt) ...[
                  const SizedBox(height: 8),
                  const Text(
                    "Qarz bor",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _fmtUsd(double v) {
    final fixed = v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(2);
    return fixed.replaceAll(RegExp(r"\.?0+$"), "");
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    // Hozircha asset deb olamiz. Agar url bo‘lsa keyin NetworkImage qilamiz.
    return Image.asset(
      path,
      width: 76,
      height: 76,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 76,
        height: 76,
        color: Colors.black12,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_outlined),
      ),
    );
  }
}