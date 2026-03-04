import 'package:flutter/material.dart';
import 'package:olam/features/kassa/presentation/widgets/kassa_card_shell.dart';

class KassaSectionHeader extends StatelessWidget {
  final String leftTitle;
  final String rightTitle;
  final VoidCallback onRightTap;

  const KassaSectionHeader({
    super.key,
    required this.leftTitle,
    required this.rightTitle,
    required this.onRightTap,
  });

  @override
  Widget build(BuildContext context) {
    return KassaCardShell(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Text(
            leftTitle,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3F3F3F),
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: onRightTap,
            child: Row(
              children: [
                Text(
                  rightTitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7A7A7A),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, size: 18, color: Color(0xFF7A7A7A)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}