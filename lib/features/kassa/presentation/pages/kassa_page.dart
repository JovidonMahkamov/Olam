import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:olam/core/utils/money_fmt.dart';
import 'package:olam/features/home/presentation/widgets/pay_type.dart';
import 'package:olam/features/kassa/domain/entity/kassa_entity.dart';
import 'package:olam/features/kassa/presentation/bloc/kassa_bloc.dart';
import 'package:olam/features/kassa/presentation/bloc/kassa_event.dart';
import 'package:olam/features/kassa/presentation/bloc/kassa_state.dart';
import 'package:olam/features/kassa/presentation/widgets/add_income_bottom_sheet.dart';
import 'package:olam/features/kassa/presentation/widgets/kassa_balance_pager.dart';
import 'package:olam/features/kassa/presentation/widgets/kassa_store.dart';

class KassaPage extends StatefulWidget {
  final KassaStore store;

  const KassaPage({super.key, required this.store});

  @override
  State<KassaPage> createState() => _KassaPageState();
}

class _KassaPageState extends State<KassaPage> {
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    context.read<KassaBloc>().add(const GetKassalarE());
    context.read<BugungiSotuvBloc>().add(const GetBugungiSotuvlarE());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 100),
          children: [
            // ── Kassa balansi kartalar ──
            BlocBuilder<KassaBloc, KassaState>(
              builder: (context, state) {
                if (state is KassaLoading) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                List<KassaEntity> kassalar = [];
                if (state is KassaSuccess) kassalar = state.kassalar;

                final cards = kassalar.map((k) => KassaBalanceCardData(
                  title:   k.turi[0].toUpperCase() + k.turi.substring(1),
                  usd:     k.balansUsd,
                  kassaId: k.id,
                  payType: k.payType,
                )).toList();

                final displayCards = cards.isEmpty
                    ? [
                  KassaBalanceCardData(title: 'Naqd',    usd: 0, kassaId: 1, payType: PayType.naqd),
                  KassaBalanceCardData(title: 'Terminal', usd: 0, kassaId: 2, payType: PayType.terminal),
                  KassaBalanceCardData(title: 'Click',    usd: 0, kassaId: 3, payType: PayType.click),
                ]
                    : cards;

                return KassaBalancePager(
                  cards: displayCards,
                  onAddIncomeTap: (card) async {
                    await AddIncomeBottomSheet.show(
                      context,
                      store:   widget.store,
                      payType: card.payType,
                      kassaId: card.kassaId,
                    );
                    // ✅ Sheet yopilgandan keyin yangilaymiz
                    if (mounted) _refresh();
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            // ── Bugungi sotuvlar statistikasi ──
            BlocBuilder<BugungiSotuvBloc, BugungiSotuvState>(
              builder: (context, state) {
                if (state is BugungiSotuvLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is BugungiSotuvError) {
                  return Center(child: Text(state.message,
                      style: const TextStyle(color: Colors.red)));
                }
                if (state is! BugungiSotuvSuccess) return const SizedBox();

                final stat = state.stat;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Bugungi sotuvlar",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Umumiy kirim — katta karta
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB96D00), Color(0xFFE0A52C)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Umumiy kirim",
                                  style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                              Text(
                                "\$${(stat.jamiUsd + stat.kirimJami).toStringAsFixed(2)}",
                                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Savdo: \$${stat.jamiUsd.toStringAsFixed(2)}",
                                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
                              if (stat.kirimJami > 0)
                                Text("Kirim: +\$${stat.kirimJami.toStringAsFixed(2)}",
                                    style: const TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Statistika kartalar
                    Row(
                      children: [
                        _StatCard(
                          title: "Jami savdo",
                          value: "\$${stat.jamiUsd.toStringAsFixed(2)}",
                          color: const Color(0xFF4CAF50),
                          icon: Icons.trending_up,
                        ),
                        const SizedBox(width: 10),
                        _StatCard(
                          title: "Qarz",
                          value: "\$${stat.qarzJami.toStringAsFixed(2)}",
                          color: Colors.redAccent,
                          icon: Icons.warning_amber_rounded,
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // To'lov turlari (sotuvlar)
                    Row(
                      children: [
                        _PayCard(label: "Naqd",     usd: stat.naqdJami),
                        const SizedBox(width: 8),
                        _PayCard(label: "Terminal", usd: stat.terminalJami),
                        const SizedBox(width: 8),
                        _PayCard(label: "Click",    usd: stat.clickJami),
                      ],
                    ),

                    // Kirimlar (qarz to'lovlari) — faqat bo'sh bo'lmasa ko'rsatamiz
                    if (stat.kirimJami > 0) ...[
                      const SizedBox(height: 10),
                      const Text(
                        "Qarz to'lovlari",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (stat.kirimNaqd > 0) _PayCard(label: "Naqd", usd: stat.kirimNaqd, color: Colors.green),
                          if (stat.kirimNaqd > 0) const SizedBox(width: 8),
                          if (stat.kirimTerminal > 0) _PayCard(label: "Terminal", usd: stat.kirimTerminal, color: Colors.green),
                          if (stat.kirimTerminal > 0) const SizedBox(width: 8),
                          if (stat.kirimClick > 0) _PayCard(label: "Click", usd: stat.kirimClick, color: Colors.green),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Sotuvlar ro'yxati
                    if (stat.sotuvlar.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          "Bugun hali sotuv yo'q",
                          style: TextStyle(color: Color(0xFF7A7A7A)),
                        ),
                      )
                    else
                      Column(
                        children: stat.sotuvlar.map((s) {
                          // O'sha sotuvning qaytarishlari
                          final sQaytarishlar = stat.qaytarishlar
                              .where((q) => q.mijozId == s.mijozId)
                              .toList();
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: _SotuvCard(sotuv: s),
                              ),
                              ...sQaytarishlar.map((q) => Padding(
                                padding: const EdgeInsets.only(bottom: 10, left: 16),
                                child: _QaytarishCard(qaytarish: q),
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Qaytarish karta ──
class _QaytarishCard extends StatelessWidget {
  final BugungiQaytarishEntity qaytarish;
  const _QaytarishCard({required this.qaytarish});

  @override
  Widget build(BuildContext context) {
    final color = _payColor(qaytarish.tolovTuri);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.keyboard_return_rounded,
                color: Colors.redAccent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  qaytarish.mijozFish ?? "Mijoz #${qaytarish.mijozId}",
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14),
                ),
                Text(
                  "Qaytarish · ${qaytarish.tolovTuri}",
                  style: const TextStyle(
                      color: Color(0xFF7A7A7A), fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "-\$${qaytarish.jamiUsd.toStringAsFixed(2)}",
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Colors.redAccent),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  qaytarish.tolovTuri,
                  style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _payColor(String turi) {
    switch (turi) {
      case 'terminal': return const Color(0xFF2F80ED);
      case 'click':    return const Color(0xFF27AE60);
      default:         return const Color(0xFFB96D00);
    }
  }
}

// ── Stat karta ──
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF7A7A7A))),
                  Text(value,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── To'lov turi karta ──
class _PayCard extends StatelessWidget {
  final String label;
  final double usd;
  final Color? color;

  const _PayCard({required this.label, required this.usd, this.color});

  @override
  Widget build(BuildContext context) {
    final borderColor = color?.withOpacity(0.4) ?? const Color(0xFFE7C66A).withOpacity(0.5);
    final textColor = color ?? const Color(0xFF2D2D2D);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7A7A7A),
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              "+\$${usd.toStringAsFixed(2)}",
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sotuv karta ──
class _SotuvCard extends StatelessWidget {
  final BugungiSotuvEntity sotuv;

  const _SotuvCard({required this.sotuv});

  @override
  Widget build(BuildContext context) {
    final hasDebt = sotuv.qarzUsd > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasDebt
              ? Colors.redAccent.withOpacity(0.4)
              : const Color(0xFFE7C66A).withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: hasDebt
                  ? Colors.redAccent.withOpacity(0.1)
                  : const Color(0xFFF4C747).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              hasDebt ? Icons.warning_amber_rounded : Icons.check_circle_outline,
              color: hasDebt ? Colors.redAccent : const Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${sotuv.mijozFish}",
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14),
                ),
                Text(
                  "Sotuv: \$${sotuv.tolovQilinganUsd.toStringAsFixed(2)} · ${sotuv.tolovTuri}",
                  style: const TextStyle(
                      color: Color(0xFF7A7A7A), fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "\$${sotuv.tolovQilinganUsd.toStringAsFixed(2)}",
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 14),
              ),
              if (hasDebt)
                Text(
                  "Qarz: \$${sotuv.qarzUsd.toStringAsFixed(2)}",
                  style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }
}