import 'package:flutter/material.dart';
import '../data/listings.dart';
import '../data/staff_data.dart';
import '../data/stores.dart';
import '../theme/app_colors.dart';
import '../utils/helpers.dart';
import '../utils/pickers.dart';
import '../widgets/fade_slide.dart';
import '../widgets/press_scale.dart';
import '../widgets/staff_ui.dart';
import 'client_preview.dart';
import 'listing_editor_screen.dart';
import 'pipeline_tab.dart';
import 'team_tab.dart';

class DashboardTab extends StatelessWidget {
  final ValueChanged<int> onGoTab;
  const DashboardTab({super.key, required this.onGoTab});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        ListingStore.revision,
        LeadStore.items,
        ViewingStore.all,
        StaffStore.members,
        ActivityStore.items,
      ]),
      builder: (context, _) => _content(context),
    );
  }

  Widget _content(BuildContext context) {
    final me = Session.staff!;
    final all = me.role.seeAll;
    final leads =
    LeadStore.items.value.where((l) => all || l.assignedTo == me.id).toList();
    final views =
    ViewingStore.all.value.where((v) => all || v.assignedTo == me.id).toList();
    final openLeads = leads
        .where((l) => l.status != LeadStatus.won && l.status != LeadStatus.lost)
        .length;
    final won = leads.where((l) => l.status == LeadStatus.won).length;
    final pendingViews = views.where((v) => v.status == 'Pending').length;
    final available = allListings.where((l) => l.status == 'Available').toList();
    final inventory = available
        .where((l) => l.offer == Offer.sale)
        .fold<int>(0, (s, l) => s + l.price);
    final pendingStaff = me.role.approveStaff ? StaffStore.pending.length : 0;
    final unassigned = me.role.assignWork
        ? leads
        .where((l) => l.assignedTo == null && l.status == LeadStatus.fresh)
        .length
        : 0;

    final kpis = <(String, String, String, IconData, Color)>[
      ('Active Listings', '${available.length}', 'of ${allListings.length} total',
      Icons.home_work_rounded, AppColors.orange),
      ('Inventory Value', fmtPkr(inventory), 'Available for sale',
      Icons.account_balance_rounded, AppColors.success),
      ('Open Leads', '$openLeads', '${leads.length} total',
      Icons.person_search_rounded, AppColors.peach),
      ('Won Deals', '$won', 'Closed successfully',
      Icons.emoji_events_rounded, AppColors.success),
      ('Pending Viewings', '$pendingViews', '${views.length} requests',
      Icons.event_available_rounded, const Color(0xFF8AB4F8)),
      ('Team', '${StaffStore.approved.length}', 'Active staff',
      Icons.groups_rounded, AppColors.orange),
    ];

    final attention = <(IconData, String, VoidCallback)>[
      if (pendingStaff > 0)
        (Icons.how_to_reg_rounded,
        '$pendingStaff staff request${pendingStaff == 1 ? '' : 's'} awaiting your approval',
            () => onGoTab(3)),
      if (unassigned > 0)
        (Icons.person_add_alt_1_rounded,
        '$unassigned new lead${unassigned == 1 ? '' : 's'} not assigned yet',
            () => onGoTab(2)),
      if (pendingViews > 0)
        (Icons.event_busy_rounded,
        '$pendingViews viewing request${pendingViews == 1 ? '' : 's'} to confirm',
            () => onGoTab(2)),
    ];

    final recent = [...leads]..sort((a, b) => b.created.compareTo(a.created));

    final h = DateTime.now().hour;
    final greet = h < 12
        ? 'Good morning'
        : (h < 17 ? 'Good afternoon' : 'Good evening');

    return LayoutBuilder(builder: (context, box) {
      final wide = box.maxWidth >= 900;
      final cols = wide ? 3 : 2;
      final cardW = (box.maxWidth - 40 - 12 * (cols - 1)) / cols;

      final left = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _attention(attention),
        const SizedBox(height: 20),
        _recentLeads(recent.take(4).toList()),
      ]);
      final right = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _inventoryBars(),
        const SizedBox(height: 20),
        _activity(),
      ]);

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          FadeSlide(child: _welcome(greet, me)),
          const SizedBox(height: 14),
          FadeSlide(delayMs: 60, child: _quick(context, me)),
          const SizedBox(height: 18),
          FadeSlide(
            delayMs: 120,
            child: Wrap(spacing: 12, runSpacing: 12, children: [
              for (final k in kpis)
                SizedBox(
                  width: cardW,
                  child: StatCard(
                      icon: k.$4,
                      label: k.$1,
                      value: k.$2,
                      hint: k.$3,
                      accent: k.$5),
                ),
            ]),
          ),
          const SizedBox(height: 22),
          FadeSlide(
            delayMs: 200,
            child: wide
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: left),
              const SizedBox(width: 20),
              Expanded(child: right),
            ])
                : Column(children: [left, const SizedBox(height: 20), right]),
          ),
        ]),
      );
    });
  }

  Widget _welcome(String greet, StaffMember me) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        color: const Color(0xFF242427),
        child: Stack(children: [
          Positioned(
            right: -50,
            top: -50,
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
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            RoleBadge(me.role),
            const SizedBox(height: 12),
            Text(greet,
                style: const TextStyle(color: AppColors.muted, fontSize: 13)),
            const SizedBox(height: 2),
            Text(me.name,
                style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 24,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('${me.title.isEmpty ? me.role.label : me.title} • ${fmtDate(DateTime.now())}',
                style: const TextStyle(color: AppColors.peach, fontSize: 12.5)),
          ]),
        ]),
      ),
    );
  }

  Widget _quick(BuildContext context, StaffMember me) {
    Widget q(IconData icon, String label, VoidCallback onTap) => PressScale(
      scale: 0.95,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 17, color: AppColors.orange),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ]),
      ),
    );

    return Wrap(spacing: 10, runSpacing: 10, children: [
      q(Icons.add_home_work_rounded, 'Add Listing',
              () => Navigator.of(context).push(fadeRoute(const ListingEditorScreen()))),
      q(Icons.person_add_alt_1_rounded, 'Add Lead', () => showLeadForm(context)),
      q(Icons.event_available_rounded, 'New Viewing',
              () => showViewingForm(context)),
      if (me.role.manageTeam)
        q(Icons.badge_outlined, 'Add Staff', () => showStaffForm(context)),
      q(Icons.visibility_outlined, 'Client View', () => openClientView(context)),
    ]);
  }

  Widget _attention(List<(IconData, String, VoidCallback)> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader('Needs Attention'),
      const SizedBox(height: 12),
      Panel(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: items.isEmpty
            ? const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Row(children: [
            Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 20),
            SizedBox(width: 10),
            Text("You're all caught up",
                style: TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ]),
        )
            : Column(children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(color: AppColors.border, height: 1),
            PressScale(
              scale: 0.98,
              onTap: items[i].$3,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: Row(children: [
                  Icon(items[i].$1, size: 20, color: AppColors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(items[i].$2,
                        style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600)),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.muted),
                ]),
              ),
            ),
          ],
        ]),
      ),
    ]);
  }

  Widget _recentLeads(List<Lead> leads) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader('Recent Leads',
          trailing: PressScale(
            scale: 0.92,
            onTap: () => onGoTab(2),
            child: const Text('View all',
                style: TextStyle(
                    color: AppColors.peach,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800)),
          )),
      const SizedBox(height: 12),
      if (leads.isEmpty)
        const Panel(
            child: Text('No leads yet.',
                style: TextStyle(color: AppColors.muted, fontSize: 13)))
      else
        for (final l in leads)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Panel(
              padding: const EdgeInsets.all(12),
              onTap: () => onGoTab(2),
              child: Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: l.status.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Text(l.name[0],
                      style: TextStyle(
                          color: l.status.color,
                          fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800)),
                        Text('${fmtPkr(l.budget)} • ${ago(l.created)}',
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 12)),
                      ]),
                ),
                Pill(l.status.label, l.status.color),
              ]),
            ),
          ),
    ]);
  }

  Widget _inventoryBars() {
    final counts = {
      for (final k in ListingKind.values)
        k: allListings.where((l) => l.kind == k).length,
    };
    final maxV = counts.values.fold<int>(1, (m, v) => v > m ? v : m);
    const labels = {
      ListingKind.plot: 'Plots',
      ListingKind.building: 'Buildings',
      ListingKind.plaza: 'Plazas',
      ListingKind.shop: 'Shops',
      ListingKind.house: 'Houses',
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader('Inventory'),
      const SizedBox(height: 12),
      Panel(
        child: Column(children: [
          for (final k in ListingKind.values)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(children: [
                SizedBox(
                  width: 78,
                  child: Text(labels[k]!,
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 13)),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Stack(children: [
                      Container(height: 10, color: AppColors.field),
                      FractionallySizedBox(
                        widthFactor: counts[k]! / maxV,
                        child: Container(
                            height: 10,
                            decoration: const BoxDecoration(
                                gradient: AppColors.gradient)),
                      ),
                    ]),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text('${counts[k]}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800)),
                ),
              ]),
            ),
        ]),
      ),
    ]);
  }

  Widget _activity() {
    final items = ActivityStore.items.value.take(6).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader('Recent Activity'),
      const SizedBox(height: 12),
      Panel(
        child: Column(children: [
          for (final a in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppColors.orange, shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(a.$2,
                      style: const TextStyle(
                          color: AppColors.text, fontSize: 13, height: 1.35)),
                ),
                const SizedBox(width: 8),
                Text(ago(a.$1),
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 11.5)),
              ]),
            ),
        ]),
      ),
    ]);
  }
}