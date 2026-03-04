
import 'package:flutter/material.dart';
import 'package:olam/core/utils/money_fmt.dart';
import 'package:olam/features/auth/presentation/widgets/elevated_wg.dart';
import 'package:olam/features/home/presentation/pages/customer_selection_page.dart';
import 'package:olam/features/home/presentation/pages/qr_scanner_page.dart';
import 'package:olam/features/home/presentation/pages/sale_product_selection_page.dart';
import 'package:olam/features/home/presentation/widgets/complete_sale_dialog.dart';
import 'package:olam/features/home/presentation/widgets/complete_sale_result.dart';
import 'package:olam/features/home/presentation/widgets/sale_customer_model.dart';
import 'package:olam/features/home/presentation/widgets/sale_product_model.dart';
import 'package:olam/features/home/presentation/widgets/sale_selected_item_model.dart';
import 'package:olam/features/kassa/presentation/widgets/kassa_entry_model.dart';
import 'package:olam/features/kassa/presentation/widgets/kassa_store.dart';

class SaleDetailPage extends StatefulWidget {
  final String saleName;
  final int? saleId;

  ///  kassa store inject qilamiz
  final KassaStore kassaStore;
  final VoidCallback onGoToKassa;
  const SaleDetailPage({
    super.key,
    required this.saleName,
    this.saleId,
    required this.kassaStore, required this.onGoToKassa,
  });

  @override
  State<SaleDetailPage> createState() => _SaleDetailPageState();
}

class _SaleDetailPageState extends State<SaleDetailPage> {
  List<SaleSelectedItemModel> _saleItems = [];
  double totalUzs = 0;
  double totalUsd = 0;

  /// Tanlangan mijoz
  SaleCustomerModel? selectedCustomer;

  final List<SaleProductModel> _catalog = [
    SaleProductModel(
      id: 1,
      name: "011M turkiya",
      code: "Q 10 (A001738)",
      skuTag: "#1",
      imageUrl: "assets/home/parda.jpg",
      stockPachka: 0,
      stockDona: 17,
      stockMetr: 0,
      adminPriceMetrUsd: 0,
      adminPriceDonaUsd: 5,
      adminPricePachkaUsd: 0,
    ),
    SaleProductModel(
      id: 2,
      name: "0422 sinyor",
      code: "Q 10 (A005234)",
      skuTag: "#tilla",
      imageUrl: "assets/home/parda.jpg",
      stockPachka: 197,
      stockDona: 397,
      stockMetr: 0,
      adminPriceMetrUsd: 0,
      adminPriceDonaUsd: 5,
      adminPricePachkaUsd: 12,
    ),
  ];

  void _recalculateTotals() {
    double usd = 0;
    double uzs = 0;
    for (final item in _saleItems) {
      usd += item.totalUsd;
      uzs += item.totalUzs;
    }
    totalUsd = usd;
    totalUzs = uzs;
  }

  void _applyStockDecrease(SaleSelectedItemModel item) {
    final index = _catalog.indexWhere((p) => p.id == item.productId);
    if (index == -1) return;
    final product = _catalog[index];
    final updated = product.copyWith(
      stockPachka: (product.stockPachka - item.soldPachka).clamp(0, 999999),
      stockDona: (product.stockDona - item.soldDona).clamp(0, 999999),
      stockMetr: (product.stockMetr - item.soldMetr).clamp(0, 999999),
    );
    setState(() => _catalog[index] = updated);
  }

  void _restoreStocksFromSaleItems() {
    for (final item in _saleItems) {
      final index = _catalog.indexWhere((p) => p.id == item.productId);
      if (index == -1) continue;
      final p = _catalog[index];
      _catalog[index] = p.copyWith(
        stockPachka: p.stockPachka + item.soldPachka,
        stockDona: p.stockDona + item.soldDona,
        stockMetr: p.stockMetr + item.soldMetr,
      );
    }
  }

  Future<void> _openQrScanner() async {
    final code = await QrScannerPage.open(context);
    if (code == null || code.isEmpty) return;
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Skanerlandi: $code")),
    );
  }

  Future<void> _openCustomerSelection() async {
    final customer = await CustomerSelectionPage.open(context);
    if (customer == null) return;
    if (!mounted) return;

    setState(() => selectedCustomer = customer);
  }

  Future<void> _openProductSelection() async {
    final item = await Navigator.push<SaleSelectedItemModel>(
      context,
      MaterialPageRoute(builder: (_) => SaleProductSelectionPage(products: _catalog)),
    );

    if (item == null) return;
    if (!mounted) return;

    setState(() {
      _saleItems.add(item);
      _recalculateTotals();
    });

    _applyStockDecrease(item);
  }

  void _removeSelectedCustomer() {
    setState(() {
      _restoreStocksFromSaleItems();
      _saleItems.clear();
      _recalculateTotals();
      selectedCustomer = null;
    });
  }
  void _onFinishSale(CompleteSaleResult res) {
    //  Kassa entry yasaymiz
    final entry = KassaEntryModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      customerName: res.customerName,
      productName: res.items.isNotEmpty ? res.items.first.productName : "-",
      address: res.address,
      imageAsset: res.items.isNotEmpty ? res.items.first.imageUrl : null,
      totalUzs: res.totalUzs,
      paidUzs: res.paidUzs,
      debtUzs: res.debtUzs,
      payType: res.payType,
      createdAt: res.createdAt,
    );

    widget.kassaStore.addEntry(entry);

    //  Sale ni tozalab yuboramiz (xohlasang qoldir)
    setState(() {
      _restoreStocksFromSaleItems();
      _saleItems.clear();
      _recalculateTotals();

    });

    widget.onGoToKassa();
  }

  @override
  Widget build(BuildContext context) { final realUzs = totalUsd * MoneyFmt.usdToUzs;
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
        titleSpacing: 0,
        title: Text(
          widget.saleName,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        actions: [
          IconButton(
            tooltip: "QR / Scan",
            onPressed: _openQrScanner,
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
          ),
          IconButton(
            tooltip: "Mijozlar",
            onPressed: _openCustomerSelection,
            icon: const Icon(Icons.groups_2, color: Colors.white),
          ),
          IconButton(
            tooltip: "Qo‘shish",
            onPressed: _openProductSelection,
            icon: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            if (selectedCustomer != null)
              _SelectedCustomerBanner(
                customer: selectedCustomer!,
                onDelete: _removeSelectedCustomer,
              ),
            Expanded(
              child: _saleItems.isEmpty
                  ? const SizedBox()
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                itemCount: _saleItems.length,
                itemBuilder: (context, index) {
                  final item = _saleItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SaleAddedItemCard(item: item),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                _TotalsRow(
                uzsAmount: realUzs,
                usdAmount: totalUsd,
              ),
                  const SizedBox(height: 12),
                  ElevatedWidget(
                    onPressed: () {
                      if (_saleItems.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Avval mahsulot qo‘shing")),
                        );
                        return;
                      }

                      final customerName = selectedCustomer?.fullName ?? "Noma’lum mijoz";
                      final address = selectedCustomer?.address ?? "Manzil: -";

                      CompleteSaleDialog.show(
                        context,
                        items: _saleItems,
                        totalUsd: totalUsd,
                        totalUzs: totalUzs,
                        customerName: customerName,
                        address: address,
                        onFinish: _onFinishSale,
                      );
                    },
                    text: "Keyingisi",
                    backgroundColor: const Color(0xffF4C747),
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedCustomerBanner extends StatelessWidget {
  final SaleCustomerModel customer;
  final VoidCallback onDelete;

  const _SelectedCustomerBanner({
    required this.customer,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFE0A52C).withOpacity(0.55), width: 0.9),
          bottom: BorderSide(color: const Color(0xFFE0A52C).withOpacity(0.75), width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            const Expanded(
              flex: 2,
              child: Text(
                "Mijoz:",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFC97700),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Text(
                customer.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFC97700),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.grey.shade400,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalsRow extends StatelessWidget {
  final double uzsAmount;
  final double usdAmount;

  const _TotalsRow({
    required this.uzsAmount,
    required this.usdAmount,
  });

  String _formatInt(double value) => value.toStringAsFixed(0);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFEAEAEA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                "${_formatInt(uzsAmount)} UZS",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3E3E3E),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                "${_formatInt(usdAmount)}\$",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3E3E3E),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaleAddedItemCard extends StatelessWidget {
  final SaleSelectedItemModel item;

  const _SaleAddedItemCard({required this.item});

  String _unitPriceText(SaleSelectedItemModel item) {
    if (item.soldMetr > 0) return "Metr narx: ${item.priceMetrUsd.toStringAsFixed(0)}\$";
    if (item.soldDona > 0) return "Dona narx: ${item.priceDonaUsd.toStringAsFixed(0)}\$";
    if (item.soldPachka > 0) return "Pachka narx: ${item.pricePachkaUsd.toStringAsFixed(0)}\$";
    return "Narx: -";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7C66A), width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade300,
              image: item.imageUrl != null
                  ? DecorationImage(
                image: AssetImage(item.imageUrl!),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: item.imageUrl == null ? const Icon(Icons.image, color: Colors.white70) : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "${item.productName} ${item.skuTag}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF444444),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.productCode,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Miqdor: ${item.soldDona} dona",
                        style: const TextStyle(fontSize: 14, color: Color(0xFF505050)),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Miqdor: ${item.soldMetr} metr",
                        style: const TextStyle(fontSize: 14, color: Color(0xFF505050)),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Pachka: ${item.soldPachka}",
                          style: const TextStyle(fontSize: 14, color: Color(0xFF505050)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _unitPriceText(item),
                        style: const TextStyle(fontSize: 14, color: Color(0xFF505050)),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Jami: ${item.agreedTotalUsd.toStringAsFixed(0)} \$",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF222222),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}