import 'package:flutter/material.dart';

class KassaDotsIndicator extends StatelessWidget {
  final int count;
  final int index;

  const KassaDotsIndicator({
    super.key,
    required this.count,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
            (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i == index ? const Color(0xFF3B3B3B) : const Color(0xFFDADADA),
          ),
        ),
      ),
    );
  }
}