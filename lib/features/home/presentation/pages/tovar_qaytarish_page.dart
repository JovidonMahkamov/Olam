import 'package:flutter/material.dart';
import 'package:olam/core/di/services_locator.dart';
import 'package:olam/core/networks/api_urls.dart';
import 'package:olam/core/networks/dio_client.dart';
import 'package:olam/features/home/domain/entity/mijoz_entity.dart';
import 'package:olam/features/home/presentation/widgets/customer_model.dart';
import 'package:olam/features/home/presentation/widgets/pay_type.dart';
import 'package:olam/features/home/presentation/widgets/return_selected_item_model.dart';
import 'customer_select_page.dart';
import 'customer_purchase_history_page.dart';
import 'package:olam/features/home/presentation/widgets/qaytarish_finish_dialog.dart';

class TovarQaytarishPage extends StatefulWidget {
  final VoidCallback? onGoToKassa;
  const TovarQaytarishPage({super.key, this.onGoToKassa});

  @override
  State<TovarQaytarishPage> createState() => _TovarQaytarishPageState();
}

class _TovarQaytarishPageState extends State<TovarQaytarishPage> {
  CustomerModel? _selectedCustomer;
  final List<ReturnSelectedItemModel> _returnItems = [];
  bool _isSubmitting = false;

  double get _totalUsd =>
      _returnItems.fold<double>(0, (sum, e) => sum + e.returnTotalUsd);

  Future<void> _pickCustomer() async {
    // Mijozlarni API dan olamiz
    List<CustomerModel> customers = [];
    try {
      final dio = sl<DioClient>();
      final resp = await dio.get(ApiUrls.getMijozlar, queryParams: {'har_sahifa': 100});
      final list = resp.data['data']['mijozlar'] as List<dynamic>? ?? [];
      customers = list.map((m) => CustomerModel(
        id:       m['id'].toString(),
        name:     m['fish'] ?? '',
        phone:    m['telefon'],
        address:  m['manzil'],
      )).toList();
    } catch (_) {}

    if (!mounted) return;

    final selectedCustomer = await Navigator.push<CustomerModel>(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerSelectPage(customers: customers),
      ),
    );

    if (selectedCustomer == null || !mounted) return;

    if (_selectedCustomer?.id != selectedCustomer.id) {
      setState(() {
        _selectedCustomer = selectedCustomer;
        _returnItems.clear();
      });
    } else {
      setState(() => _selectedCustomer = selectedCustomer);
    }

    _openPurchaseHistory(selectedCustomer);
  }

  Future<void> _openPurchaseHistory(CustomerModel customer) async {
    final ret = await Navigator.push<ReturnSelectedItemModel>(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerPurchaseHistoryPage(customer: customer),
      ),
    );

    if (ret == null || !mounted) return;

    setState(() {
      final i = _returnItems.indexWhere((e) =>
      e.sotuvId == ret.sotuvId && e.productId == ret.productId);
      if (i == -1) {
        _returnItems.add(ret);
      } else {
        _returnItems[i] = ret;
      }
    });
  }

  void _clearCustomer() {
    setState(() {
      _selectedCustomer = null;
      _returnItems.clear();
    });
  }

  Future<void> _submit() async {
    if (_selectedCustomer == null || _returnItems.isEmpty) return;

    // ✅ To'lov turi tanlash
    final payType = await QaytarishFinishDialog.show(
      context,
      totalUsd: _totalUsd,
    );
    if (payType == null || !mounted) return;

    setState(() => _isSubmitting = true);

    try {
      final dio = sl<DioClient>();

      final elementlar = _returnItems.map((e) => {
        'mahsulot_id': int.tryParse(e.productId) ?? 0,
        'sotuv_id':    int.tryParse(e.sotuvId) ?? 0,
        'dona':    e.returnDona,
        'pachtka': e.returnPachka,
        'metr':    e.returnMetr,
        'narx_usd': e.priceMetrUsd > 0
            ? e.priceMetrUsd
            : e.pricePachkaUsd > 0
            ? e.pricePachkaUsd
            : e.priceDonaUsd,
      }).toList();

      await dio.post(
        ApiUrls.qaytarishlar,
        data: {
          'mijoz_id':   int.tryParse(_selectedCustomer!.id) ?? 0,
          'tolov_turi': payType.name,
          'elementlar': elementlar,
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Qaytarish yaratildi ✅  ${payType.label} orqali ${_totalUsd.toStringAsFixed(2)}\$ qaytarildi"),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _returnItems.clear();
        _selectedCustomer = null;
      });
      // ✅ Kassaga o'tamiz va yangilaymiz
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onGoToKassa?.call();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Xatolik yuz berdi"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canNext = _selectedCustomer != null && _returnItems.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: const Text("Tovar qaytarish",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
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
        actions: [
          IconButton(
            onPressed: _pickCustomer,
            icon: const Icon(Icons.group, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          // Mijoz panel
          _CustomerBar(
            customerName: _selectedCustomer?.name,
            onClear: _selectedCustomer == null ? null : _clearCustomer,
          ),

          Expanded(child: _buildContent()),

          // Pastki total
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
            child: Column(
              children: [
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEFEF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Qaytarish summasi:",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      Text("\$${_totalUsd.toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700,
                              color: Color(0xFFB96D00))),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: canNext && !_isSubmitting ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2C23A),
                      disabledBackgroundColor:
                      const Color(0xFFF2C23A).withOpacity(0.45),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Yakunlash",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedCustomer == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text("Mijoz tanlang",
                style: TextStyle(fontSize: 18, color: Colors.black54)),
          ],
        ),
      );
    }

    if (_returnItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text("Savat bo'sh",
                style: TextStyle(fontSize: 18, color: Colors.black54)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _openPurchaseHistory(_selectedCustomer!),
              icon: const Icon(Icons.add),
              label: const Text("Tovar qo'shish"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF4C747),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      itemCount: _returnItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _returnItems[index];
        return _ReturnCard(
          item: item,
          onDelete: () => setState(() => _returnItems.removeAt(index)),
        );
      },
    );
  }
}

class _CustomerBar extends StatelessWidget {
  final String? customerName;
  final VoidCallback? onClear;

  const _CustomerBar({required this.customerName, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0A52C), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Text("Mijoz:",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB96D00))),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              customerName ?? "-",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onClear != null)
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.delete_outline, color: Colors.black54),
            ),
        ],
      ),
    );
  }
}

class _ReturnCard extends StatelessWidget {
  final ReturnSelectedItemModel item;
  final VoidCallback onDelete;

  const _ReturnCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD58A), width: 1.2),
        boxShadow: const [
          BoxShadow(blurRadius: 14, offset: Offset(0, 6), color: Color(0x14000000)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: item.imageUrl != null
                ? Image.network(item.imageUrl!,
                width: 76, height: 76, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _noImage())
                : _noImage(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                if (item.returnMetr > 0)
                  Text("Metr: ${item.returnMetr}",
                      style: const TextStyle(color: Colors.black87)),
                if (item.returnPachka > 0)
                  Text("Pachka: ${item.returnPachka}",
                      style: const TextStyle(color: Colors.black87)),
                const SizedBox(height: 4),
                Text("Qaytarish: \$${item.returnTotalUsd.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB96D00))),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
        ],
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