import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'press_scale.dart';

enum _BtnState { idle, loading, success }

class GradientButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Future<bool> Function() onPressed; // true = success
  final VoidCallback onSuccess;
  const GradientButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.onSuccess,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  _BtnState _s = _BtnState.idle;

  Future<void> _tap() async {
    if (_s != _BtnState.idle) return;
    FocusScope.of(context).unfocus();
    setState(() => _s = _BtnState.loading);
    final ok = await widget.onPressed();
    if (!mounted) return;
    if (!ok) {
      setState(() => _s = _BtnState.idle);
      return;
    }
    setState(() => _s = _BtnState.success);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    widget.onSuccess();
  }

  Widget _content() {
    switch (_s) {
      case _BtnState.loading:
        return const SizedBox(
          key: ValueKey('l'),
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.6, color: Colors.black),
        );
      case _BtnState.success:
        return const Icon(Icons.check_rounded,
            key: ValueKey('s'), color: Colors.black, size: 30);
      case _BtnState.idle:
        return FittedBox(
          key: const ValueKey('i'),
          fit: BoxFit.scaleDown,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Icon(widget.icon, size: 18, color: Colors.black),
          ]),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final collapsed = _s != _BtnState.idle;
      return Center(
        child: PressScale(
          onTap: _tap,
          scale: 0.97,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            width: collapsed ? 56 : c.maxWidth,
            height: 56,
            decoration: BoxDecoration(
              gradient: _s == _BtnState.success
                  ? const LinearGradient(
                  colors: [AppColors.success, Color(0xFF8CF0B5)])
                  : AppColors.gradient,
              borderRadius: BorderRadius.circular(collapsed ? 28 : 16),
              boxShadow: [
                BoxShadow(
                  color: (_s == _BtnState.success
                      ? AppColors.success
                      : AppColors.orange)
                      .withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _content(),
              ),
            ),
          ),
        ),
      );
    });
  }
}