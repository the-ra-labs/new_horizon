import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/listings.dart';
import '../data/staff_data.dart';
import '../data/stores.dart';
import '../theme/app_colors.dart';
import '../utils/helpers.dart';
import '../utils/pickers.dart';
import '../widgets/action_button.dart';
import '../widgets/animated_tab_switch.dart';
import '../widgets/auth_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/press_scale.dart';
import '../widgets/search_bar_field.dart';
import '../widgets/staff_avatar.dart';
import '../widgets/staff_ui.dart';

// ======================================================= Shared helpers

Future<String?> pickStaff(BuildContext context, {String? current}) {
  return showFormSheet<String>(
    context,
    title: 'Assign to',
    child: Builder(
      builder: (ctx) => Column(children: [
        for (final m in StaffStore.approved)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Panel(
              padding: const EdgeInsets.all(12),
              border: m.id == current ? AppColors.orange : null,
              onTap: () => Navigator.of(ctx).pop(m.id),
              child: Row(children: [
                StaffAvatar(
                    name: m.name, width: 42, height: 42, radius: 21),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(m.name,
                      style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800)),
                ),
                RoleBadge(m.role),
              ]),
            ),
          ),
      ]),
    ),
  );
}

String _staffName(String? id) => StaffStore.byId(id)?.name ?? 'Unassigned';

Widget _info(IconData icon, String text) => Padding(
  padding: const EdgeInsets.only(bottom: 6),
  child: Row(children: [
    Icon(icon, size: 16, color: AppColors.orange),
    const SizedBox(width: 10),
    Expanded(
      child: Text(text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.text, fontSize: 13)),
    ),
  ]),
);

// ======================================================= Pipeline tab

class PipelineTab extends StatefulWidget {
  const PipelineTab({super.key});

  @override
  State<PipelineTab> createState() => _PipelineTabState();
}

class _PipelineTabState extends State<PipelineTab> {
  bool _leads = true;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: AnimatedTabSwitch(
          isLeft: _leads,
          left: 'Leads',
          right: 'Viewings',
          onChanged: (v) => setState(() => _leads = v),
        ),
      ),
      Expanded(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _leads
              ? const _LeadsView(key: ValueKey('leads'))
              : const _ViewingsView(key: ValueKey('views')),
        ),
      ),
    ]);
  }
}

// ======================================================= Leads

class _LeadsView extends StatefulWidget {
  const _LeadsView({super.key});

  @override
  State<_LeadsView> createState() => _LeadsViewState();
}

class _LeadsViewState extends State<_LeadsView> {
  static const _sorts = ['Newest', 'Budget: High to Low', 'Budget: Low to High'];
  final _qc = TextEditingController();
  String _q = '';
  String _filter = 'All';
  String _sort = _sorts.first;

  @override
  void dispose() {
    _qc.dispose();
    super.dispose();
  }

  Future<void> _delete(Lead l) async {
    final ok = await confirmDialog(context,
        title: 'Delete lead?',
        message: '${l.name} will be removed from the pipeline.',
        confirmLabel: 'Delete',
        danger: true);
    if (!ok || !mounted) return;
    LeadStore.remove(l.id);
    ActivityStore.log(Session.staff!.name, 'deleted lead ${l.id}');
    showToast(context, 'Lead deleted');
  }

  Future<void> _assign(Lead l) async {
    final id = await pickStaff(context, current: l.assignedTo);
    if (id == null || !mounted) return;
    l.assignedTo = id;
    LeadStore.notify();
    ActivityStore.log(
        Session.staff!.name, 'assigned ${l.name} to ${_staffName(id)}');
    showToast(context, 'Assigned to ${_staffName(id)}');
  }

  @override
  Widget build(BuildContext context) {
    final me = Session.staff!;
    return ValueListenableBuilder<List<Lead>>(
      valueListenable: LeadStore.items,
      builder: (context, all, _) {
        final base =
        all.where((l) => me.role.seeAll || l.assignedTo == me.id).toList();
        final labels = [
          'All (${base.length})',
          for (final s in LeadStatus.values)
            '${s.label} (${base.where((l) => l.status == s).length})',
        ];
        final selected = labels.firstWhere(
                (l) => l.startsWith('$_filter ('),
            orElse: () => labels.first);

        var items = base
            .where((l) => _filter == 'All' || l.status.label == _filter)
            .toList();
        final tokens = _q
            .toLowerCase()
            .split(RegExp(r'\s+'))
            .where((t) => t.isNotEmpty)
            .toList();
        if (tokens.isNotEmpty) {
          items = items.where((l) {
            final hay =
            '${l.name} ${l.phone} ${l.email} ${l.source} ${l.notes} ${l.status.label} ${_staffName(l.assignedTo)}'
                .toLowerCase();
            return tokens.every(hay.contains);
          }).toList();
        }
        switch (_sort) {
          case 'Budget: High to Low':
            items.sort((a, b) => b.budget.compareTo(a.budget));
          case 'Budget: Low to High':
            items.sort((a, b) => a.budget.compareTo(b.budget));
          default:
            items.sort((a, b) => b.created.compareTo(a.created));
        }

        return LayoutBuilder(builder: (context, box) {
          final cols = box.maxWidth >= 900 ? 2 : 1;
          final w = (box.maxWidth - 40 - 12 * (cols - 1)) / cols;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Expanded(
                  child: ListingSearchBar(
                    controller: _qc,
                    hint: 'Search name, phone, source...',
                    sort: _sort,
                    sortOptions: _sorts,
                    onChanged: (v) => setState(() => _q = v),
                    onSort: (v) => setState(() => _sort = v),
                  ),
                ),
                const SizedBox(width: 10),
                PressScale(
                  scale: 0.92,
                  onTap: () => showLeadForm(context),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.person_add_alt_1_rounded,
                        color: Colors.black, size: 24),
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              ChipSelect(
                options: labels,
                selected: selected,
                scroll: true,
                onChanged: (v) => setState(() => _filter = v.split(' (').first),
              ),
              const SizedBox(height: 16),
              if (items.isEmpty)
                const EmptyState(
                  icon: Icons.person_search_rounded,
                  title: 'No leads found',
                  message: 'Try another filter or add a new lead.',
                )
              else
                Wrap(spacing: 12, runSpacing: 12, children: [
                  for (final l in items)
                    SizedBox(
                      width: w,
                      child: _LeadCard(
                        lead: l,
                        canAssign: me.role.assignWork,
                        canDelete: me.role.deleteLeads,
                        onEdit: () => showLeadForm(context, lead: l),
                        onAssign: () => _assign(l),
                        onDelete: () => _delete(l),
                      ),
                    ),
                ]),
            ]),
          );
        });
      },
    );
  }
}

class _LeadCard extends StatelessWidget {
  final Lead lead;
  final bool canAssign;
  final bool canDelete;
  final VoidCallback onEdit;
  final VoidCallback onAssign;
  final VoidCallback onDelete;
  const _LeadCard({
    required this.lead,
    required this.canAssign,
    required this.canDelete,
    required this.onEdit,
    required this.onAssign,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l = lead;
    final listing =
        allListings.where((x) => x.id == l.listingId).firstOrNull;
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: l.status.color.withValues(alpha: 0.15),
                shape: BoxShape.circle),
            child: Text(l.name[0].toUpperCase(),
                style: TextStyle(
                    color: l.status.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800)),
              Text('${l.source} • ${ago(l.created)}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ]),
          ),
          PopupMenuButton<LeadStatus>(
            color: AppColors.card,
            shape: menuShape,
            tooltip: 'Change status',
            onSelected: (s) {
              l.status = s;
              LeadStore.notify();
              ActivityStore.log(Session.staff!.name,
                  'moved ${l.name} to ${s.label}');
            },
            itemBuilder: (_) => [
              for (final s in LeadStatus.values)
                PopupMenuItem<LeadStatus>(
                  value: s,
                  child: Row(children: [
                    Container(
                        width: 10,
                        height: 10,
                        decoration:
                        BoxDecoration(color: s.color, shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Text(s.label,
                        style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
            ],
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
              decoration: BoxDecoration(
                color: l.status.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(l.status.label.toUpperCase(),
                    style: TextStyle(
                        color: l.status.color,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5)),
                Icon(Icons.arrow_drop_down_rounded,
                    size: 18, color: l.status.color),
              ]),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        _info(Icons.phone_outlined, l.phone),
        if (l.email.isNotEmpty) _info(Icons.mail_outline_rounded, l.email),
        _info(Icons.payments_outlined, 'Budget ${fmtPkr(l.budget)}'),
        if (listing != null)
          _info(Icons.home_work_outlined, '${listing.title} (${listing.id})'),
        _info(Icons.person_outline_rounded,
            'Assigned: ${_staffName(l.assignedTo)}'),
        if (l.notes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 4),
            child: Text(l.notes,
                style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    height: 1.35)),
          ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: ActionBtn(
              icon: Icons.call_outlined,
              label: 'Call',
              height: 42,
              onTap: () => showToast(context, 'Calling ${l.name}...'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ActionBtn(
              icon: Icons.chat_outlined,
              label: 'WhatsApp',
              height: 42,
              onTap: () => showToast(context, 'Opening WhatsApp...'),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            color: AppColors.card,
            shape: menuShape,
            onSelected: (v) {
              switch (v) {
                case 'edit':
                  onEdit();
                case 'assign':
                  onAssign();
                case 'delete':
                  onDelete();
              }
            },
            itemBuilder: (_) => [
              menuItem('edit', Icons.edit_outlined, 'Edit lead'),
              if (canAssign)
                menuItem('assign', Icons.swap_horiz_rounded, 'Assign to...'),
              if (canDelete)
                menuItem('delete', Icons.delete_outline_rounded, 'Delete',
                    danger: true),
            ],
            child: Container(
              width: 44,
              height: 42,
              decoration: BoxDecoration(
                  color: const Color(0xFF18181A),
                  borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.more_horiz_rounded,
                  color: AppColors.text),
            ),
          ),
        ]),
      ]),
    );
  }
}

// ======================================================= Lead form

Future<void> showLeadForm(BuildContext context, {Lead? lead}) {
  return showFormSheet<void>(
    context,
    title: lead == null ? 'Add Lead' : 'Edit Lead',
    child: _LeadForm(lead: lead),
  );
}

class _LeadForm extends StatefulWidget {
  final Lead? lead;
  const _LeadForm({this.lead});

  @override
  State<_LeadForm> createState() => _LeadFormState();
}

class _LeadFormState extends State<_LeadForm> {
  late final _name = TextEditingController(text: widget.lead?.name ?? '');
  late final _phone = TextEditingController(text: widget.lead?.phone ?? '');
  late final _email = TextEditingController(text: widget.lead?.email ?? '');
  late final _budget = TextEditingController(
      text: widget.lead == null ? '' : '${widget.lead!.budget}');
  late final _listing =
  TextEditingController(text: widget.lead?.listingId ?? '');
  late final _notes = TextEditingController(text: widget.lead?.notes ?? '');
  late String _source = widget.lead?.source ?? 'Website';
  late LeadStatus _status = widget.lead?.status ?? LeadStatus.fresh;
  late String? _assigned = widget.lead?.assignedTo ?? Session.staff!.id;
  String? _nameErr, _phoneErr, _emailErr, _budgetErr, _listingErr;

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _budget, _listing, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<bool> _save() async {
    final lid = _listing.text.trim();
    setState(() {
      _nameErr = Validators.required(_name.text, 'Name');
      _phoneErr = Validators.phone(_phone.text);
      _emailErr =
      _email.text.trim().isEmpty ? null : Validators.email(_email.text);
      _budgetErr = (int.tryParse(_budget.text.trim()) ?? 0) <= 0
          ? 'Enter a valid budget'
          : null;
      _listingErr = (lid.isEmpty ||
          allListings.any((l) => l.id.toLowerCase() == lid.toLowerCase()))
          ? null
          : 'Listing ID not found';
    });
    if ([_nameErr, _phoneErr, _emailErr, _budgetErr, _listingErr]
        .any((e) => e != null)) {
      HapticFeedback.mediumImpact();
      return false;
    }
    await Future.delayed(const Duration(milliseconds: 600));
    final listingId = lid.isEmpty
        ? null
        : allListings.firstWhere((l) => l.id.toLowerCase() == lid.toLowerCase()).id;
    final actor = Session.staff!.name;
    final e = widget.lead;
    if (e == null) {
      LeadStore.add(Lead(
        id: LeadStore.nextId(),
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        email: _email.text.trim(),
        notes: _notes.text.trim(),
        source: _source,
        budget: int.parse(_budget.text.trim()),
        listingId: listingId,
        status: _status,
        assignedTo: _assigned,
      ));
      ActivityStore.log(actor, 'added lead ${_name.text.trim()}');
    } else {
      e.name = _name.text.trim();
      e.phone = _phone.text.trim();
      e.email = _email.text.trim();
      e.notes = _notes.text.trim();
      e.source = _source;
      e.budget = int.parse(_budget.text.trim());
      e.listingId = listingId;
      e.status = _status;
      e.assignedTo = _assigned;
      LeadStore.notify();
      ActivityStore.log(actor, 'updated lead ${e.name}');
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final me = Session.staff!;
    final staff = StaffStore.approved;
    final names = ['Unassigned', for (final s in staff) s.name];
    final selectedName = _assigned == null ? 'Unassigned' : _staffName(_assigned);

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AuthField(
        label: 'Full name',
        hint: 'Client name',
        icon: Icons.person_outline_rounded,
        controller: _name,
        errorText: _nameErr,
        onChanged: (_) => setState(() => _nameErr = null),
      ),
      const SizedBox(height: 14),
      AuthField(
        label: 'Phone',
        hint: '+923001234567',
        icon: Icons.phone_outlined,
        controller: _phone,
        keyboardType: TextInputType.phone,
        errorText: _phoneErr,
        onChanged: (_) => setState(() => _phoneErr = null),
      ),
      const SizedBox(height: 14),
      AuthField(
        label: 'Email (optional)',
        hint: 'client@mail.com',
        icon: Icons.mail_outline_rounded,
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        errorText: _emailErr,
        onChanged: (_) => setState(() => _emailErr = null),
      ),
      const SizedBox(height: 14),
      AuthField(
        label: 'Budget (PKR)',
        hint: '25000000',
        icon: Icons.payments_outlined,
        controller: _budget,
        keyboardType: TextInputType.number,
        errorText: _budgetErr,
        onChanged: (_) => setState(() => _budgetErr = null),
      ),
      const SizedBox(height: 14),
      AuthField(
        label: 'Interested listing ID (optional)',
        hint: 'NH-H-1042',
        icon: Icons.home_work_outlined,
        controller: _listing,
        errorText: _listingErr,
        onChanged: (_) => setState(() => _listingErr = null),
      ),
      const SizedBox(height: 16),
      ChipSelect(
        label: 'Source',
        options: const [
          'Website', 'Referral', 'Walk-in', 'WhatsApp', 'Instagram', 'Facebook',
        ],
        selected: _source,
        onChanged: (v) => setState(() => _source = v),
      ),
      const SizedBox(height: 16),
      ChipSelect(
        label: 'Status',
        options: [for (final s in LeadStatus.values) s.label],
        selected: _status.label,
        onChanged: (v) => setState(
                () => _status = LeadStatus.values.firstWhere((s) => s.label == v)),
      ),
      if (me.role.assignWork) ...[
        const SizedBox(height: 16),
        ChipSelect(
          label: 'Assigned to',
          options: names,
          selected: selectedName,
          onChanged: (v) => setState(() {
            _assigned = v == 'Unassigned'
                ? null
                : staff.firstWhere((s) => s.name == v).id;
          }),
        ),
      ],
      const SizedBox(height: 14),
      AuthField(
        label: 'Notes',
        hint: 'Preferences, timing, remarks...',
        icon: Icons.notes_rounded,
        controller: _notes,
      ),
      const SizedBox(height: 22),
      GradientButton(
        label: widget.lead == null ? 'Add Lead' : 'Save Lead',
        icon: Icons.check_rounded,
        onPressed: _save,
        onSuccess: () {
          showToast(context,
              widget.lead == null ? 'Lead added' : 'Lead updated');
          Navigator.of(context).pop();
        },
      ),
    ]);
  }
}

// ======================================================= Viewings

class _ViewingsView extends StatefulWidget {
  const _ViewingsView({super.key});

  @override
  State<_ViewingsView> createState() => _ViewingsViewState();
}

class _ViewingsViewState extends State<_ViewingsView> {
  static const _statuses = ['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled'];
  String _filter = 'All';

  void _set(ViewingRequest v, String s) {
    v.status = s;
    ViewingStore.notifyAll();
    ActivityStore.log(Session.staff!.name, '$s viewing ${v.ref}');
    showToast(context, '${v.ref} marked $s');
  }

  Future<void> _reschedule(ViewingRequest v) async {
    final d = await pickDate(context);
    if (d == null || !mounted) return;
    final t = await pickTime(context);
    if (t == null || !mounted) return;
    v.date = fmtDate(d);
    v.time = t.format(context);
    ViewingStore.notifyAll();
    ActivityStore.log(Session.staff!.name, 'rescheduled ${v.ref}');
    showToast(context, 'Rescheduled to ${v.date}, ${v.time}');
  }

  Future<void> _assign(ViewingRequest v) async {
    final id = await pickStaff(context, current: v.assignedTo);
    if (id == null || !mounted) return;
    v.assignedTo = id;
    ViewingStore.notifyAll();
    ActivityStore.log(
        Session.staff!.name, 'assigned ${v.ref} to ${_staffName(id)}');
    showToast(context, 'Assigned to ${_staffName(id)}');
  }

  @override
  Widget build(BuildContext context) {
    final me = Session.staff!;
    return ValueListenableBuilder<List<ViewingRequest>>(
      valueListenable: ViewingStore.all,
      builder: (context, all, _) {
        final base =
        all.where((v) => me.role.seeAll || v.assignedTo == me.id).toList();
        final labels = [
          for (final s in _statuses)
            s == 'All'
                ? 'All (${base.length})'
                : '$s (${base.where((v) => v.status == s).length})',
        ];
        final selected = labels.firstWhere((l) => l.startsWith('$_filter ('),
            orElse: () => labels.first);
        final items =
        base.where((v) => _filter == 'All' || v.status == _filter).toList();

        return LayoutBuilder(builder: (context, box) {
          final cols = box.maxWidth >= 900 ? 2 : 1;
          final w = (box.maxWidth - 40 - 12 * (cols - 1)) / cols;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Expanded(
                  child: ChipSelect(
                    options: labels,
                    selected: selected,
                    scroll: true,
                    onChanged: (v) => setState(() => _filter = v.split(' (').first),
                  ),
                ),
                const SizedBox(width: 10),
                PressScale(
                  scale: 0.92,
                  onTap: () => showViewingForm(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        gradient: AppColors.gradient,
                        borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.add_rounded, color: Colors.black),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              if (items.isEmpty)
                const EmptyState(
                  icon: Icons.event_busy_rounded,
                  title: 'No viewings',
                  message: 'Viewing requests from clients will appear here.',
                )
              else
                Wrap(spacing: 12, runSpacing: 12, children: [
                  for (final v in items)
                    SizedBox(
                      width: w,
                      child: _ViewingCard(
                        v: v,
                        canAssign: me.role.assignWork,
                        onStatus: (s) => _set(v, s),
                        onReschedule: () => _reschedule(v),
                        onAssign: () => _assign(v),
                      ),
                    ),
                ]),
            ]),
          );
        });
      },
    );
  }
}

class _ViewingCard extends StatelessWidget {
  final ViewingRequest v;
  final bool canAssign;
  final ValueChanged<String> onStatus;
  final VoidCallback onReschedule;
  final VoidCallback onAssign;
  const _ViewingCard({
    required this.v,
    required this.canAssign,
    required this.onStatus,
    required this.onReschedule,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    final next = v.status == 'Pending'
        ? ('Confirm', 'Confirmed', Icons.check_circle_outline_rounded)
        : (v.status == 'Confirmed'
        ? ('Complete', 'Completed', Icons.task_alt_rounded)
        : null);
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(v.ref,
              style: const TextStyle(
                  color: AppColors.orange,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1)),
          const Spacer(),
          Pill(v.status.toUpperCase(), statusColor(v.status)),
        ]),
        const SizedBox(height: 10),
        Text(v.property,
            style: const TextStyle(
                color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        _info(Icons.person_outline_rounded, 'Client: ${v.client}'),
        _info(Icons.calendar_month_rounded, '${v.date} • ${v.time}'),
        _info(Icons.flight_takeoff_rounded,
            '${v.mode} • ${v.guests} guest${v.guests == 1 ? '' : 's'}'),
        _info(Icons.support_agent_rounded,
            'Handled by: ${_staffName(v.assignedTo)}'),
        const SizedBox(height: 10),
        Row(children: [
          if (next != null)
            Expanded(
              child: ActionBtn(
                icon: next.$3,
                label: next.$1,
                filled: true,
                height: 42,
                onTap: () => onStatus(next.$2),
              ),
            ),
          if (next != null) const SizedBox(width: 8),
          Expanded(
            child: ActionBtn(
              icon: Icons.edit_calendar_rounded,
              label: 'Reschedule',
              height: 42,
              onTap: onReschedule,
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            color: AppColors.card,
            shape: menuShape,
            onSelected: (x) {
              if (x == 'assign') {
                onAssign();
              } else {
                onStatus(x);
              }
            },
            itemBuilder: (_) => [
              if (canAssign)
                menuItem('assign', Icons.swap_horiz_rounded, 'Assign to...'),
              menuItem('Pending', Icons.hourglass_top_rounded, 'Mark Pending'),
              menuItem('Cancelled', Icons.cancel_outlined, 'Cancel viewing',
                  danger: true),
            ],
            child: Container(
              width: 44,
              height: 42,
              decoration: BoxDecoration(
                  color: const Color(0xFF18181A),
                  borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.more_horiz_rounded, color: AppColors.text),
            ),
          ),
        ]),
      ]),
    );
  }
}

// ======================================================= New viewing form

Future<void> showViewingForm(BuildContext context) {
  return showFormSheet<void>(
    context,
    title: 'New Viewing',
    child: const _ViewingForm(),
  );
}

class _ViewingForm extends StatefulWidget {
  const _ViewingForm();

  @override
  State<_ViewingForm> createState() => _ViewingFormState();
}

class _ViewingFormState extends State<_ViewingForm> {
  static const _times = ['10:00 AM', '12:00 PM', '02:00 PM', '04:00 PM', '06:00 PM'];
  final _client = TextEditingController();
  final _property = TextEditingController();
  DateTime? _date;
  String? _time;
  String _mode = 'Chauffeur';
  String? _clientErr, _propErr;

  @override
  void dispose() {
    _client.dispose();
    _property.dispose();
    super.dispose();
  }

  Future<bool> _save() async {
    setState(() {
      _clientErr = Validators.required(_client.text, 'Client name');
      _propErr = Validators.required(_property.text, 'Property');
    });
    if (_clientErr != null || _propErr != null) {
      HapticFeedback.mediumImpact();
      return false;
    }
    if (_date == null || _time == null) {
      showToast(context, 'Please choose a date and time', error: true);
      return false;
    }
    await Future.delayed(const Duration(milliseconds: 600));
    final p = _property.text.trim();
    final match =
        allListings.where((l) => l.id.toLowerCase() == p.toLowerCase()).firstOrNull;
    ViewingStore.addStaff(ViewingRequest(
      ref: 'VV-${1000 + Random().nextInt(9000)}',
      property: match?.title ?? p,
      client: _client.text.trim(),
      date: fmtDate(_date!),
      time: _time!,
      mode: _mode,
      guests: 1,
      status: 'Confirmed',
      assignedTo: Session.staff!.id,
    ));
    ActivityStore.log(
        Session.staff!.name, 'booked a viewing for ${_client.text.trim()}');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AuthField(
        label: 'Client name',
        hint: 'Client name',
        icon: Icons.person_outline_rounded,
        controller: _client,
        errorText: _clientErr,
        onChanged: (_) => setState(() => _clientErr = null),
      ),
      const SizedBox(height: 14),
      AuthField(
        label: 'Property (title or listing ID)',
        hint: '10 Marla House or NH-H-1042',
        icon: Icons.home_work_outlined,
        controller: _property,
        errorText: _propErr,
        onChanged: (_) => setState(() => _propErr = null),
      ),
      const SizedBox(height: 16),
      PressScale(
        onTap: () async {
          final d = await pickDate(context);
          if (d != null) setState(() => _date = d);
        },
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: _date != null ? AppColors.orange : AppColors.border),
          ),
          child: Row(children: [
            Icon(Icons.calendar_month_rounded,
                size: 20,
                color: _date != null ? AppColors.orange : AppColors.muted),
            const SizedBox(width: 10),
            Text(_date == null ? 'Select date' : fmtDate(_date!),
                style: TextStyle(
                    color: _date == null ? AppColors.muted : AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
      const SizedBox(height: 14),
      ChipSelect(
          label: 'Time',
          options: _times,
          selected: _time,
          onChanged: (v) => setState(() => _time = v)),
      const SizedBox(height: 16),
      ChipSelect(
          label: 'Travel',
          options: const ['Chauffeur', 'Helicopter', 'Private Jet'],
          selected: _mode,
          onChanged: (v) => setState(() => _mode = v)),
      const SizedBox(height: 22),
      GradientButton(
        label: 'Book Viewing',
        icon: Icons.event_available_rounded,
        onPressed: _save,
        onSuccess: () {
          showToast(context, 'Viewing booked and confirmed');
          Navigator.of(context).pop();
        },
      ),
    ]);
  }
}