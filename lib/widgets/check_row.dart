import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CheckRow extends StatelessWidget {
  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;
  const CheckRow({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              gradient: value ? AppColors.gradient : null,
              color: value ? null : AppColors.field,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                  color: value ? Colors.transparent : AppColors.border),
            ),
            child: AnimatedScale(
              scale: value ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: const Icon(Icons.check_rounded,
                  size: 16, color: Colors.black),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          ),
        ]),
      ),
    );
  }
}