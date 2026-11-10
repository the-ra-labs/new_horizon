import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/helpers.dart';
import '../widgets/fade_slide.dart';
import '../widgets/press_scale.dart';
import '../widgets/property_card.dart';
import 'staff_screen.dart';
import 'browse_screens.dart';
import 'vip_viewing_screen.dart';
import 'roi_engine_screen.dart';
class HubTab extends StatefulWidget {
  final VoidCallback onProfile;
  const HubTab({super.key, required this.onProfile});

  @override
  State<HubTab> createState() => _HubTabState();
}

class _HubTabState extends State<HubTab> {
  final _pc = PageController(viewportFraction: 0.9);
  final Set<int> _saved = {};
  int _page = 0;

  static const _properties = [
    Property(
      location: 'LAKE COMO, IT',
      price: '\$18,400,000',
      title: 'Villa Solaria Waterfront',
      description:
      'Private peninsula docking, subterranean wine cellar, infinity edge pool.',
      beds: 6,
      baths: 8,
      sqft: '11,250',
      image: 'assets/images/estates/como.jpg',
    ),
    Property(
      location: 'BEL-AIR, US',
      price: '\$24,900,000',
      title: 'The Hillcrest Residence',
      description:
      'Helipad access, panoramic canyon views and a private screening room.',
      beds: 7,
      baths: 9,
      sqft: '14,800',
      image: 'assets/images/estates/belair.jpg',
    ),
    Property(
      location: 'MONACO, MC',
      price: '\$31,200,000',
      title: 'Penthouse Monte Carlo',
      description:
      'Triplex sky residence with private elevator and wraparound terraces.',
      beds: 5,
      baths: 6,
      sqft: '8,900',
      image: 'assets/images/estates/monaco.jpg',
    ),
  ];

  static const _portals = [
    (Icons.support_agent_rounded, 'Advisory Staff', 'Assigned brokers'),
    (Icons.landscape_rounded, 'Land & Plots', 'Development tracts'),
    (Icons.business_rounded, 'Commercial', 'Towers & yields'),
    (Icons.home_work_rounded, 'Houses', 'Homes for sale & rent'),
    (Icons.event_available_rounded, 'VIP Viewing', 'Private air & ground'),
    (Icons.calculate_rounded, 'ROI Engine', 'Yield & debt models'),
  ];

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final target = (_page + delta).clamp(0, _properties.length - 1);
    if (_pc.hasClients) {
      _pc.animateToPage(target,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic);
    }
  }

  void _toggleSave(int i) {
    final adding = !_saved.contains(i);
    setState(() => adding ? _saved.add(i) : _saved.remove(i));
    showToast(context, adding ? 'Added to Saved' : 'Removed from Saved');
  }

  void _openPortal(String title) {
    final Widget? page = switch (title) {
      'Advisory Staff' => StaffScreen(onProfile: widget.onProfile),
      'Land & Plots' => const LandPlotsScreen(),
      'Commercial' => const CommercialScreen(),
      'Houses' => const HousesScreen(),
      'VIP Viewing' => const VipViewingScreen(),
      'ROI Engine' => const RoiEngineScreen(),
      _ => null,
    };
    if (page == null) {
      showToast(context, '$title opening soon');
    } else {
      Navigator.of(context).push(fadeRoute(page));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final w = box.maxWidth;
      final wide = w >= 700;
      final hPad = w >= 1000 ? 32.0 : 20.0;
      Widget pad(Widget c) => Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad), child: c);

      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          FadeSlide(child: _header(hPad)),
          const SizedBox(height: 8),
          FadeSlide(delayMs: 100, child: pad(_WelcomeCard(wide: wide))),
          const SizedBox(height: 28),
          FadeSlide(
            delayMs: 200,
            child: Column(children: [
              pad(const _SectionTitle(
                title: 'Priority Portals',
                trailing: Text('Direct Access',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    )),
              )),
              const SizedBox(height: 14),
              pad(_portalGrid()),
            ]),
          ),
          const SizedBox(height: 30),
          FadeSlide(
            delayMs: 300,
            child: Column(children: [
              pad(_SectionTitle(
                title: 'Exclusive Mandates',
                trailing: wide
                    ? Text('${_properties.length} Listings',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ))
                    : Row(children: [
                  _ArrowBtn(
                      icon: Icons.chevron_left_rounded,
                      enabled: _page > 0,
                      onTap: () => _go(-1)),
                  const SizedBox(width: 8),
                  _ArrowBtn(
                      icon: Icons.chevron_right_rounded,
                      enabled: _page < _properties.length - 1,
                      onTap: () => _go(1)),
                ]),
              )),
              const SizedBox(height: 14),
              wide ? pad(_mandateGrid()) : _carousel(),
            ]),
          ),
        ]),
      );
    });
  }

  Widget _carousel() {
    return SizedBox(
      height: 440,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
        ),
        child: PageView.builder(
          controller: _pc,
          padEnds: false,
          itemCount: _properties.length,
          onPageChanged: (p) => setState(() => _page = p),
          itemBuilder: (_, i) => Padding(
            padding: EdgeInsets.only(left: i == 0 ? 15 : 0),
            child: PropertyCard(
              property: _properties[i],
              index: i,
              saved: _saved.contains(i),
              onSave: () => _toggleSave(i),
            ),
          ),
        ),
      ),
    );
  }

  Widget _mandateGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _properties.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 440,
        mainAxisExtent: 440,
        crossAxisSpacing: 10,
        mainAxisSpacing: 14,
      ),
      itemBuilder: (_, i) => PropertyCard(
        property: _properties[i],
        index: i,
        saved: _saved.contains(i),
        onSave: () => _toggleSave(i),
      ),
    );
  }

  Widget _header(double hPad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 12),
      child: Row(children: [
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
        const Spacer(),
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
        const SizedBox(width: 16),
        PressScale(
          onTap: widget.onProfile,
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

  Widget _portalGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _portals.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 230,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 130,
      ),
      itemBuilder: (_, i) {
        final p = _portals[i];
        return _PortalCard(
          icon: p.$1,
          title: p.$2,
          subtitle: p.$3,
          onTap: () => _openPortal(p.$2),
        );
      },
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final bool wide;
  const _WelcomeCard({required this.wide});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(wide ? 28 : 20),
        decoration: const BoxDecoration(color: Color(0xFF242427)),
        child: Stack(children: [
          Positioned(
            right: -60,
            bottom: -60,
            child: Container(
              width: wide ? 320 : 220,
              height: wide ? 320 : 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.orange.withValues(alpha: 0.28),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          FractionallySizedBox(
            widthFactor: wide ? 0.5 : 0.68,
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.workspace_premium_rounded,
                        size: 13, color: AppColors.orange),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text('PRIVATE CLIENT TIER',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          )),
                    ),
                  ]),
                ),
                const SizedBox(height: 14),
                Text(
                    wide
                        ? 'Welcome,\nRespected Investor'
                        : 'Welcome,\nRespected\nInvestor',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: wide ? 38 : 30,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                    )),
                const SizedBox(height: 12),
                const Text(
                  'Sovereign allocations & bespoke architectural portfolios curated for your legacy.',
                  style: TextStyle(
                      color: AppColors.muted, fontSize: 13, height: 1.45),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget trailing;
  const _SectionTitle({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 4,
        height: 18,
        decoration: BoxDecoration(
            color: AppColors.orange, borderRadius: BorderRadius.circular(2)),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(title,
            style: const TextStyle(
                color: AppColors.text,
                fontSize: 17,
                fontWeight: FontWeight.w800)),
      ),
      trailing,
    ]);
  }
}

class _PortalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _PortalCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressScale(
      scale: 0.96,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1F),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: const Color(0xFF2A2A2D),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.orange, size: 20),
          ),
          const Spacer(),
          Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        ]),
      ),
    );
  }
}

class _ArrowBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _ArrowBtn(
      {required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1 : 0.35,
      child: PressScale(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
              color: Color(0xFF2A2A2D), shape: BoxShape.circle),
          child: Icon(icon, size: 20, color: AppColors.text),
        ),
      ),
    );
  }
}