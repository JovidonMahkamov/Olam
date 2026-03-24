import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:olam/features/auth/presentation/widgets/text_field_wg.dart';
import 'package:olam/features/home/domain/entity/mijoz_entity.dart';
import 'package:olam/features/home/presentation/bloc/home_bloc.dart';
import 'package:olam/features/home/presentation/bloc/home_event.dart';
import 'package:olam/features/home/presentation/bloc/home_state.dart';
import 'package:olam/features/home/presentation/widgets/create_customer_dialog.dart';
import 'package:olam/features/home/presentation/widgets/create_customer_form_result.dart';
import 'package:olam/features/home/presentation/widgets/sale_customer_model.dart';

class CustomerSelectionPage extends StatefulWidget {
  const CustomerSelectionPage({super.key});

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

  @override
  void initState() {
    super.initState();
    context.read<MijozlarBloc>().add(const GetMijozlarE());
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearch);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    context.read<MijozlarBloc>().add(
      GetMijozlarE(q: _searchController.text.trim()),
    );
  }

  void _onSelectCustomer(MijozEntity mijoz) {
    final customer = SaleCustomerModel(
      id: mijoz.id,
      fullName: mijoz.fish,
      phone: mijoz.telefon,
      address: mijoz.manzil,
      customerType: SaleCustomerType.mijoz,
    );
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextFieldWidgetBoard(
              height: 50,
              text: "Qidiruv",
              obscureText: false,
              readOnly: false,
              prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 30),
              controller: _searchController,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: BlocBuilder<MijozlarBloc, MijozlarState>(
              builder: (context, state) {
                if (state is MijozlarLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is MijozlarError) {
                  return Center(
                    child: Text(state.message,
                        style: const TextStyle(color: Colors.red)),
                  );
                }

                final mijozlar =
                state is MijozlarSuccess ? state.mijozlar : <MijozEntity>[];

                if (mijozlar.isEmpty) {
                  return Center(
                    child: Text(
                      "Mijoz topilmadi",
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
                  itemCount: mijozlar.length,
                  itemBuilder: (context, index) {
                    final mijoz = mijozlar[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CustomerCard(
                        mijoz: mijoz,
                        onTap: () => _onSelectCustomer(mijoz),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: BlocListener<PostMijozBloc, PostMijozState>(
        listener: (context, state) {
          if (state is PostMijozSuccess) {
            // Yangi mijoz qo'shildi — ro'yxatni yangilaymiz
            context.read<MijozlarBloc>().add(const GetMijozlarE());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("${state.mijoz.fish} qo'shildi")),
            );
          } else if (state is PostMijozError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: FloatingActionButton(
          onPressed: () async {
            final CreateCustomerFormResult? result =
            await CreateCustomerDialog.show(context);
            if (result == null || !mounted) return;

            context.read<PostMijozBloc>().add(PostMijozE(
              fish: result.fullName,
              telefon: result.phone.isEmpty ? null : result.phone,
              manzil: result.address.isEmpty ? null : result.address,
            ));
          },
          elevation: 2,
          shape: const CircleBorder(),
          backgroundColor: const Color(0xFFF2C23A),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final MijozEntity mijoz;
  final VoidCallback onTap;

  const _CustomerCard({required this.mijoz, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasPhone = (mijoz.telefon ?? '').trim().isNotEmpty;
    final hasAddress = (mijoz.manzil ?? '').trim().isNotEmpty;

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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      mijoz.fish,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                  ),
                  if (mijoz.qarzdorlik < 0)
                    Text(
                      "${mijoz.qarzdorlik.abs().toStringAsFixed(0)}\$ qarz",
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w600),
                    ),
                ],
              ),
              if (hasPhone) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 13, color: Color(0xFFE0A52C)),
                    const SizedBox(width: 8),
                    Text(mijoz.telefon!,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade700)),
                  ],
                ),
              ],
              if (hasAddress) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 13, color: Color(0xFFE0A52C)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(mijoz.manzil!,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade700)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}