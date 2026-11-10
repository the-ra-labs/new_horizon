import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StrengthMeter extends StatelessWidget {
  final String password;
  const StrengthMeter({super.key, required this.password});

  int get _score {
    var s = 0;
    if (password.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password)) s++;
    if (RegExp(r'[0-9]').hasMatch(password)) s++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) s++;
    return s;
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox(width: double.infinity);
    final s = _score.clamp(1, 4);
    const colors = [
      AppColors.error,
      AppColors.orange,
      Color(0xFFD4E157),
      AppColors.success,
    ];
    const labels = ['Weak', 'Fair', 'Good', 'Strong'];

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                decoration: BoxDecoration(
                  color: i < s ? colors[s - 1] : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Text(labels[s - 1],
            style: TextStyle(
                color: colors[s - 1],
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}