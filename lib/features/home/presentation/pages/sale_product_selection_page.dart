import 'package:flutter/material.dart';
import '../widgets/sale_product_model.dart';
import '../widgets/sale_selected_item_model.dart';
import 'sale_product_detail_page.dart';

class SaleProductSelectionPage extends StatefulWidget {
  final List<SaleProductModel> products;
  const SaleProductSelectionPage({super.key,required this.products});

  static Future<SaleSelectedItemModel?> open(BuildContext context) {
    return Navigator.push<SaleSelectedItemModel>(
      context,
      MaterialPageRoute(builder: (_) =>  SaleProductSelectionPage(products: [],)),
    );
  }

  @override
  State<SaleProductSelectionPage> createState() => _SaleProductSelectionPageState();
}

class _SaleProductSelectionPageState extends State<SaleProductSelectionPage> {
  final TextEditingController _searchCtrl = TextEditingController();

  late List<SaleProductModel> _allProducts;
  late List<SaleProductModel> _filteredProducts;

  @override
  void initState() {
    super.initState();
    _allProducts = List<SaleProductModel>.from(widget.products);
    _filteredProducts = List<SaleProductModel>.from(_allProducts);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_filter);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _filter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredProducts = List.of(_allProducts);
      } else {
        _filteredProducts = _allProducts.where((e) {
          return e.name.toLowerCase().contains(q) ||
              e.skuTag.toLowerCase().contains(q) ||
              e.code.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  Future<void> _openDetail(SaleProductModel product) async {
    final selected = await SaleProductDetailPage.open(context, product: product);
    if (selected == null) return;
    if (!mounted) return;

    Navigator.pop(context, selected); // SaleDetailPage ga qaytarish
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
          icon: const Icon(Icons.arrow_back_ios_new,color: Colors.white,),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFDADADA)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: "Qidiruv",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final p = _filteredProducts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ProductListCard(
                    product: p,
                    onTap: () => _openDetail(p),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductListCard extends StatelessWidget {
  final SaleProductModel product;
  final VoidCallback onTap;

  const _ProductListCard({
    required this.product,
    required this.onTap,
  });

  String _rightText(SaleProductModel p) {
    if (p.stockDona > 0) return "${p.stockDona} Dona";
    if (p.stockMetr > 0) return "${p.stockMetr} Metr";
    return "0 Dona";
  }

  String _subText(SaleProductModel p) {
    if (p.stockPachka > 0) return "${p.stockPachka} Pachka";
    if (p.stockDona > 0 && p.stockMetr == 0) return "";
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final sub = _subText(product);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE7C66A), width: 0.8),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade300,
                  image: product.imageUrl != null
                      ? DecorationImage(
                    image: AssetImage(product.imageUrl!),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF444444),
                      ),
                    ),
                    if (sub.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        sub,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _rightText(product),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF444444),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}