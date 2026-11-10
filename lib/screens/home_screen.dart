import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/helpers.dart';
import '../utils/responsive.dart';
import '../widgets/press_scale.dart';
import 'auth_screen.dart';
import 'hub_tab.dart';
import '../utils/app_nav.dart';
import 'profile_tab.dart';
import '../data/staff_data.dart';
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String title;
  const _NavItem(this.icon, this.activeIcon, this.label, this.title);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  @override
  void initState() {
    super.initState();
    AppNav.register((i) => setState(() => _index = i));
  }

  @override
  void dispose() {
    AppNav.unregister();
    super.dispose();
  }

  static const _items = [
    _NavItem(Icons.maps_home_work_outlined, Icons.maps_home_work, 'HUB', 'Hub'),
    _NavItem(Icons.manage_accounts_outlined, Icons.manage_accounts, 'PROFILE',
        'Profile'),
  ];

  void _logout() {
    if (Session.previewing) {
      Navigator.of(context).pop(); // Client View se wapas staff par
      return;
    }
    Session.staff = null;
    Navigator.of(context).pushReplacement(fadeRoute(const AuthScreen()));
  }

  Widget _tab() {
    if (_index == 0) {
      return HubTab(onProfile: () => setState(() => _index = 1));
    }
    return ProfileTab(onLogout: _logout);  }

  @override
  Widget build(BuildContext context) {
    final desktop = Responsive.isDesktop(context);
    final maxW = Responsive.maxContentWidth(context);
    final content = AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: KeyedSubtree(key: ValueKey(_index), child: _tab()),
    );

    if (desktop) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: Row(children: [
          _SideRail(
            items: _items,
            index: _index,
            onChanged: (i) => setState(() => _index = i),
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
              _BottomNav(
                items: _items,
                index: _index,
                onChanged: (i) => setState(() => _index = i),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ---------------- Desktop side menu ----------------

class _SideRail extends StatelessWidget {
  final List<_NavItem> items;
  final int index;
  final ValueChanged<int> onChanged;
  final VoidCallback onLogout;
  const _SideRail({
    required this.items,
    required this.index,
    required this.onChanged,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
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
                              letterSpacing: 1.5,
                            )),
                      ]),
                      const SizedBox(height: 36),
                      for (var i = 0; i < items.length; i++)
                        _RailButton(
                          icon: i == index ? items[i].activeIcon : items[i].icon,
                          label: items[i].title,
                          selected: i == index,
                          onTap: () => onChanged(i),
                        ),
                      const Spacer(),
                      const SizedBox(height: 12),
                      _RailButton(
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

class _RailButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RailButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_RailButton> createState() => _RailButtonState();
}

class _RailButtonState extends State<_RailButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  : Colors.transparent,
            ),
          ),
          child: Row(children: [
            Icon(widget.icon,
                size: 22, color: sel ? AppColors.orange : AppColors.muted),
            const SizedBox(width: 14),
            Text(widget.label,
                style: TextStyle(
                  color: sel ? AppColors.orange : AppColors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                )),
          ]),
        ),
      ),
    );
  }
}

// ---------------- Mobile / tablet bottom nav ----------------

class _BottomNav extends StatelessWidget {
  final List<_NavItem> items;
  final int index;
  final ValueChanged<int> onChanged;
  const _BottomNav(
      {required this.items, required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      decoration: const BoxDecoration(
        color: Color(0xFF111112),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final sel = i == index;
          final it = items[i];
          return Expanded(
            child: PressScale(
              scale: 0.9,
              onTap: () => onChanged(i),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                AnimatedScale(
                  scale: sel ? 1.15 : 1,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  child: Icon(sel ? it.activeIcon : it.icon,
                      size: 24,
                      color: sel ? AppColors.orange : AppColors.muted),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: sel ? AppColors.orange : AppColors.muted,
                  ),
                  child: Text(it.label),
                ),
                const SizedBox(height: 4),
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

class _ProfileTab extends StatelessWidget {
  final VoidCallback onLogout;
  const _ProfileTab({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: AppColors.gradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: AppColors.orange.withValues(alpha: 0.35),
                  blurRadius: 30),
            ],
          ),
          child:
          const Icon(Icons.person_rounded, color: Colors.black, size: 44),
        ),
        const SizedBox(height: 16),
        const Text('Respected Investor',
            style: TextStyle(
                color: AppColors.text,
                fontSize: 22,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        const Text('Private Client Tier',
            style: TextStyle(color: AppColors.peach, fontSize: 13)),
        const SizedBox(height: 28),
        PressScale(
          onTap: onLogout,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            decoration: BoxDecoration(
              gradient: AppColors.gradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.logout_rounded, color: Colors.black, size: 18),
              SizedBox(width: 8),
              Text('Logout',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w800)),
            ]),
          ),
        ),
      ]),
    );
  }
}