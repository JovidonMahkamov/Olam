import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:olam/core/di/services_locator.dart';
import 'package:olam/core/networks/api_urls.dart';
import 'package:olam/core/networks/dio_client.dart';
import 'package:olam/features/home/presentation/widgets/customer_model.dart';
import 'package:olam/features/home/presentation/widgets/customer_purchase_model.dart';
import 'package:olam/features/home/presentation/widgets/return_price_adjust_dialog.dart';
import 'package:olam/features/home/presentation/widgets/return_selected_item_model.dart';

class CustomerPurchaseHistoryPage extends StatefulWidget {
  final CustomerModel customer;

  const CustomerPurchaseHistoryPage({
    super.key,
    required this.customer,
  });

  @override
  State<CustomerPurchaseHistoryPage> createState() =>
      _CustomerPurchaseHistoryPageState();
}

class _CustomerPurchaseHistoryPageState
    extends State<CustomerPurchaseHistoryPage> {
  List<CustomerPurchaseModel> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  Future<void> _loadPurchases() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final dio = sl<DioClient>();

      // 1. Mijoz sotuvlarini olamiz
      final sotuvResp = await dio.get(
        ApiUrls.getSotuvlar,
        queryParams: {
          'mijoz_id': widget.customer.id,
          'holat': 'yakunlangan',
          'har_sahifa': 100,
        },
      );
      final sotuvlar = (sotuvResp.data['data']['sotuvlar'] as List<dynamic>? ?? []);

      // 2. Har bir sotuv elementlarini olamiz
      final List<CustomerPurchaseModel> allItems = [];
      for (final sotuv in sotuvlar) {
        final sotuvId = sotuv['id'];
        try {
          final elemResp = await dio.get('${ApiUrls.sotuvElementlar}$sotuvId/elementlar');
          final elementlar = (elemResp.data['data'] as List<dynamic>? ?? []);
          for (final e in elementlar) {
            allItems.add(CustomerPurchaseModel.fromElementJson(
              e as Map<String, dynamic>,
              sotuv as Map<String, dynamic>,
            ));
          }
        } catch (_) {}
      }

      if (mounted) setState(() { _items = allItems; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = "Xatolik yuz berdi"; _isLoading = false; });
    }
  }

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
        title: Text(widget.customer.name,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.white)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
          : _items.isEmpty
          ? const Center(
          child: Text("Bu mijozda hali savdo yo'q",
              style: TextStyle(fontSize: 16, color: Colors.black54)))
          : ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final p = _items[index];
          return _PurchaseCard(
            item: p,
            onTap: () async {
              final ret = await ReturnPriceAdjustDialog.show(
                context,
                purchase: p,
              );
              if (ret == null || !mounted) return;
              Navigator.pop(context, ret);
            },
          );
        },
      ),
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  final CustomerPurchaseModel item;
  final VoidCallback onTap;

  const _PurchaseCard({required this.item, required this.onTap});

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
            BoxShadow(blurRadius: 14, offset: Offset(0, 6), color: Color(0x14000000)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rasm
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.imageUrl != null
                  ? Image.network(
                item.imageUrl!,
                width: 76, height: 76, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _noImage(),
              )
                  : _noImage(),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.productName,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                      if (item.hasDebt)
                        const Text("Qarz",
                            style: TextStyle(
                                color: Colors.redAccent, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (item.qtyMetr > 0)
                    Text("Metr: ${item.qtyMetr}",
                        style: const TextStyle(color: Colors.black87)),
                  if (item.qtyPachka > 0)
                    Text("Pachka: ${item.qtyPachka}",
                        style: const TextStyle(color: Colors.black87)),
                  if (item.qtyDona > 0)
                    Text("Dona: ${item.qtyDona}",
                        style: const TextStyle(color: Colors.black87)),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (item.narxMetrUsd > 0)
                  Text("${item.narxMetrUsd.toStringAsFixed(2)}\$/metr",
                      style: const TextStyle(fontSize: 12, color: Colors.black54)),
                if (item.narxPachkaUsd > 0)
                  Text("${item.narxPachkaUsd.toStringAsFixed(2)}\$/pachka",
                      style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 8),
                Text("Jami: \$${item.jamiUsd.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.black87)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _noImage() => Container(
    width: 76, height: 76,
    color: Colors.black12,
    alignment: Alignment.center,
    child: const Icon(Icons.image_not_supported_outlined),
  );
}