import 'package:flutter/material.dart';
import 'package:olam/features/auth/presentation/widgets/text_field_wg.dart';
import 'package:olam/features/home/presentation/widgets/create_customer_dialog.dart';
import 'package:olam/features/home/presentation/widgets/create_customer_form_result.dart';
import 'package:olam/features/home/presentation/widgets/sale_customer_model.dart';

class CustomerSelectionPage extends StatefulWidget {
  const CustomerSelectionPage({super.key});

  /// Qulay ochish uchun
  static Future<SaleCustomerModel?> open(BuildContext context) {
    return Navigator.push<SaleCustomerModel>(
      context,
      MaterialPageRoute(builder: (_) => const CustomerSelectionPage()),
    );
  }

  @override
  State<CustomerSelectionPage> createState() => _CustomerSelectionPageState();
}

class _CustomerSelectionPageState extends State<CustomerSelectionPage> {
  final TextEditingController _searchController = TextEditingController();

  /// Hozircha demo data. Keyin API bilan almashtirish oson:
  /// - _allCustomers = state.customers
  /// - _applyFilter() ishlayveradi
  final List<SaleCustomerModel> _allCustomers = [
    const SaleCustomerModel(
      id: 1,
      fullName: 'Valijon',
      phone: '+998 94 34 23',
      address: 'Sergeli 3',
      customerType: SaleCustomerType.mijoz,
      socialType: 'Eski',
    ),
    const SaleCustomerModel(
      id: 2,
      fullName: 'Alijon',
      phone: null,
      address: null,
      customerType: SaleCustomerType.mijoz,
      socialType: 'Eski',
    ),
    const SaleCustomerModel(
      id: 3,
      fullName: 'Mahmudjon',
      phone: null,
      address: 'Sergeli 3',
      customerType: SaleCustomerType.optom,
      socialType: 'Eski',
    ),
    const SaleCustomerModel(
      id: 4,
      fullName: 'Sobirjon',
      phone: '+998 94 34 23',
      address: null,
      customerType: SaleCustomerType.mijoz,
      socialType: 'Eski',
    ),
  ];

  late List<SaleCustomerModel> _filteredCustomers;

  @override
  void initState() {
    super.initState();
    _filteredCustomers = List.of(_allCustomers);
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_applyFilter)
      ..dispose();
    super.dispose();
  }

  void _applyFilter() {
    final q = _searchController.text.trim().toLowerCase();

    setState(() {
      if (q.isEmpty) {
        _filteredCustomers = List.of(_allCustomers);
        return;
      }

      _filteredCustomers = _allCustomers.where((c) {
        final inName = c.fullName.toLowerCase().contains(q);
        final inPhone = (c.phone ?? '').toLowerCase().contains(q);
        final inAddress = (c.address ?? '').toLowerCase().contains(q);
        return inName || inPhone || inAddress;
      }).toList();
    });
  }

  void _onSelectCustomer(SaleCustomerModel customer) {
    Navigator.pop(context, customer);
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
            child: TextFieldWidgetBoard(
              height: 50,
              text: "Qidiruv",
              obscureText: false,
              readOnly: false,
              prefixIcon: Icon(Icons.search, color: Colors.grey, size: 30),
            ),
          ),

          const SizedBox(height: 14),

          /// List
          Expanded(
            child: _filteredCustomers.isEmpty
                ? Center(
                    child: Text(
                      "Mijoz topilmadi",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
                    itemCount: _filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = _filteredCustomers[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CustomerCard(
                          customer: customer,
                          onTap: () => _onSelectCustomer(customer),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      /// FAB (keyin customer create pagega o'tkazasan)
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final CreateCustomerFormResult? result =
          await CreateCustomerDialog.show(context);

          if (result == null) return;
          if (!context.mounted) return;

          final nextId = _allCustomers.isEmpty ? 1 : (_allCustomers.last.id + 1);

          final newCustomer = SaleCustomerModel(
            id: nextId,
            fullName: result.fullName,
            phone: result.phone.isEmpty ? null : result.phone,
            address: result.address.isEmpty ? null : result.address,
            socialType: result.socialType.isEmpty ? null : result.socialType,
            customerType: result.customerType,
          );

          setState(() {
            _allCustomers.insert(0, newCustomer); // tepaga qo‘shamiz
          });

          _applyFilter(); // qidiruv bo'lsa qayta filtrlasin

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${newCustomer.fullName} qo‘shildi")),
          );

          //  Keyinchalik API bo‘lsa:
          // context.read<CustomerCubit>().createCustomer(...);
          // success bo'lsa listga qo'shasan yoki refresh qilasan
        },
        elevation: 2,
        shape: const CircleBorder(),
        backgroundColor: const Color(0xFFF2C23A),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final SaleCustomerModel customer;
  final VoidCallback onTap;

  const _CustomerCard({required this.customer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasPhone = (customer.phone ?? '').trim().isNotEmpty;
    final hasAddress = (customer.address ?? '').trim().isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE7C66A), width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// top row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      customer.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    customer.typeLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// phone row
              Row(
                children: [
                  const Icon(Icons.phone, size: 13, color: Color(0xFFE0A52C)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasPhone ? customer.phone! : "",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              /// address row
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 13,
                    color: Color(0xFFE0A52C),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasAddress ? customer.address! : "",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
