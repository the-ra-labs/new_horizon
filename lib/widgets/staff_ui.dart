import 'package:flutter/material.dart';
import '../data/staff_data.dart';
import '../theme/app_colors.dart';
import 'press_scale.dart';

const kPanelColor = Color(0xFF1C1C1F);

final menuShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(14),
  side: const BorderSide(color: AppColors.border),
);

PopupMenuItem<T> menuItem<T>(T value, IconData icon, String label,
    {bool danger = false}) {
  final c = danger ? AppColors.error : AppColors.orange;
  return PopupMenuItem<T>(
    value: value,
    child: Row(children: [
      Icon(icon, size: 18, color: c),
      const SizedBox(width: 10),
      Text(label,
          style: TextStyle(
            color: danger ? AppColors.error : AppColors.text,
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
          )),
    ]),
  );
}

Color statusColor(String s) => switch (s) {
  'Available' || 'Completed' => AppColors.success,
  'Reserved' || 'Pending' => AppColors.orange,
  'Confirmed' => const Color(0xFF8AB4F8),
  'Cancelled' => AppColors.error,
  _ => AppColors.muted,
};

String ago(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes}m ago';
  if (d.inHours < 24) return '${d.inHours}h ago';
  return '${d.inDays}d ago';
}

class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? border;
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: kPanelColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: border ?? AppColors.border.withValues(alpha: 0.7)),
      ),
      child: child,
    );
    if (onTap == null) return box;
    return PressScale(scale: 0.98, onTap: onTap, child: box);
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Text(title,
            style: const TextStyle(
                color: AppColors.text,
                fontSize: 17,
                fontWeight: FontWeight.w800)),
      ),
      if (trailing != null) trailing!,
    ]);
  }
}

class Pill extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  const Pill(this.text, this.color, {super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
        ],
        Text(text,
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            )),
      ]),
    );
  }
}

class RoleBadge extends StatelessWidget {
  final StaffRole role;
  const RoleBadge(this.role, {super.key});

  @override
  Widget build(BuildContext context) =>
      Pill(role.label.toUpperCase(), role.color);
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? hint;
  final Color accent;
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.hint,
    this.accent = AppColors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF242427),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 19, color: accent),
        ),
        const SizedBox(height: 12),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value,
              style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 2),
        Text(label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: AppColors.muted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8)),
        if (hint != null) ...[
          const SizedBox(height: 3),
          Text(hint!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: accent, fontSize: 11.5)),
        ],
      ]),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const EmptyState(
      {super.key,
        required this.icon,
        required this.title,
        required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.orange.withValues(alpha: 0.1),
            border: Border.all(color: AppColors.orange.withValues(alpha: 0.4)),
          ),
          child: Icon(icon, color: AppColors.orange, size: 30),
        ),
        const SizedBox(height: 14),
        Text(title,
            style: const TextStyle(
                color: AppColors.text,
                fontSize: 17,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, fontSize: 13)),
      ]),
    );
  }
}

class IconAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final double size;
  const IconAction({
    super.key,
    required this.icon,
    required this.onTap,
    this.color = AppColors.text,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return PressScale(
      scale: 0.9,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF18181A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 19, color: color),
      ),
    );
  }
}

class ChipSelect extends StatelessWidget {
  final String? label;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onChanged;
  final bool scroll;
  const ChipSelect({
    super.key,
    this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.scroll = false,
  });

  Widget _chip(String o) {
    final sel = o == selected;
    return PressScale(
      scale: 0.94,
      onTap: () => onChanged(o),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: sel ? AppColors.gradient : null,
          color: sel ? null : AppColors.field,
          borderRadius: BorderRadius.circular(12),
          border:
          Border.all(color: sel ? Colors.transparent : AppColors.border),
          boxShadow: sel
              ? [
            BoxShadow(
                color: AppColors.orange.withValues(alpha: 0.25),
                blurRadius: 10)
          ]
              : [],
        ),
        child: Text(o,
            style: TextStyle(
              color: sel ? Colors.black : AppColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!.toUpperCase(),
              style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1)),
          const SizedBox(height: 8),
        ],
        if (scroll)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              for (final o in options)
                Padding(
                    padding: const EdgeInsets.only(right: 8), child: _chip(o)),
            ]),
          )
        else
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final o in options) _chip(o),
          ]),
      ],
    );
  }
}

class SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  const SearchBox(
      {super.key,
        required this.controller,
        required this.hint,
        required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        const Icon(Icons.search_rounded, size: 22, color: AppColors.muted),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            cursorColor: AppColors.orange,
            style: const TextStyle(color: AppColors.text, fontSize: 14.5),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: hint,
              hintStyle: TextStyle(
                  color: AppColors.muted.withValues(alpha: 0.7), fontSize: 13.5),
            ),
          ),
        ),
      ]),
    );
  }
}

Future<bool> confirmDialog(
    BuildContext context, {
      required String title,
      required String message,
      String confirmLabel = 'Confirm',
      bool danger = false,
    }) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.border)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                    danger
                        ? Icons.warning_amber_rounded
                        : Icons.help_outline_rounded,
                    color: danger ? AppColors.error : AppColors.orange,
                    size: 32),
                const SizedBox(height: 14),
                Text(title,
                    style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(message,
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 13.5, height: 1.4)),
                const SizedBox(height: 22),
                Row(children: [
                  Expanded(
                    child: _DlgBtn('Cancel', false, AppColors.text,
                            () => Navigator.of(ctx).pop(false)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DlgBtn(
                        confirmLabel,
                        true,
                        danger ? AppColors.error : AppColors.orange,
                            () => Navigator.of(ctx).pop(true)),
                  ),
                ]),
              ]),
        ),
      ),
    ),
  );
  return r ?? false;
}

class _DlgBtn extends StatelessWidget {
  final String label;
  final bool filled;
  final Color color;
  final VoidCallback onTap;
  const _DlgBtn(this.label, this.filled, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return PressScale(
      scale: 0.96,
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: filled ? color : const Color(0xFF18181A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                color: filled ? Colors.black : color,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              )),
        ),
      ),
    );
  }
}

Future<T?> showFormSheet<T>(
    BuildContext context, {
      required String title,
      required Widget child,
    }) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (ctx) {
      final h = MediaQuery.sizeOf(ctx).height;
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: Container(
          constraints: BoxConstraints(maxHeight: h * 0.9),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: Text(title,
                        style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 20,
                            fontWeight: FontWeight.w800)),
                  ),
                  IconAction(
                    icon: Icons.close_rounded,
                    size: 36,
                    onTap: () => Navigator.of(ctx).pop(),
                  ),
                ]),
                const SizedBox(height: 16),
                Flexible(child: SingleChildScrollView(child: child)),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Full-screen page frame (back button + title), staff forms ke liye
class StaffPage extends StatelessWidget {
  final String caption;
  final String title;
  final Widget child;
  final double maxWidth;
  const StaffPage({
    super.key,
    required this.caption,
    required this.title,
    required this.child,
    this.maxWidth = 760,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                child: Row(children: [
                  PressScale(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 15, color: AppColors.text),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(caption.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: AppColors.peach,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2)),
                          Text(title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800)),
                        ]),
                  ),
                ]),
              ),
              Expanded(child: child),
            ]),
          ),
        ),
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  final StaffMember m;
  final double size;
  const ProfileAvatar(this.m, {super.key, this.size = 40});

  Widget _initials() => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
            gradient: AppColors.gradient, shape: BoxShape.circle),
        child: Text(m.initials,
            style: TextStyle(
                color: Colors.black,
                fontSize: size * 0.35,
                fontWeight: FontWeight.w800)),
      );

  @override
  Widget build(BuildContext context) {
    final img = m.image;
    if (img == null) return _initials();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: AppColors.orange.withValues(alpha: 0.6), width: 1.5),
      ),
      child: ClipOval(
        child: Image.asset(
          img,
          width: size,
          height: size,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (_, __, ___) => _initials(),
        ),
      ),
    );
  }
}