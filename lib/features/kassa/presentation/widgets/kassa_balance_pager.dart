import 'package:flutter/material.dart';
import 'package:olam/features/kassa/presentation/widgets/kassa_balance_card.dart';
import 'package:olam/features/kassa/presentation/widgets/kassa_dots_indicator.dart';

@immutable
class KassaBalanceCardData {
  final String title;
  final double uzs;
  final double usd;

  const KassaBalanceCardData({
    required this.title,
    required this.uzs,
    required this.usd,
  });
}

class KassaBalancePager extends StatefulWidget {
  final List<KassaBalanceCardData> cards;

  /// qaysi kartada bosildi: Naqd/Terminal/Click
  final ValueChanged<KassaBalanceCardData> onAddIncomeTap;

  const KassaBalancePager({
    super.key,
    required this.cards,
    required this.onAddIncomeTap,
  });

  @override
  State<KassaBalancePager> createState() => _KassaBalancePagerState();
}

class _KassaBalancePagerState extends State<KassaBalancePager> {
  final PageController _ctrl = PageController(viewportFraction: 0.92);
  int _index = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 255,
          child: PageView.builder(
            controller: _ctrl,
            itemCount: widget.cards.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) {
              final data = widget.cards[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: KassaBalanceCard(
                  data: data,
                  onAddIncomeTap: () => widget.onAddIncomeTap(data),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        KassaDotsIndicator(count: widget.cards.length, index: _index),
      ],
    );
  }
}