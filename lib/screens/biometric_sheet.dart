import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BiometricSheet extends StatefulWidget {
  const BiometricSheet({super.key});

  @override
  State<BiometricSheet> createState() => _BiometricSheetState();
}

class _BiometricSheetState extends State<BiometricSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);

    // DEMO: 2 second baad auto-success. Asli biometric ke liye local_auth lagana hai.
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _done = true);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) Navigator.of(context).pop(true);
      });
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _done ? AppColors.success : AppColors.orange;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: AppColors.border, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 22),
          const Text('Instant Concierge',
              style: TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) {
              final v = _pulse.value;
              return Container(
                width: 100 + 28 * v,
                height: 100 + 28 * v,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.withValues(alpha: 0.12 + 0.1 * (1 - v)),
                  border: Border.all(color: c.withValues(alpha: 0.5)),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    _done ? Icons.check_circle_rounded : Icons.fingerprint_rounded,
                    key: ValueKey(_done),
                    color: c,
                    size: 56,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              _done ? 'Verified' : 'Touch the sensor to continue',
              key: ValueKey(_done),
              style: const TextStyle(color: AppColors.muted, fontSize: 14),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.muted)),
          ),
        ]),
      ),
    );
  }
}