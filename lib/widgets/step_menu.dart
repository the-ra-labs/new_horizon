import 'package:flutter/material.dart';
import '../data/listings.dart';
import '../theme/app_colors.dart';
import 'fade_slide.dart';
import 'press_scale.dart';

class MenuStep {
  final String label;
  final String Function(Listing) value;
  final num Function(Listing) order;
  const MenuStep(this.label, this.value, this.order);
}

class StepMenu extends StatelessWidget {
  final List<MenuStep> steps;
  final List<String?> selected;
  final List<List<String>> options;
  final void Function(int step, String value) onSelect;
  final VoidCallback onReset;

  const StepMenu({
    super.key,
    required this.steps,
    required this.selected,
    required this.options,
    required this.onSelect,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    var visible = 1;
    while (visible < steps.length && selected[visible - 1] != null) {
      visible++;
    }
    final chosen = [
      for (final s in selected)
        if (s != null && s != 'All') s,
    ];
    final anySelected = selected.any((s) => s != null);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        alignment: Alignment.topCenter,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.tune_rounded, size: 18, color: AppColors.orange),
            const SizedBox(width: 8),
            const Text('FILTER MENU',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                )),
            const Spacer(),
            if (anySelected)
              PressScale(
                scale: 0.92,
                onTap: onReset,
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.restart_alt_rounded,
                      size: 16, color: AppColors.peach),
                  SizedBox(width: 4),
                  Text('Reset',
                      style: TextStyle(
                        color: AppColors.peach,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      )),
                ]),
              ),
          ]),
          if (chosen.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              runSpacing: 6,
              children: [
                for (var i = 0; i < chosen.length; i++) ...[
                  if (i > 0)
                    const Icon(Icons.chevron_right_rounded,
                        size: 16, color: AppColors.muted),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(chosen[i],
                        style: const TextStyle(
                          color: AppColors.orange,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        )),
                  ),
                ],
              ],
            ),
          ],
          for (var i = 0; i < visible; i++)
            FadeSlide(
              key: ValueKey('step$i'),
              from: const Offset(0, 0.15),
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text('STEP ${i + 1}',
                            style: const TextStyle(
                              color: AppColors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            )),
                        const SizedBox(width: 8),
                        Text(steps[i].label,
                            style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ]),
                      const SizedBox(height: 10),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final o in options[i])
                          _OptionChip(
                            label: o,
                            selected: selected[i] == o,
                            onTap: () => onSelect(i, o),
                          ),
                      ]),
                    ]),
              ),
            ),
        ]),
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _OptionChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressScale(
      scale: 0.94,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.gradient : null,
          color: selected ? null : AppColors.field,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? Colors.transparent : AppColors.border),
          boxShadow: selected
              ? [
            BoxShadow(
              color: AppColors.orange.withValues(alpha: 0.28),
              blurRadius: 12,
            )
          ]
              : [],
        ),
        child: Text(label,
            style: TextStyle(
              color: selected ? Colors.black : AppColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            )),
      ),
    );
  }
}