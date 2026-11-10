import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AuthField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final Widget? trailingLabel;

  const AuthField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.errorText,
    this.onChanged,
    this.trailingLabel,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  final _focus = FocusNode();
  bool _hide = true;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final focused = _focus.hasFocus;
    final borderColor = hasError
        ? AppColors.error
        : focused
        ? AppColors.orange
        : AppColors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label.toUpperCase(),
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            if (widget.trailingLabel != null) widget.trailingLabel!,
          ],
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: focused ? 1.4 : 1),
            boxShadow: focused
                ? [
              BoxShadow(
                color: AppColors.orange.withValues(alpha: 0.18),
                blurRadius: 16,
              )
            ]
                : [],
          ),
          child: Row(children: [
            Icon(widget.icon,
                size: 20, color: focused ? AppColors.orange : AppColors.muted),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                obscureText: widget.isPassword && _hide,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                onChanged: widget.onChanged,
                cursorColor: AppColors.orange,
                style: const TextStyle(color: AppColors.text, fontSize: 15),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: widget.hint,
                  hintStyle:
                  TextStyle(color: AppColors.muted.withValues(alpha: 0.6)),
                ),
              ),
            ),
            if (widget.isPassword)
              GestureDetector(
                onTap: () => setState(() => _hide = !_hide),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _hide
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    key: ValueKey(_hide),
                    size: 20,
                    color: AppColors.muted,
                  ),
                ),
              ),
          ]),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topLeft,
          child: hasError
              ? Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(children: [
              const Icon(Icons.error_outline,
                  size: 14, color: AppColors.error),
              const SizedBox(width: 6),
              Flexible(
                child: Text(widget.errorText!,
                    style: const TextStyle(
                        color: AppColors.error, fontSize: 12)),
              ),
            ]),
          )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}