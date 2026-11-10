import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0F0F10);
  static const card = Color(0xFF18181A);
  static const field = Color(0xFF0D0D0E);
  static const border = Color(0xFF26262A);
  static const orange = Color(0xFFF7A10A);
  static const peach = Color(0xFFFFB57D);
  static const text = Color(0xFFF2F2F2);
  static const muted = Color(0xFF8A8A8E);
  static const error = Color(0xFFFF5C5C);
  static const success = Color(0xFF3DDC84);

  static const gradient = LinearGradient(
    colors: [orange, peach],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}