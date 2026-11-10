import 'package:flutter/material.dart';
import '../data/listings.dart';
import '../data/stores.dart';
import '../theme/app_colors.dart';
import '../utils/helpers.dart';
import '../widgets/fade_slide.dart';
import '../widgets/listing_card.dart';
import '../widgets/press_scale.dart';
import 'listing_detail_screen.dart';

class ProfileTab extends StatefulWidget {
  final VoidCallback onLogout;
  const ProfileTab({super.key, required this.onLogout});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _notif = true;
  bool _bio = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            FadeSlide(child: _header()),
            const SizedBox(height: 14),
            FadeSlide(delayMs: 80, child: _stats()),
            const SizedBox(height: 24),
            FadeSlide(delayMs: 160, child: _saved()),
            const SizedBox(height: 24),
            FadeSlide(delayMs: 240, child: _settings()),
            const SizedBox(height: 24),
            FadeSlide(
              delayMs: 320,
              child: PressScale(
                onTap: widget.onLogout,
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
  }

  Widget _box(Widget child) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF1C1C1F),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
    ),
    child: child,
  );

  Widget _header() {
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
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                gradient: AppColors.gradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.orange.withValues(alpha: 0.35),
                      blurRadius: 24),
                ],
              ),
              child: const Icon(Icons.person_rounded,
                  color: Colors.black, size: 38),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Respected Investor',
                        style: TextStyle(
                            color: AppColors.text,
                            fontSize: 20,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    const Text('investor@horizon.ae',
                        style:
                        TextStyle(color: AppColors.muted, fontSize: 12.5)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.workspace_premium_rounded,
                            size: 13, color: AppColors.orange),
                        SizedBox(width: 6),
                        Text('PRIVATE CLIENT TIER',
                            style: TextStyle(
                                color: AppColors.orange,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1)),
                      ]),
                    ),
                  ]),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _stats() {
    Widget stat(Widget value, String label) => Expanded(
      child: _box(Column(children: [
        value,
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                color: AppColors.muted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1)),
      ])),
    );
    const style = TextStyle(
        color: AppColors.peach, fontSize: 24, fontWeight: FontWeight.w800);
    return Row(children: [
      stat(
        ValueListenableBuilder<Set<String>>(
          valueListenable: SavedStore.ids,
          builder: (_, s, __) => Text('${s.length}', style: style),
        ),
        'SAVED',
      ),
      const SizedBox(width: 12),
      stat(
        ValueListenableBuilder<List<ViewingRequest>>(
          valueListenable: ViewingStore.items,
          builder: (_, s, __) => Text('${s.length}', style: style),
        ),
        'VIEWINGS',
      ),
    ]);
  }

  Widget _saved() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Saved Listings',
          style: TextStyle(
              color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      ValueListenableBuilder<Set<String>>(
        valueListenable: SavedStore.ids,
        builder: (_, ids, __) {
          final items = allListings.where((l) => ids.contains(l.id)).toList();
          if (items.isEmpty) {
            return _box(const Text(
              'Bookmark listings to keep them here for quick access.',
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ));
          }
          return Column(children: [
            for (final l in items.take(6))
              PressScale(
                scale: 0.98,
                onTap: () => Navigator.of(context)
                    .push(fadeRoute(ListingDetailScreen(l: l))),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF242427),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: kindColors(l)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(kindIcon(l),
                          color: AppColors.orange, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 2),
                            Text('${l.location} • ${l.priceText}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: AppColors.muted, fontSize: 12)),
                          ]),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.muted),
                  ]),
                ),
              ),
          ]);
        },
      ),
    ]);
  }

  Widget _settings() {
    Widget navRow(IconData icon, String label) => PressScale(
      scale: 0.98,
      onTap: () => showToast(context, '$label coming soon'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Icon(icon, size: 20, color: AppColors.orange),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600)),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ]),
      ),
    );

    Widget switchRow(
        IconData icon, String label, bool v, ValueChanged<bool> onChanged) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            Icon(icon, size: 20, color: AppColors.orange),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600)),
            ),
            Switch(
              value: v,
              onChanged: onChanged,
              thumbColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? Colors.black
                  : AppColors.muted),
              trackColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? AppColors.orange
                  : AppColors.field),
              trackOutlineColor:
              const WidgetStatePropertyAll(Colors.transparent),
            ),
          ]),
        );

    const divider = Divider(color: AppColors.border, height: 1);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Settings',
          style: TextStyle(
              color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      _box(Column(children: [
        switchRow(Icons.notifications_none_rounded, 'Notifications', _notif,
                (v) => setState(() => _notif = v)),
        divider,
        switchRow(Icons.fingerprint_rounded, 'Biometric login', _bio,
                (v) => setState(() => _bio = v)),
        divider,
        navRow(Icons.lock_outline_rounded, 'Security'),
        divider,
        navRow(Icons.language_rounded, 'Language'),
        divider,
        navRow(Icons.policy_outlined, 'Privacy & Charter'),
        divider,
        navRow(Icons.support_agent_rounded, 'Help & Support'),
      ])),
    ]);
  }
}