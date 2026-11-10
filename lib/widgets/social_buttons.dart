import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'press_scale.dart';

class OrDivider extends StatelessWidget {
  final String label;
  const OrDivider(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Expanded(child: Divider(color: AppColors.border, height: 1)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            )),
      ),
      const Expanded(child: Divider(color: AppColors.border, height: 1)),
    ]);
  }
}

class SocialRow extends StatelessWidget {
  final void Function(String provider) onSelected;
  const SocialRow({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: _SocialButton(
          icon: Icons.mail_rounded,
          color: const Color(0xFFEA4335),
          label: 'Gmail',
          onTap: () => onSelected('Gmail'),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _SocialButton(
          icon: Icons.facebook_rounded,
          color: const Color(0xFF1877F2),
          label: 'Facebook',
          onTap: () => onSelected('Facebook'),
        ),
      ),
    ]);
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _SocialButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressScale(
      scale: 0.96,
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF222225),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                )),
          ]),
        ),
      ),
    );
  }
}

/// DEMO: sirf connecting animation. Asli login ke liye google_sign_in /
/// flutter_facebook_auth + Firebase lagana hoga.
Future<void> connectSocial(BuildContext context, String provider) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                  strokeWidth: 3, color: AppColors.orange),
            ),
            const SizedBox(height: 16),
            Text('Connecting to $provider...',
                style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    ),
  );
  await Future.delayed(const Duration(milliseconds: 1400));
  if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
}