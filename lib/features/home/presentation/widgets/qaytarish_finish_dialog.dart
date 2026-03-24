import 'package:flutter/material.dart';
import 'package:olam/features/home/presentation/widgets/pay_type.dart';

class QaytarishFinishDialog extends StatefulWidget {
  final double totalUsd;

  const QaytarishFinishDialog({super.key, required this.totalUsd});

  static Future<PayType?> show(BuildContext context, {required double totalUsd}) {
    return showModalBottomSheet<PayType>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QaytarishFinishDialog(totalUsd: totalUsd),
    );
  }

  @override
  State<QaytarishFinishDialog> createState() => _QaytarishFinishDialogState();
}

class _QaytarishFinishDialogState extends State<QaytarishFinishDialog> {
  PayType _selected = PayType.naqd;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.only(top: 80),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: const Text(
                    "Qaytarish to'lovi",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.redAccent),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Summa
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB96D00), Color(0xFFE0A52C)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  const Text("Qaytariladigan summa",
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    "\$${widget.totalUsd.toStringAsFixed(2)}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text("To'lov turi tanlang:",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),

            const SizedBox(height: 12),

            // To'lov turlari
            Row(
              children: [
                _PayTypeCard(
                  label: "Naqd",
                  icon: Icons.money_rounded,
                  isSelected: _selected == PayType.naqd,
                  onTap: () => setState(() => _selected = PayType.naqd),
                ),
                const SizedBox(width: 10),
                _PayTypeCard(
                  label: "Terminal",
                  icon: Icons.credit_card_rounded,
                  isSelected: _selected == PayType.terminal,
                  onTap: () => setState(() => _selected = PayType.terminal),
                ),
                const SizedBox(width: 10),
                _PayTypeCard(
                  label: "Click",
                  icon: Icons.phone_android_rounded,
                  isSelected: _selected == PayType.click,
                  onTap: () => setState(() => _selected = PayType.click),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _selected),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE7C66A),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26)),
                ),
                child: const Text(
                  "Tasdiqlash",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayTypeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PayTypeCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFE7C66A).withOpacity(0.15)
                : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFE7C66A)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSelected
                      ? const Color(0xFFB96D00)
                      : Colors.grey,
                  size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? const Color(0xFFB96D00)
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}