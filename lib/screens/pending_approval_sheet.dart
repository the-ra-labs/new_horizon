import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/press_scale.dart';

Future<void> showPendingApprovalSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: 440),
    builder: (_) => const _PendingSheet(),
  );
}

class _PendingSheet extends StatelessWidget {
  const _PendingSheet();

  @override
  Widget build(BuildContext context) {
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
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.4, end: 1.0),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.orange.withValues(alpha: 0.12),
                border:
                Border.all(color: AppColors.orange.withValues(alpha: 0.5)),
              ),
              child: const Icon(Icons.hourglass_top_rounded,
                  color: AppColors.orange, size: 36),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Awaiting CEO Approval',
              style: TextStyle(
                  color: AppColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text(
            'Your staff account request has been sent to the CEO. You will be able to sign in once it is approved.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 13.5, height: 1.4),
          ),
          const SizedBox(height: 24),
          PressScale(
            scale: 0.97,
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              height: 52,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppColors.gradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text('Got it',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}