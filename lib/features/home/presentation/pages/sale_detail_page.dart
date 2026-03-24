import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:olam/core/utils/money_fmt.dart';
import 'package:olam/features/auth/presentation/widgets/elevated_wg.dart';
import 'package:olam/features/home/presentation/bloc/home_bloc.dart';
import 'package:olam/features/home/presentation/bloc/home_event.dart';
import 'package:olam/features/home/presentation/bloc/home_state.dart';
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
  final int? mijozId;
  final KassaStore kassaStore;
  final VoidCallback onGoToKassa;

  const SaleDetailPage({
    super.key,
    required this.saleName,
    this.saleId,
    this.mijozId,
    required this.kassaStore,
    required this.onGoToKassa,
  });

  @override
  State<SaleDetailPage> createState() => _SaleDetailPageState();
}

class _SaleDetailPageState extends State<SaleDetailPage> {
  List<SaleSelectedItemModel> _saleItems = [];
  double totalUsd = 0;
  double totalUzs = 0;
  SaleCustomerModel? selectedCustomer;

  // API ga yuborilgan sotuv ID si
  int? _activeSotuvId;
  bool _isCreatingSotuv = false;

  @override
  void initState() {
    super.initState();
    _activeSotuvId = widget.saleId;
  }

  void _recalculateTotals() {
    double usd = 0;
    for (final item in _saleItems) {
      usd += item.totalUsd;
    }
    totalUsd = usd;
    totalUzs = usd * MoneyFmt.usdToUzs;
  }

  Future<void> _openQrScanner() async {
    final code = await QrScannerPage.open(context);
    if (code == null || code.isEmpty || !mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Skanerlandi: $code")));
  }

  Future<void> _openCustomerSelection() async {
    final customer = await CustomerSelectionPage.open(context);
    if (customer == null || !mounted) return;
    setState(() => selectedCustomer = customer);
  }

  Future<void> _openProductSelection() async {
    // Avval mijoz tanlanganmi tekshiramiz
    if (selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Avval mijozni tanlang")),
      );
      return;
    }

    // Sotuv hali yaratilmagan bo'lsa, avval yaratamiz
    if (_activeSotuvId == null) {
      await _createSotuv();
      if (_activeSotuvId == null) return; // yaratish muvaffaqiyatsiz
    }

    // ✅ Mahsulotlarni API dan olamiz
    context.read<MahsulotlarBloc>().add(const GetMahsulotlarE());

    // Mahsulotlar yuklanishini kutamiz
    final mahsulotlarState = await Future<MahsulotlarState>(() async {
      MahsulotlarState? result;
      final stream = context.read<MahsulotlarBloc>().stream;
      await for (final state in stream) {
        if (state is MahsulotlarSuccess || state is MahsulotlarError) {
          result = state;
          break;
        }
      }
      return result ?? context.read<MahsulotlarBloc>().state;
    });

    if (!mounted) return;

    if (mahsulotlarState is MahsulotlarError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mahsulotlarState.message)),
      );
      return;
    }

    // MahsulotEntity -> SaleProductModel ga o'giramiz
    final List<SaleProductModel> products = [];
    if (mahsulotlarState is MahsulotlarSuccess) {
      for (final m in mahsulotlarState.mahsulotlar) {
        products.add(SaleProductModel(
          id:                  m.id,
          name:                m.nomi,
          code:                m.kodi,
          skuTag:              m.kodi,
          stockDona:           m.miqdor,        // ✅ double as-is
          stockPachka:         m.pochka,         // ✅ double as-is
          stockMetr:           m.metr,           // ✅ double as-is
          adminPriceDonaUsd:   m.narxDona ?? 0,         // ✅ narx_dona
          adminPricePachkaUsd: m.narxPochka ?? 0,       // ✅ narx_pochka
          adminPriceMetrUsd:   m.narxMetr ?? 0,         // ✅ narx_metr
          imageUrl:            m.rasmUrl,
        ));
      }
    }

    final item = await SaleProductSelectionPage.open(context, products: products);
    if (item == null || !mounted) return;

    // API ga element qo'shamiz
    context.read<PostSotuvElementBloc>().add(PostSotuvElementE(
      sotuvId: _activeSotuvId!,
      mahsulotId: item.productId,
      dona: item.soldDona.toDouble(),
      pachtka: item.soldPachka.toDouble(),
      metr: item.soldMetr.toDouble(),
      narxUsd: item.usedUnitPriceUsd,
    ));

    setState(() {
      _saleItems.add(item);
      _recalculateTotals();
    });
  }

  Future<void> _createSotuv() async {
    if (_isCreatingSotuv || selectedCustomer == null) return;
    setState(() => _isCreatingSotuv = true);

    context.read<PostSotuvBloc>().add(PostSotuvE(
      nomi: widget.saleName,
      mijozId: selectedCustomer!.id,
    ));

    // PostSotuvBloc listener orqali _activeSotuvId o'rnatiladi
    // Shuning uchun kichik wait qilamiz
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isCreatingSotuv = false);
  }

  void _removeSelectedCustomer() {
    setState(() {
      _saleItems.clear();
      _recalculateTotals();
      selectedCustomer = null;
      _activeSotuvId = widget.saleId;
    });
  }

  void _onFinishSale(CompleteSaleResult res) {
    if (_activeSotuvId == null) return;

    // Kassa entry ni saqlayapmiz — API javobini kutmasdan
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

    // ✅ API ga yakunlash so'rovini yuboramiz
    // onGoToKassa endi YakunlashSotuvSuccess listener da chaqiriladi
    context.read<YakunlashSotuvBloc>().add(YakunlashSotuvE(
      sotuvId: _activeSotuvId!,
      tolovTuri: res.payType.name,
      tolovQilinganUsd: res.paidUzs / MoneyFmt.usdToUzs,
      chegirma: res.discountEnabled,
      sms: res.smsEnabled,
      izoh: res.note.isEmpty ? null : res.note,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final realUzs = totalUsd * MoneyFmt.usdToUzs;

    return MultiBlocListener(
      listeners: [
        // Sotuv yaratilganda ID ni olamiz
        BlocListener<PostSotuvBloc, PostSotuvState>(
          listener: (context, state) {
            if (state is PostSotuvSuccess) {
              setState(() => _activeSotuvId = state.sotuv.id);
            } else if (state is PostSotuvError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        ),
        // Element qo'shilganda
        BlocListener<PostSotuvElementBloc, PostSotuvElementState>(
          listener: (context, state) {
            if (state is PostSotuvElementError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        ),
        // Yakunlash
        BlocListener<YakunlashSotuvBloc, YakunlashSotuvState>(
          listener: (context, state) {
            if (state is YakunlashSotuvSuccess) {
              // ✅ Avval state ni tozalaymiz
              setState(() {
                _saleItems.clear();
                _recalculateTotals();
                _activeSotuvId = null;
              });
              // ✅ Keyin kassa ga o'tamiz — PostFrameCallback bilan
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) widget.onGoToKassa();
              });
            } else if (state is YakunlashSotuvError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        ),
      ],
      child: Scaffold(
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
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.white),
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
              tooltip: "Qo'shish",
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
                    ? Center(
                  child: Text(
                    selectedCustomer == null
                        ? "Avval mijoz tanlang (yuqoridagi groups icon)"
                        : "Mahsulot qo'shing (+ tugmasi)",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 15),
                  ),
                )
                    : ListView.builder(
                  padding:
                  const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
                    _TotalsRow(uzsAmount: realUzs, usdAmount: totalUsd),
                    const SizedBox(height: 12),
                    ElevatedWidget(
                      onPressed: () {
                        if (_saleItems.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Avval mahsulot qo'shing")),
                          );
                          return;
                        }

                        CompleteSaleDialog.show(
                          context,
                          items: _saleItems,
                          totalUsd: totalUsd,
                          totalUzs: totalUzs,
                          customerName:
                          selectedCustomer?.fullName ?? "Noma'lum mijoz",
                          address: selectedCustomer?.address ?? "-",
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
      ),
    );
  }
}

class _SelectedCustomerBanner extends StatelessWidget {
  final SaleCustomerModel customer;
  final VoidCallback onDelete;

  const _SelectedCustomerBanner(
      {required this.customer, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
              color: const Color(0xFFE0A52C).withOpacity(0.75), width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            const Text("Mijoz:",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFC97700))),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                customer.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFC97700)),
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline,
                  color: Colors.grey.shade400, size: 24),
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

  const _TotalsRow({required this.uzsAmount, required this.usdAmount});

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
                "${uzsAmount.toStringAsFixed(0)} UZS",
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3E3E3E)),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                "${usdAmount.toStringAsFixed(0)}\$",
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3E3E3E)),
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
            ),
            child: item.imageUrl != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(item.imageUrl!, fit: BoxFit.cover),
            )
                : const Icon(Icons.image, color: Colors.white70),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF444444)),
                ),
                const SizedBox(height: 6),
                Text(
                  "Miqdor: ${item.soldDona}d / ${item.soldMetr}m / ${item.soldPachka}p",
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF505050)),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                        child: Text(_unitPriceText(item),
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF505050)))),
                    Text(
                      "Jami: ${item.agreedTotalUsd.toStringAsFixed(0)}\$",
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF222222)),
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