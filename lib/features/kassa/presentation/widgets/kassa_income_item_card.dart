import 'package:flutter/material.dart';
import 'package:olam/core/utils/money_fmt.dart';
import 'package:olam/features/home/presentation/widgets/pay_type.dart';
import 'package:olam/features/kassa/presentation/widgets/kassa_entry_model.dart';
import 'kassa_card_shell.dart';

class KassaIncomeItemCard extends StatelessWidget {
  final KassaEntryModel entry;

  const KassaIncomeItemCard({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return KassaCardShell(
      borderColor: entry.hasDebt ? Colors.redAccent : const Color(0xFFE7C66A),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Thumb(imageAsset: entry.imageAsset),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3F3F3F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6A6A6A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  entry.address,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF8A8A8A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),

                // ✅ To‘langan, Qarz, To‘lov turi ko‘rinadi
                _InfoLine(label: "To‘langan", value: _fmt(entry.paidUzs)),
                if (entry.hasDebt) _InfoLine(label: "Qarz", value: _fmt(entry.debtUzs)),
                _InfoLine(label: "To‘lov", value: entry.payType.label),
                if ((entry.note ?? '').trim().isNotEmpty)
                  _InfoLine(label: "Izoh", value: entry.note!.trim()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int uzs) => MoneyFmt.usdFromUzs(uzs);
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;
  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF6F6F6F),
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF6F6F6F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String? imageAsset;
  const _Thumb({required this.imageAsset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFE0E0E0),
        image: imageAsset == null
            ? null
            : DecorationImage(
          image: AssetImage(imageAsset!),
          fit: BoxFit.cover,
        ),
      ),
      child: imageAsset == null
          ? const Icon(Icons.image, color: Colors.white70, size: 22)
          : null,
    );
  }
}