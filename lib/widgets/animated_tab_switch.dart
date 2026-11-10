import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AnimatedTabSwitch extends StatelessWidget {
  final bool isLeft;
  final String left;
  final String right;
  final ValueChanged<bool> onChanged; // true = left selected

  const AnimatedTabSwitch({
    super.key,
    required this.isLeft,
    required this.left,
    required this.right,
    required this.onChanged,
  });

  Widget _tab(String label, bool selected, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
              color: selected ? Colors.black : AppColors.text,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(children: [
        AnimatedAlign(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          child: FractionallySizedBox(
            widthFactor: 0.5,
            heightFactor: 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.gradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orange.withValues(alpha: 0.35),
                    blurRadius: 14,
                  ),
                ],
              ),
            ),
          ),
        ),
        Row(children: [
          Expanded(child: _tab(left, isLeft, () => onChanged(true))),
          Expanded(child: _tab(right, !isLeft, () => onChanged(false))),
        ]),
      ]),
    );
  }
}