import 'package:flutter/material.dart';
import 'package:olam/features/home/presentation/widgets/pay_type.dart';
import 'package:olam/features/kassa/presentation/widgets/kassa_balance_card.dart';
import 'package:olam/features/kassa/presentation/widgets/kassa_dots_indicator.dart';

@immutable
class KassaBalanceCardData {
  final String title;
  final double usd;
  final int kassaId;
  final PayType payType;

  const KassaBalanceCardData({
    required this.title,
    required this.usd,
    required this.kassaId,
    required this.payType,
  });
}

class KassaBalancePager extends StatefulWidget {
  final List<KassaBalanceCardData> cards;
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
          height: 200,
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