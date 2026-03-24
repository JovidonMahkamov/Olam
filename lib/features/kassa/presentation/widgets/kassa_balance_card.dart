import 'package:flutter/material.dart';
import 'package:olam/features/kassa/presentation/widgets/kassa_card_shell.dart';
import 'kassa_balance_pager.dart';

class KassaBalanceCard extends StatelessWidget {
  final KassaBalanceCardData data;
  final VoidCallback onAddIncomeTap;

  const KassaBalanceCard({
    super.key,
    required this.data,
    required this.onAddIncomeTap,
  });

  @override
  Widget build(BuildContext context) {
    return KassaCardShell(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            "Balans",
            style: TextStyle(
              fontSize: 12.5,
              color: Color(0xFF8C8C8C),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          _BalanceRow(valueText: "\$${data.usd.toStringAsFixed(2)}"),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: onAddIncomeTap,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFF4C747),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text(
                "Kirim qo'shish",
                style:
                TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  final String valueText;
  const _BalanceRow({required this.valueText});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 44,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        valueText,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF3F3F3F),
        ),
      ),
    );
  }
}