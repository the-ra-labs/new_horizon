import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/staff_data.dart';
import '../screens/auth_screen.dart';
import '../theme/app_colors.dart';
import '../utils/helpers.dart';
import '../utils/responsive.dart';
import '../widgets/press_scale.dart';
import '../widgets/staff_ui.dart';
import 'client_preview.dart';
import 'dashboard_tab.dart';
import 'listings_tab.dart';
import 'pipeline_tab.dart';
import 'staff_profile_tab.dart';
import 'team_tab.dart';

class _Nav {
  final IconData icon;
  final IconData active;
  final String label;
  final String title;
  final String caption;
  const _Nav(this.icon, this.active, this.label, this.title, this.caption);
}

class StaffShell extends StatefulWidget {
  const StaffShell({super.key});

  @override
  State<StaffShell> createState() => _StaffShellState();
}

class _StaffShellState extends State<StaffShell> {
  int _index = 0;

  static const _items = [
    _Nav(Icons.space_dashboard_outlined, Icons.space_dashboard_rounded,
        'DASHBOARD', 'Dashboard', 'Overview'),
    _Nav(Icons.home_work_outlined, Icons.home_work_rounded, 'LISTINGS',
        'Listings', 'Inventory management'),
    _Nav(Icons.leaderboard_outlined, Icons.leaderboard_rounded, 'PIPELINE',
        'Pipeline', 'Leads & viewings'),
    _Nav(Icons.groups_outlined, Icons.groups_rounded, 'TEAM', 'Team',
        'Staff & approvals'),
    _Nav(Icons.manage_accounts_outlined, Icons.manage_accounts, 'PROFILE',
        'Profile', 'Account & access'),
  ];

  StaffMember get _me => Session.staff!;

  void _go(int i) => setState(() => _index = i);

  void _logout() {
    Session.staff = null;
    Navigator.of(context).pushReplacement(fadeRoute(const AuthScreen()));
  }

  Widget _tab() => switch (_index) {
    0 => DashboardTab(onGoTab: _go),
    1 => const ListingsMgmtTab(),
    2 => const PipelineTab(),
    3 => const TeamTab(),
    _ => StaffProfileTab(onLogout: _logout),
  };

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<StaffMember>>(
      valueListenable: StaffStore.members,
      builder: (context, _, __) {
        final desktop = Responsive.isDesktop(context);
        final maxW = Responsive.maxContentWidth(context);
        final badges = [
          0,
          0,
          0,
          _me.role.approveStaff ? StaffStore.pending.length : 0,
          0,
        ];
        final nav = _items[_index];

        final content = Column(children: [
          _TopBar(
            title: nav.title,
            caption: nav.caption,
            onProfile: () => _go(4),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: KeyedSubtree(key: ValueKey(_index), child: _tab()),
            ),
          ),
        ]);

        if (desktop) {
          return Scaffold(
            backgroundColor: AppColors.bg,
            body: Row(children: [
              _Rail(
                items: _items,
                badges: badges,
                index: _index,
                onChanged: _go,
                onLogout: _logout,
              ),
              Expanded(
                child: SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxW),
                      child: content,
                    ),
                  ),
                ),
              ),
            ]),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: Column(children: [
                  Expanded(child: content),
                  _Bottom(
                      items: _items,
                      badges: badges,
                      index: _index,
                      onChanged: _go),
                ]),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final String caption;
  final VoidCallback onProfile;
  const _TopBar(
      {required this.title, required this.caption, required this.onProfile});

  @override
  Widget build(BuildContext context) {
    final me = Session.staff!;
    final compact = Responsive.isMobile(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                    fontSize: 24,
                    fontWeight: FontWeight.w800)),
          ]),
        ),
        PressScale(
          onTap: () => openClientView(context),
          child: Container(
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: compact ? 11 : 14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.orange.withValues(alpha: 0.5)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.visibility_outlined,
                  size: 18, color: AppColors.orange),
              if (!compact) ...[
                const SizedBox(width: 6),
                const Text('Client View',
                    style: TextStyle(
                        color: AppColors.orange,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800)),
              ],
            ]),
          ),
        ),
        const SizedBox(width: 12),
        PressScale(
          onTap: onProfile,
          child: ProfileAvatar(me, size: 40),
        ),
      ]),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int badge;
  const _BadgeIcon(this.icon, this.color, this.badge);

  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, children: [
      Icon(icon, size: 24, color: color),
      if (badge > 0)
        Positioned(
          right: -9,
          top: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
                color: AppColors.orange,
                borderRadius: BorderRadius.circular(10)),
            child: Text('$badge',
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800)),
          ),
        ),
    ]);
  }
}

class _Bottom extends StatelessWidget {
  final List<_Nav> items;
  final List<int> badges;
  final int index;
  final ValueChanged<int> onChanged;
  const _Bottom(
      {required this.items,
        required this.badges,
        required this.index,
        required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
      decoration: const BoxDecoration(
        color: Color(0xFF111112),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final sel = i == index;
          final it = items[i];
          final c = sel ? AppColors.orange : AppColors.muted;
          return Expanded(
            child: PressScale(
              scale: 0.9,
              onTap: () => onChanged(i),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                AnimatedScale(
                  scale: sel ? 1.12 : 1,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  child: _BadgeIcon(sel ? it.active : it.icon, c, badges[i]),
                ),
                const SizedBox(height: 4),
                Text(it.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: c)),
                const SizedBox(height: 3),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: sel ? 5 : 0,
                  height: sel ? 5 : 0,
                  decoration: const BoxDecoration(
                      color: AppColors.orange, shape: BoxShape.circle),
                ),
              ]),
            ),
          );
        }),
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  final List<_Nav> items;
  final List<int> badges;
  final int index;
  final ValueChanged<int> onChanged;
  final VoidCallback onLogout;
  const _Rail({
    required this.items,
    required this.badges,
    required this.index,
    required this.onChanged,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final me = Session.staff!;
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Color(0xFF111112),
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: LayoutBuilder(builder: (context, c) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: math.max(0.0, c.maxHeight - 44)),
              child: IntrinsicHeight(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset('assets/images/logo.png',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox(width: 40, height: 40)),
                        ),
                        const SizedBox(width: 10),
                        const Text('NEW\nHORIZON',
                            style: TextStyle(
                                color: AppColors.orange,
                                fontSize: 14,
                                height: 1.2,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5)),
                      ]),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(children: [
                          ProfileAvatar(me, size: 38),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(me.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: AppColors.text,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800)),
                                  Text(me.role.label,
                                      style: TextStyle(
                                          color: me.role.color,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700)),
                                ]),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 22),
                      for (var i = 0; i < items.length; i++)
                        _RailBtn(
                          icon: i == index ? items[i].active : items[i].icon,
                          label: items[i].title,
                          selected: i == index,
                          badge: badges[i],
                          onTap: () => onChanged(i),
                        ),
                      const Spacer(),
                      const SizedBox(height: 12),
                      _RailBtn(
                        icon: Icons.visibility_outlined,
                        label: 'Client View',
                        selected: false,
                        onTap: () => openClientView(context),
                      ),
                      _RailBtn(
                        icon: Icons.logout_rounded,
                        label: 'Logout',
                        selected: false,
                        onTap: onLogout,
                      ),
                    ]),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _RailBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final int badge;
  final VoidCallback onTap;
  const _RailBtn({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge = 0,
  });

  @override
  State<_RailBtn> createState() => _RailBtnState();
}

class _RailBtnState extends State<_RailBtn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final sel = widget.selected;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: sel
                ? AppColors.orange.withValues(alpha: 0.15)
                : _hover
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: sel
                    ? AppColors.orange.withValues(alpha: 0.5)
                    : Colors.transparent),
          ),
          child: Row(children: [
            Icon(widget.icon,
                size: 22, color: sel ? AppColors.orange : AppColors.muted),
            const SizedBox(width: 14),
            Expanded(
              child: Text(widget.label,
                  style: TextStyle(
                      color: sel ? AppColors.orange : AppColors.text,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700)),
            ),
            if (widget.badge > 0)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(10)),
                child: Text('${widget.badge}',
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w800)),
              ),
          ]),
        ),
      ),
    );
  }
}