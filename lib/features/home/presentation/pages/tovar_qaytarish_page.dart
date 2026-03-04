import 'package:flutter/material.dart';
import 'package:olam/features/home/presentation/widgets/customer_model.dart';
import 'package:olam/features/home/presentation/widgets/return_selected_item_model.dart';
import 'customer_select_page.dart';
import 'customer_purchase_history_page.dart';


class TovarQaytarishPage extends StatefulWidget {
  const TovarQaytarishPage({super.key});

  @override
  State<TovarQaytarishPage> createState() => _TovarQaytarishPageState();
}

class _TovarQaytarishPageState extends State<TovarQaytarishPage> {
  CustomerModel? _selectedCustomer;
  final List<ReturnSelectedItemModel> _returnItems = [];

  // Hozircha UZS = 0 (keyin kursga ulaymiz)
  int get _totalUzs => 0;

  double get _totalUsd =>
      _returnItems.fold<double>(0, (sum, e) => sum + e.returnTotalUsd);

  Future<void> _pickCustomerAndReturnProduct() async {
    // 1) Mijoz tanlash (hozir demo). Keyin real listni ulab beramiz.
    final customers = <CustomerModel>[
      const CustomerModel(
        id: "1",
        name: "Xaridor Q10",
        phone: "+998 94 34 23",
        address: "Sergeli 3",
      ),
      const CustomerModel(
        id: "2",
        name: "Xaridor Ali",
        phone: "+998 90 11 22 33",
        address: "Chilonzor",
      ),
    ];

    final selectedCustomer = await Navigator.push<CustomerModel>(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerSelectPage(customers: customers),
      ),
    );

    if (selectedCustomer == null) return;

    // Agar boshqa mijoz tanlansa — savat tozalanadi
    if (_selectedCustomer?.id != selectedCustomer.id) {
      setState(() {
        _selectedCustomer = selectedCustomer;
        _returnItems.clear();
      });
    } else {
      setState(() => _selectedCustomer = selectedCustomer);
    }

    // 2) Mijozning sotib olgan mahsulotlari sahifasiga o‘tamiz.
    // U sahifada card bosilganda dialog ochilib,
    // dialog "Saqlash" bosilganda Navigator.pop(context, ReturnSelectedItemModel) qaytishi kerak.
    final ret = await Navigator.push<ReturnSelectedItemModel>(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerPurchaseHistoryPage(
          customer: selectedCustomer,
          items: const [], // ❗ bu yerga keyin real history list beramiz
        ),
      ),
    );

    if (ret == null) return;

    // 3) Return itemni savatga saqlaymiz (purchaseId bo‘yicha update/add)
    setState(() {
      final i = _returnItems.indexWhere((e) => e.purchaseId == ret.purchaseId);
      if (i == -1) {
        _returnItems.add(ret);
      } else {
        _returnItems[i] = ret;
      }
    });
  }

  void _clearCustomerAndCart() {
    setState(() {
      _selectedCustomer = null;
      _returnItems.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final canNext = _selectedCustomer != null && _returnItems.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: const Text(
          "Tovar qaytarish",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
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
            onPressed: _pickCustomerAndReturnProduct,
            icon: const Icon(Icons.group, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          // Mijoz panel
          _CustomerBar(
            customerName: _selectedCustomer?.name,
            onClear: (_selectedCustomer == null) ? null : _clearCustomerAndCart,
          ),

          Expanded(
            child: _buildContent(),
          ),

          // Pastki total va Keyingisi
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
                      Text(
                        "${_formatInt(_totalUzs)} UZS",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "${_formatUsd(_totalUsd)}\$",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: canNext
                        ? () {
                      // Keyingi stepni sen aytasan (pul qaytarish, qarz kamaytirish, ombor, va h.k.)
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2C23A),
                      disabledBackgroundColor:
                      const Color(0xFFF2C23A).withOpacity(0.45),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      "Keyingisi",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
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
      return const Center(
        child: Text(
          "Mijoz tanlang",
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      );
    }

    if (_returnItems.isEmpty) {
      return const Center(
        child: Text(
          "Savat bo‘sh",
          style: TextStyle(fontSize: 20, color: Colors.black54),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      itemCount: _returnItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _returnItems[index];
        return _ReturnCard(item: item);
      },
    );
  }

  String _formatInt(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final pos = s.length - i;
      buf.write(s[i]);
      if (pos > 1 && pos % 3 == 1) buf.write(' ');
    }
    return buf.toString();
  }

  String _formatUsd(double v) {
    final fixed = v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(2);
    return fixed.replaceAll(RegExp(r"\.?0+$"), "");
  }
}

class _CustomerBar extends StatelessWidget {
  final String? customerName;
  final VoidCallback? onClear;

  const _CustomerBar({
    required this.customerName,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0A52C), width: 1),
      ),
      child: Row(
        children: [
          const Text(
            "Mijoz:",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFB96D00),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              customerName ?? "-",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
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

  const _ReturnCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final miqdorText = item.returnDona > 0
        ? "${item.returnDona} dona"
        : item.returnPachka > 0
        ? "${item.returnPachka} pachka"
        : "${item.returnMetr} metr";

    final unitPrice = item.returnDona > 0
        ? item.priceDonaUsd
        : item.returnPachka > 0
        ? item.pricePachkaUsd
        : item.priceMetrUsd;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD58A), width: 1.2),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            offset: Offset(0, 6),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              item.imageUrl,
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
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text("Miqdor: $miqdorText",
                    style: const TextStyle(color: Colors.black87)),
                const SizedBox(height: 6),
                Text("Narx: ${unitPrice.toStringAsFixed(0)}\$",
                    style: const TextStyle(color: Colors.black87)),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Pachka: ${item.returnPachka}",
                  style: const TextStyle(color: Colors.black87)),
              const SizedBox(height: 14),
              Text(
                "Jami: ${item.returnTotalUsd.toStringAsFixed(0)} (\$)",
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}