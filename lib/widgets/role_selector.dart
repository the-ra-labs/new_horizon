import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/auth_demo.dart';
import 'press_scale.dart';

class RoleSelector extends StatelessWidget {
  final AccountRole role;
  final ValueChanged<AccountRole> onChanged;
  const RoleSelector({super.key, required this.role, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('REGISTER AS',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          )),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(
          child: _RoleCard(
            icon: Icons.workspace_premium_outlined,
            title: 'Client',
            subtitle: 'Buy & invest',
            selected: role == AccountRole.client,
            onTap: () => onChanged(AccountRole.client),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _RoleCard(
            icon: Icons.badge_outlined,
            title: 'Staff',
            subtitle: 'CEO approval',
            selected: role == AccountRole.staff,
            onTap: () => onChanged(AccountRole.staff),
          ),
        ),
      ]),
      AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        alignment: Alignment.topCenter,
        child: role == AccountRole.staff
            ? Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.orange.withValues(alpha: 0.4)),
            ),
            child: const Row(children: [
              Icon(Icons.info_outline_rounded,
                  size: 16, color: AppColors.orange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Staff accounts are activated only after the CEO verifies your request.',
                  style: TextStyle(
                      color: AppColors.peach, fontSize: 12, height: 1.35),
                ),
              ),
            ]),
          ),
        )
            : const SizedBox(width: double.infinity),
      ),
    ]);
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressScale(
      scale: 0.96,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.orange.withValues(alpha: 0.12)
              : AppColors.field,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.orange : AppColors.border,
            width: selected ? 1.4 : 1,
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: AppColors.orange.withValues(alpha: 0.18),
              blurRadius: 16,
            )
          ]
              : [],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Icon(icon,
                size: 24, color: selected ? AppColors.orange : AppColors.muted),
            AnimatedScale(
              scale: selected ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: const Icon(Icons.check_circle_rounded,
                  size: 18, color: AppColors.orange),
            ),
          ]),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 11.5)),
        ]),
      ),
    );
  }
}