import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'press_scale.dart';

class ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final double height;
  final VoidCallback onTap;
  const ActionBtn({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
    this.height = 46,
  });

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.black : AppColors.text;
    return PressScale(
      scale: 0.96,
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: filled ? const Color(0xFFFFC46B) : const Color(0xFF18181A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 17, color: fg),
              const SizedBox(width: 7),
              Text(label,
                  style: TextStyle(
                      color: fg, fontSize: 13.5, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      ),
    );
  }
}