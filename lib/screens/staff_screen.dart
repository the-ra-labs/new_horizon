import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/helpers.dart';
import '../utils/responsive.dart';
import '../widgets/fade_slide.dart';
import '../widgets/press_scale.dart';
import '../widgets/staff_avatar.dart';
import '../data/staff_data.dart';
// ---------------- Sample data (baad mein backend se aayega) ----------------
// Photos ke liye image: 'assets/images/staff/ceo.jpg' do aur pubspec mein
// '- assets/images/staff/' add karo.

class _Director {
  final String name, role, creds, focus, portfolio;
  final String? image;
  const _Director(this.name, this.role, this.creds, this.focus, this.portfolio,
      [this.image]);
}

class _Advisor {
  final String name, role, mandates, languages, region;
  final String rating;
  final String? image;
  const _Advisor(this.name, this.role, this.mandates, this.languages,
      this.region, this.rating,
      [this.image]);
}

List<_Director> get _directors => [
  for (final m in StaffStore.approved
      .where((m) => m.role == StaffRole.manager))
    _Director(m.name, m.title.toUpperCase(), m.credentials, m.focus,
        m.portfolio, m.image),
];

List<_Advisor> get _advisors => [
  for (final m
  in StaffStore.approved.where((m) => m.role == StaffRole.agent))
    _Advisor(m.name, m.title, m.portfolio, m.languages, m.region,
        m.rating.toStringAsFixed(1), m.image),
];


// ---------------- Helpers ----------------

Future<void> _schedule(BuildContext context, String name) async {
  final now = DateTime.now();
  final d = await showDatePicker(
    context: context,
    initialDate: now.add(const Duration(days: 1)),
    firstDate: now,
    lastDate: now.add(const Duration(days: 365)),
    builder: (ctx, child) => Theme(
      data: Theme.of(ctx).copyWith(
        colorScheme: const ColorScheme.dark(
          primary: AppColors.orange,
          onPrimary: Colors.black,
          surface: AppColors.card,
          onSurface: AppColors.text,
        ),
      ),
      child: child!,
    ),
  );
  if (d != null && context.mounted) {
    showToast(context,
        'Meeting with $name requested for ${d.day}/${d.month}/${d.year}');
  }
}

// ---------------- Screen ----------------

class StaffScreen extends StatelessWidget {
  final VoidCallback onProfile;
  const StaffScreen({super.key, required this.onProfile});

  Widget _pad(Widget c) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: c);

  void _toProfile(BuildContext context) {
    Navigator.of(context).pop();
    onProfile();
  }

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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlide(
                        child: _Header(
                          onBack: () => Navigator.of(context).pop(),
                          onProfile: () => _toProfile(context),
                        ),
                      ),
                      FadeSlide(delayMs: 80, child: _pad(const _Breadcrumb())),
                      const SizedBox(height: 14),
                      FadeSlide(delayMs: 160, child: _pad(const _CeoCard())),
                      const SizedBox(height: 30),
                      FadeSlide(
                        delayMs: 240,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _pad(const _SectionTitle(
                              title: 'Executive Directors',
                              trailing: Text('3 Principals',
                                  style: TextStyle(
                                      color: AppColors.muted, fontSize: 12.5)),
                            )),
                            const SizedBox(height: 14),
                            const _DirectorList(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      FadeSlide(
                        delayMs: 320,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _pad(_SectionTitle(
                              title: 'Senior Advisors',
                              trailing: PressScale(
                                scale: 0.92,
                                onTap: () => showToast(
                                    context, 'Full directory coming soon'),
                                child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('View All',
                                          style: TextStyle(
                                              color: AppColors.peach,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w800)),
                                      Icon(Icons.chevron_right_rounded,
                                          size: 16, color: AppColors.peach),
                                    ]),
                              ),
                            )),
                            const SizedBox(height: 14),
                            _pad(const _AdvisorGrid()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!desktop)
                _StaffNav(
                  onHub: () => Navigator.of(context).pop(),
                  onProfile: () => _toProfile(context),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ---------------- Header & breadcrumb ----------------

class _Header extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onProfile;
  const _Header({required this.onBack, required this.onProfile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      child: Row(children: [
        PressScale(
          onTap: onBack,
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
        const Spacer(),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PRIVATE PORTFOLIO',
              style: TextStyle(
                color: AppColors.peach,
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              )),
          Text('Staff',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              )),
        ]),
        const SizedBox(width: 16),
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
          onTap: onProfile,
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

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb();

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Text('LEADERSHIP',
          style: TextStyle(
            color: AppColors.orange,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          )),
      const SizedBox(width: 8),
      Container(
        width: 4,
        height: 4,
        decoration: const BoxDecoration(
            color: AppColors.muted, shape: BoxShape.circle),
      ),
      const SizedBox(width: 8),
      const Text('Private Office',
          style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
      const Spacer(),
      const Text('Q2 Directory',
          style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
    ]);
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget trailing;
  const _SectionTitle({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            )),
        trailing,
      ],
    );
  }
}

// ---------------- CEO card (responsive) ----------------

class _CeoCard extends StatelessWidget {
  const _CeoCard();

  static const _cardColor = Color(0xFF242427);
  static const _name = 'Lord Alistair Sterling';

  Widget _badge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Text('\$1.8B+ Closed',
        style: TextStyle(
          color: AppColors.peach,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        )),
  );

  Widget _details(BuildContext context, EdgeInsets padding) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 6,
            children: [
              const Text(_name,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  )),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('FRICS',
                    style: TextStyle(
                      color: AppColors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Chief Executive Officer & Founder',
              style: TextStyle(
                color: AppColors.orange,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 12),
          const Text(
            'Over 22 years orchestrating trophy acquisitions across Mayfair, Palm Jumeirah, and Manhattan for ultra-prime single-family offices.',
            style:
            TextStyle(color: AppColors.muted, fontSize: 13.5, height: 1.5),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF18181A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(children: [
              Expanded(child: _Stat('22', 'y', 'TENURE')),
              _StatDivider(),
              Expanded(child: _Stat('94', '%', 'OFF-MARKET', highlight: true)),
              _StatDivider(),
              Expanded(child: _Stat('<48', 'h', 'RESPONSE')),
            ]),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: _ActionBtn(
                icon: Icons.call_outlined,
                label: 'Call',
                onTap: () => showToast(context, 'Calling $_name...'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionBtn(
                icon: Icons.chat_outlined,
                label: 'WhatsApp',
                onTap: () => showToast(context, 'Opening WhatsApp...'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionBtn(
                icon: Icons.calendar_today_outlined,
                label: 'Schedule',
                filled: true,
                onTap: () => _schedule(context, _name),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final wide = box.maxWidth >= 700;
      final deco = BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      );

      // Mobile: photo upar, details neeche
      if (!wide) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: deco,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              height: 290,
              child: Stack(fit: StackFit.expand, children: [
                StaffAvatar(
                  name: _name,
                  image: 'assets/images/staff/ceo.jpg',
                  width: double.infinity,
                  height: 290,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, _cardColor],
                      stops: [0.55, 1],
                    ),
                  ),
                ),
                Positioned(top: 16, right: 16, child: _badge()),
              ]),
            ),
            _details(context, const EdgeInsets.fromLTRB(20, 0, 20, 20)),
          ]),
        );
      }

      // Wide: photo left, details right
      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: deco,
        child: SizedBox(
          height: 420,
          child: Row(children: [
            Expanded(
              flex: 4,
              child: Stack(fit: StackFit.expand, children: [
                StaffAvatar(
                  name: _name,
                  image: 'assets/images/staff/ceo.jpg',
                  width: double.infinity,
                  height: 420,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.transparent, _cardColor],
                      stops: [0.6, 1],
                    ),
                  ),
                ),
                Positioned(top: 16, left: 16, child: _badge()),
              ]),
            ),
            Expanded(
              flex: 6,
              child: Center(
                child: SingleChildScrollView(
                  child: _details(context, const EdgeInsets.all(28)),
                ),
              ),
            ),
          ]),
        ),
      );
    });
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String unit;
  final String label;
  final bool highlight;
  const _Stat(this.value, this.unit, this.label, {this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text.rich(TextSpan(children: [
        TextSpan(
          text: value,
          style: TextStyle(
            color: highlight ? AppColors.peach : AppColors.text,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        TextSpan(
          text: unit,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ])),
      const SizedBox(height: 4),
      Text(label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          )),
    ]);
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 34, color: AppColors.border);
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final double height;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
    this.height = 46,
  });

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.black : AppColors.text;
    return PressScale(
      scale: 0.96,
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: filled ? const Color(0xFFFFC46B) : const Color(0xFF18181A),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 17, color: fg),
              const SizedBox(width: 7),
              Text(label,
                  style: TextStyle(
                    color: fg,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  )),
            ]),
          ),
        ),
      ),
    );
  }
}

// ---------------- Executive directors (responsive) ----------------

class _DirectorList extends StatelessWidget {
  const _DirectorList();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      // Wide screen: teeno directors ek row mein
      if (c.maxWidth >= 700) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 250,
            child: Row(children: [
              for (var i = 0; i < _directors.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: _DirectorCard(d: _directors[i])),
              ],
            ]),
          ),
        );
      }

      // Mobile: horizontal swipe list
      final cardW = c.maxWidth * 0.8;
      return SizedBox(
        height: 250,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
          ),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _directors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) =>
                SizedBox(width: cardW, child: _DirectorCard(d: _directors[i])),
          ),
        ),
      );
    });
  }
}

class _DirectorCard extends StatelessWidget {
  final _Director d;
  const _DirectorCard({required this.d});

  Widget _row(String label, String value, {bool highlight = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          )),
      const SizedBox(width: 8),
      Flexible(
        child: Text(value,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: highlight ? AppColors.peach : AppColors.text,
              fontSize: 13,
              fontWeight: highlight ? FontWeight.w800 : FontWeight.w500,
            )),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF242427),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          StaffAvatar(
              name: d.name, image: d.image, width: 52, height: 52, radius: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(d.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  )),
              const SizedBox(height: 2),
              Text(d.role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  )),
              const SizedBox(height: 2),
              Text(d.creds,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                  const TextStyle(color: AppColors.muted, fontSize: 12)),
            ]),
          ),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF18181A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: [
            _row('Focus', d.focus),
            const SizedBox(height: 10),
            _row('Mandates', d.portfolio, highlight: true),
          ]),
        ),
        const Spacer(),
        Row(children: [
          Expanded(
            child: _ActionBtn(
              icon: Icons.folder_shared_outlined,
              label: 'Dossier',
              height: 44,
              onTap: () => showToast(context, 'Opening dossier: ${d.name}'),
            ),
          ),
          const SizedBox(width: 10),
          PressScale(
            scale: 0.92,
            onTap: () => showToast(context, 'Opening chat with ${d.name}'),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF18181A),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.chat_outlined,
                  size: 18, color: AppColors.text),
            ),
          ),
        ]),
      ]),
    );
  }
}

// ---------------- Senior advisors (responsive) ----------------

class _AdvisorGrid extends StatelessWidget {
  const _AdvisorGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth < 700) {
        return Column(children: [
          for (final a in _advisors) _AdvisorCard(a: a),
        ]);
      }
      final w = (c.maxWidth - 12) / 2;
      return Wrap(spacing: 12, children: [
        for (final a in _advisors)
          SizedBox(width: w, child: _AdvisorCard(a: a)),
      ]);
    });
  }
}

class _AdvisorCard extends StatelessWidget {
  final _Advisor a;
  const _AdvisorCard({required this.a});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF242427),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          StaffAvatar(
              name: a.name, image: a.image, width: 58, height: 58, radius: 14),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  )),
              const SizedBox(height: 3),
              Text(a.role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.orange,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: 3),
              Text(a.mandates,
                  style:
                  const TextStyle(color: AppColors.muted, fontSize: 12.5)),
            ]),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF18181A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.star_rounded, size: 14, color: AppColors.peach),
              const SizedBox(width: 3),
              Text(a.rating,
                  style: const TextStyle(
                    color: AppColors.peach,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  )),
            ]),
          ),
        ]),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(a.languages,
              style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(a.region,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _ActionBtn(
              icon: Icons.call_outlined,
              label: 'Call',
              height: 44,
              onTap: () => showToast(context, 'Calling ${a.name}...'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionBtn(
              icon: Icons.chat_outlined,
              label: 'Chat',
              height: 44,
              onTap: () => showToast(context, 'Opening chat with ${a.name}'),
            ),
          ),
        ]),
      ]),
    );
  }
}

// ---------------- Bottom nav (Hub + Profile, sirf mobile/tablet) ----------------

class _StaffNav extends StatelessWidget {
  final VoidCallback onHub;
  final VoidCallback onProfile;
  const _StaffNav({required this.onHub, required this.onProfile});

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
        _item(Icons.maps_home_work_outlined, 'HUB', onHub),
        _item(Icons.manage_accounts_outlined, 'PROFILE', onProfile),
      ]),
    );
  }
}