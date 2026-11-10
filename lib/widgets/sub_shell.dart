import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/app_nav.dart';
import '../utils/helpers.dart';
import '../utils/responsive.dart';
import 'press_scale.dart';

class SubShell extends StatelessWidget {
  final String caption;
  final String title;
  final Widget body;
  const SubShell({
    super.key,
    required this.caption,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final desktop = Responsive.isDesktop(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
            BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
            child: Column(children: [
              _ShellHeader(caption: caption, title: title),
              Expanded(child: body),
              if (!desktop) const _ShellNav(),
            ]),
          ),
        ),
      ),
    );
  }
}

class _ShellHeader extends StatelessWidget {
  final String caption;
  final String title;
  const _ShellHeader({required this.caption, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(caption.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.peach,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                )),
            Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                )),
          ]),
        ),
        PressScale(
          onTap: () => showToast(context, 'No new notifications'),
          child: Stack(clipBehavior: Clip.none, children: [
            const Icon(Icons.notifications_none_rounded,
                color: AppColors.text, size: 26),
            Positioned(
              right: 2,
              top: 0,
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                    color: AppColors.orange, shape: BoxShape.circle),
              ),
            ),
          ]),
        ),
        const SizedBox(width: 14),
        PressScale(
          onTap: () => AppNav.goTab(context, 1),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
                gradient: AppColors.gradient, shape: BoxShape.circle),
            child: const Icon(Icons.person_outline_rounded,
                color: Colors.black, size: 22),
          ),
        ),
      ]),
    );
  }
}

class _ShellNav extends StatelessWidget {
  const _ShellNav();

  Widget _item(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: PressScale(
        scale: 0.9,
        onTap: onTap,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 24, color: AppColors.muted),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              )),
          const SizedBox(height: 9),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
      decoration: const BoxDecoration(
        color: Color(0xFF111112),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        _item(Icons.maps_home_work_outlined, 'HUB',
                () => AppNav.goTab(context, 0)),
        _item(Icons.manage_accounts_outlined, 'PROFILE',
                () => AppNav.goTab(context, 1)),
      ]),
    );
  }
}