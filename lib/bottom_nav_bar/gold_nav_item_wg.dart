import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GoldBottomNavItem extends StatelessWidget {
  final bool isSelected;
  final String icon;
  final String label;
  final VoidCallback onTap;

  const GoldBottomNavItem({
    super.key,
    required this.isSelected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  static const LinearGradient _goldGradient = LinearGradient(
    colors: [
      Color(0xFFB86A00),
      Color(0xFFD89216),
      Color(0xFFF1C24B),
      Color(0xFFC97E07),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color _inactive = Color(0xFFBDBDBD);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: const Color(0xFFD89216).withOpacity(0.12),
          highlightColor: const Color(0xFFD89216).withOpacity(0.06),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF5F1E8) : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: AnimatedScale(
              scale: isSelected ? 1.0 : 0.96,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 160),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeOut,
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: isSelected
                        ? ShaderMask(
                      key: const ValueKey('selected_icon'),
                      shaderCallback: (bounds) =>
                          _goldGradient.createShader(bounds),
                      blendMode: BlendMode.srcIn,
                      child: SvgPicture.asset(
                        icon,
                        width: 22,
                        height: 22,
                        color: Colors.white,
                      ),
                    )
                        : SvgPicture.asset(
                      icon,
                      key: const ValueKey('unselected_icon'),
                      width: 22,
                      height: 22,
                      color: _inactive,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.transparent : _inactive,
                    ),
                    child: isSelected
                        ? ShaderMask(
                      shaderCallback: (bounds) =>
                          _goldGradient.createShader(bounds),
                      blendMode: BlendMode.srcIn,
                      child:  Text(
                        label,
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                        : Text(''),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}