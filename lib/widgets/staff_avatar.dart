import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StaffAvatar extends StatelessWidget {
  final String name;
  final String? image; // asset path, null = initials placeholder
  final double width;
  final double height;
  final double radius;

  const StaffAvatar({
    super.key,
    required this.name,
    this.image,
    required this.width,
    required this.height,
    this.radius = 0,
  });

  String get _initials {
    final w = name.trim().split(RegExp(r'\s+'));
    if (w.length == 1) return w.first.substring(0, 1).toUpperCase();
    return (w.first[0] + w.last[0]).toUpperCase();
  }

  Widget _fallback() {
    final base = width.isFinite ? math.min(width, height) : height;
    return Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3A2A12), Color(0xFF1B1B26)],
        ),
      ),
      child: Text(_initials,
          style: TextStyle(
            color: AppColors.orange,
            fontWeight: FontWeight.w800,
            fontSize: base * 0.36,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: image != null
            ? Image.asset(
          image!,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (_, __, ___) => _fallback(),
        )
            : _fallback(),
      ),
    );
  }
}