import 'package:flutter/material.dart';
import 'package:olam/features/home/presentation/widgets/pay_type.dart';
import 'package:olam/features/kassa/presentation/widgets/add_income_bottom_sheet.dart';
import 'package:olam/features/kassa/presentation/widgets/kassa_balance_pager.dart';
import 'package:olam/features/kassa/presentation/widgets/kassa_income_item_card.dart';
import 'package:olam/features/kassa/presentation/widgets/kassa_section_header.dart';
import 'package:olam/features/kassa/presentation/widgets/kassa_store.dart';
class KassaPage extends StatefulWidget {
  final KassaStore store;

  const KassaPage({
    super.key,
    required this.store,
  });

  @override
  State<KassaPage> createState() => _KassaPageState();
}

class _KassaPageState extends State<KassaPage> {
  // Demo: header’dagi summa (keyin store’dan hisoblab berasan)
  double topTotalUzs = 1200000;
  PayType _payTypeFromTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains("terminal")) return PayType.terminal;
    if (t.contains("click")) return PayType.click;
    return PayType.naqd;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
              children: [
                /// 1) Naqd/Terminal/Click swipe card
                KassaBalancePager(
                  cards: const [
                    KassaBalanceCardData(title: "Naqd", uzs: 0, usd: 349.16),
                    KassaBalanceCardData(title: "Terminal", uzs: 56000, usd: 349.16),
                    KassaBalanceCardData(title: "Click", uzs: 12000, usd: 0.06),
                  ],
                  onAddIncomeTap: (selectedCard) {
                    final payType = _payTypeFromTitle(selectedCard.title);
                    AddIncomeBottomSheet.show(
                      context,
                      store: widget.store,
                      payType: payType,
                    );
                  },
                ),

                const SizedBox(height: 14),

                /// 2) Section header
                KassaSectionHeader(
                  leftTitle: "Kunlik kirimlar",
                  rightTitle: "Barchasi",
                  onRightTap: () {
                    // TODO: all incomes page
                  },
                ),

                const SizedBox(height: 10),

                /// 3) Entries list (store’dan)
                AnimatedBuilder(
                  animation: widget.store,
                  builder: (_, __) {
                    final entries = widget.store.entries;

                    if (entries.isEmpty) {
                      return const _EmptyKassaList();
                    }

                    return Column(
                      children: [
                        for (int i = 0; i < entries.length; i++) ...[
                          KassaIncomeItemCard(entry: entries[i]),
                          const SizedBox(height: 12),
                        ],
                      ],
                    );
                  },
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _EmptyKassaList extends StatelessWidget {
  const _EmptyKassaList();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      alignment: Alignment.center,
      child: const Text(
        "Hozircha kirimlar yo‘q",
        style: TextStyle(
          color: Color(0xFF7A7A7A),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
