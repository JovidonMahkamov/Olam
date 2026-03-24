import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:olam/features/home/domain/entity/mahsulot_entity.dart';
import 'package:olam/features/home/presentation/bloc/home_bloc.dart';
import 'package:olam/features/home/presentation/bloc/home_event.dart';
import 'package:olam/features/home/presentation/bloc/home_state.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    context.read<MahsulotlarBloc>().add(
      GetMahsulotlarE(),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Column(
        children: [

          /// HEADER
          Container(
            padding: EdgeInsets.only(
              left: 14,
              right: 14,
              top: MediaQuery.of(context).padding.top + 10,
              bottom: 14,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFB96D00),
                  Color(0xFFD8921A),
                  Color(0xFFE0A52C),
                  Color(0xFFC97D08),
                ],
              ),
            ),
            child: SearchBar(
              controller: _searchCtrl,
              hintText: "Qidiruv",
              onChanged: (v) {
                context.read<MahsulotlarBloc>().add(
                  GetMahsulotlarE(q: v),
                );
              },
              onTap: () {
                _searchCtrl.clear();

                context.read<MahsulotlarBloc>().add(
                  GetMahsulotlarE(),
                );
              },
            ),
          ),

          /// LIST
          Expanded(
            child: BlocBuilder<MahsulotlarBloc, MahsulotlarState>(
              builder: (context, state) {

                if (state is MahsulotlarLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is MahsulotlarSuccess) {

                  final products = state.mahsulotlar;

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
                    itemCount: products.length,
                    itemBuilder: (context, index) {

                      final product = products[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ProductSearchCard(
                          mahsulot: product,
                          onTap: () {},
                        ),
                      );
                    },
                  );
                }

                if (state is MahsulotlarError) {
                  return Center(child: Text(state.message));
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductSearchCard extends StatelessWidget {
  final MahsulotEntity mahsulot;
  final VoidCallback onTap;

  const _ProductSearchCard({
    required this.mahsulot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    String rightMain = "";

    if (mahsulot.miqdor > 0) {
      rightMain = "${mahsulot.miqdor} Dona";
    } else if (mahsulot.metr > 0) {
      rightMain = "${mahsulot.metr} Metr";
    }

    String extra = "";

    if (mahsulot.pochka > 0) {
      extra = "${mahsulot.pochka} Pachka";
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE7C66A),
            ),
          ),
          child: Row(
            children: [

              /// IMAGE
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade300,
                ),
                child: mahsulot.rasmUrl != null
                    ? Image.network(mahsulot.rasmUrl!)
                    : const Icon(Icons.image),
              ),

              const SizedBox(width: 10),

              /// NAME
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      mahsulot.nomi,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    if (extra.isNotEmpty)
                      Text(
                        extra,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),

              /// RIGHT
              Text(
                rightMain,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}