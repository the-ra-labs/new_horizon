import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

ThemeData _dark(BuildContext ctx) => Theme.of(ctx).copyWith(
  colorScheme: const ColorScheme.dark(
    primary: AppColors.orange,
    onPrimary: Colors.black,
    surface: AppColors.card,
    onSurface: AppColors.text,
  ),
);

Future<DateTime?> pickDate(BuildContext context) {
  final now = DateTime.now();
  return showDatePicker(
    context: context,
    initialDate: now.add(const Duration(days: 1)),
    firstDate: now,
    lastDate: now.add(const Duration(days: 365)),
    builder: (ctx, child) => Theme(data: _dark(ctx), child: child!),
  );
}

Future<TimeOfDay?> pickTime(BuildContext context) {
  return showTimePicker(
    context: context,
    initialTime: const TimeOfDay(hour: 11, minute: 0),
    builder: (ctx, child) => Theme(data: _dark(ctx), child: child!),
  );
}

String fmtDate(DateTime d) {
  const m = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day} ${m[d.month - 1]} ${d.year}';
}