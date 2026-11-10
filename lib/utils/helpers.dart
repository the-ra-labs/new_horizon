import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

Route<T> fadeRoute<T>(Widget page) => PageRouteBuilder<T>(
  transitionDuration: const Duration(milliseconds: 500),
  reverseTransitionDuration: const Duration(milliseconds: 400),
  pageBuilder: (_, __, ___) => page,
  transitionsBuilder: (_, anim, __, child) {
    final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  },
);

void showToast(BuildContext context, String msg, {bool error = false}) {
  final m = ScaffoldMessenger.of(context);
  final wide = MediaQuery.of(context).size.width > 500;
  final c = error ? AppColors.error : AppColors.orange;
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: AppColors.card,
    elevation: 0,
    width: wide ? 420 : null,
    margin: wide ? null : const EdgeInsets.all(16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: c.withValues(alpha: 0.6)),
    ),
    content: Row(children: [
      Icon(error ? Icons.error_outline : Icons.check_circle_outline,
          color: c, size: 20),
      const SizedBox(width: 10),
      Expanded(
        child: Text(msg, style: const TextStyle(color: AppColors.text)),
      ),
    ]),
  ));
}

class Validators {
  static String? required(String v, String label) =>
      v.trim().isEmpty ? '$label is required' : null;

  static String? emailOrPhone(String v) {
    final s = v.trim();
    if (s.isEmpty) return 'Email or phone is required';
    final ok = RegExp(r'^[\w\.\-+]+@[\w\-]+\.[\w\.\-]+$').hasMatch(s) ||
        RegExp(r'^\+?[0-9]{10,14}$').hasMatch(s);
    return ok ? null : 'Enter a valid email or phone';
  }

  static String? email(String v) {
    final s = v.trim();
    if (s.isEmpty) return 'Email is required';
    return RegExp(r'^[\w\.\-+]+@[\w\-]+\.[\w\.\-]+$').hasMatch(s)
        ? null
        : 'Enter a valid email';
  }

  static String? phone(String v) {
    final s = v.trim();
    if (s.isEmpty) return 'Phone is required';
    return RegExp(r'^\+?[0-9]{10,14}$').hasMatch(s)
        ? null
        : 'Enter a valid phone number';
  }

  static String? password(String v) =>
      v.length < 6 ? 'Minimum 6 characters' : null;
}