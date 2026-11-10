import 'package:flutter/material.dart';
import '../data/staff_data.dart';
import '../theme/app_colors.dart';
import '../widgets/fade_slide.dart';
import '../widgets/press_scale.dart';
import '../widgets/staff_ui.dart';
import 'client_preview.dart';
import 'team_tab.dart';

class StaffProfileTab extends StatelessWidget {
  final VoidCallback onLogout;
  const StaffProfileTab({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<StaffMember>>(
      valueListenable: StaffStore.members,
      builder: (context, _, __) {
        final me = Session.staff!;
        final r = me.role;
        final perms = <(String, bool)>[
          ('Add and edit listings', true),
          ('Delete listings', r.deleteListings),
          ('See all leads and viewings', r.seeAll),
          ('Assign leads and viewings', r.assignWork),
          ('Approve new staff', r.approveStaff),
          ('Add, edit and remove staff', r.manageTeam),
        ];

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeSlide(child: _header(context, me)),
                    const SizedBox(height: 14),
                    FadeSlide(
                      delayMs: 80,
                      child: PressScale(
                        onTap: () => openClientView(context),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.orange.withValues(alpha: 0.5)),
                          ),
                          child: const Row(children: [
                            Icon(Icons.visibility_outlined,
                                color: AppColors.orange, size: 26),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Switch to Client View',
                                        style: TextStyle(
                                            color: AppColors.text,
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w800)),
                                    SizedBox(height: 2),
                                    Text('See the app exactly as your clients do',
                                        style: TextStyle(
                                            color: AppColors.muted,
                                            fontSize: 12.5)),
                                  ]),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: AppColors.orange),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    FadeSlide(
                      delayMs: 160,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader('Your Access'),
                            const SizedBox(height: 12),
                            Panel(
                              child: Column(children: [
                                for (final p in perms)
                                  Padding(
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(children: [
                                      Icon(
                                          p.$2
                                              ? Icons.check_circle_rounded
                                              : Icons.lock_outline_rounded,
                                          size: 20,
                                          color: p.$2
                                              ? AppColors.success
                                              : AppColors.muted),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(p.$1,
                                            style: TextStyle(
                                                color: p.$2
                                                    ? AppColors.text
                                                    : AppColors.muted,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ]),
                                  ),
                              ]),
                            ),
                          ]),
                    ),
                    const SizedBox(height: 22),
                    FadeSlide(
                      delayMs: 240,
                      child: PressScale(
                        onTap: onLogout,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: AppColors.gradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout_rounded,
                                    color: Colors.black, size: 18),
                                SizedBox(width: 8),
                                Text('Logout',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800)),
                              ]),
                        ),
                      ),
                    ),
                  ]),
            ),
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context, StaffMember me) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        color: const Color(0xFF242427),
        child: Stack(children: [
          Positioned(
            right: -50,
            bottom: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.orange.withValues(alpha: 0.25),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Row(children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.orange.withValues(alpha: 0.35),
                      blurRadius: 24),
                ],
              ),
              child: ProfileAvatar(me, size: 74),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(me.name,
                    style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(me.title.isEmpty ? me.role.label : me.title,
                    style: const TextStyle(
                        color: AppColors.peach, fontSize: 12.5)),
                const SizedBox(height: 6),
                Text(me.email,
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 12.5)),
                const SizedBox(height: 8),
                Row(children: [
                  RoleBadge(me.role),
                  const SizedBox(width: 10),
                  PressScale(
                    scale: 0.92,
                    onTap: () => showStaffForm(context, member: me, self: true),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.edit_outlined,
                          size: 15, color: AppColors.orange),
                      SizedBox(width: 4),
                      Text('Edit',
                          style: TextStyle(
                              color: AppColors.orange,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800)),
                    ]),
                  ),
                ]),
              ]),
            ),
          ]),
        ]),
      ),
    );
  }
}