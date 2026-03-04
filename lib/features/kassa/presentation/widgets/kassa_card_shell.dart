import 'package:flutter/material.dart';

class KassaCardShell extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color borderColor;

  const KassaCardShell({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(14, 14, 14, 14),
    this.borderColor = const Color(0xFFE7C66A), // default sariq
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 0.9),
      ),
      child: child,
    );
  }
}