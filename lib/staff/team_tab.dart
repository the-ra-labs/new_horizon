import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/staff_data.dart';
import '../theme/app_colors.dart';
import '../utils/helpers.dart';
import '../widgets/action_button.dart';
import '../widgets/auth_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/press_scale.dart';
import '../widgets/staff_avatar.dart';
import '../widgets/staff_ui.dart';

class TeamTab extends StatefulWidget {
  const TeamTab({super.key});

  @override
  State<TeamTab> createState() => _TeamTabState();
}

class _TeamTabState extends State<TeamTab> {
  final _qc = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _qc.dispose();
    super.dispose();
  }

  Future<void> _reject(StaffMember m) async {
    final ok = await confirmDialog(context,
        title: 'Reject request?',
        message: '${m.name}\'s staff request will be deleted.',
        confirmLabel: 'Reject',
        danger: true);
    if (!ok || !mounted) return;
    StaffStore.remove(m.id);
    ActivityStore.log(Session.staff!.name, 'rejected ${m.name}');
    showToast(context, 'Request rejected');
  }

  void _approve(StaffMember m, StaffRole role) {
    m.role = role;
    m.status = AccountStatus.approved;
    m.title = role == StaffRole.manager ? 'Director' : 'Advisor';
    StaffStore.notify();
    ActivityStore.log(
        Session.staff!.name, 'approved ${m.name} as ${role.label}');
    showToast(context, '${m.name} approved. They can now sign in.');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<StaffMember>>(
      valueListenable: StaffStore.members,
      builder: (context, _, __) {
        final me = Session.staff!;
        final pending = me.role.approveStaff ? StaffStore.pending : <StaffMember>[];
        final q = _q.trim().toLowerCase();
        final team = StaffStore.approved
            .where((m) =>
        q.isEmpty ||
            '${m.name} ${m.title} ${m.email} ${m.role.label} ${m.region}'
                .toLowerCase()
                .contains(q))
            .toList()
          ..sort((a, b) {
            final c = a.role.index.compareTo(b.role.index);
            return c != 0 ? c : a.name.compareTo(b.name);
          });

        return LayoutBuilder(builder: (context, box) {
          final cols = box.maxWidth >= 900 ? 2 : 1;
          final w = (box.maxWidth - 40 - 12 * (cols - 1)) / cols;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              if (pending.isNotEmpty) ...[
                SectionHeader('Approvals',
                    trailing: Pill('${pending.length} PENDING', AppColors.orange)),
                const SizedBox(height: 12),
                Wrap(spacing: 12, runSpacing: 12, children: [
                  for (final m in pending)
                    SizedBox(
                      width: w,
                      child: _PendingCard(
                        m: m,
                        onReject: () => _reject(m),
                        onApprove: (r) => _approve(m, r),
                      ),
                    ),
                ]),
                const SizedBox(height: 24),
              ],
              SectionHeader('Team (${team.length})',
                  trailing: me.role.manageTeam
                      ? PressScale(
                    scale: 0.94,
                    onTap: () => showStaffForm(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                          gradient: AppColors.gradient,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_rounded,
                                size: 18, color: Colors.black),
                            SizedBox(width: 4),
                            Text('Add Staff',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800)),
                          ]),
                    ),
                  )
                      : null),
              const SizedBox(height: 12),
              SearchBox(
                controller: _qc,
                hint: 'Search name, role, region...',
                onChanged: (v) => setState(() => _q = v),
              ),
              const SizedBox(height: 14),
              if (team.isEmpty)
                const EmptyState(
                    icon: Icons.groups_rounded,
                    title: 'No staff found',
                    message: 'Try a different search.')
              else
                Wrap(spacing: 12, runSpacing: 12, children: [
                  for (final m in team)
                    SizedBox(
                      width: w,
                      child: _MemberCard(
                        m: m,
                        canManage: me.role.manageTeam && m.id != me.id,
                        isMe: m.id == me.id,
                        onManage: () => showStaffForm(context, member: m),
                      ),
                    ),
                ]),
              const SizedBox(height: 24),
              const _AccessLegend(),
            ]),
          );
        });
      },
    );
  }
}

class _PendingCard extends StatelessWidget {
  final StaffMember m;
  final VoidCallback onReject;
  final ValueChanged<StaffRole> onApprove;
  const _PendingCard(
      {required this.m, required this.onReject, required this.onApprove});

  @override
  Widget build(BuildContext context) {
    return Panel(
      border: AppColors.orange.withValues(alpha: 0.5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          StaffAvatar(name: m.name, width: 46, height: 46, radius: 23),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800)),
              const Text('Requested: Advisor access',
                  style: TextStyle(color: AppColors.peach, fontSize: 12)),
            ]),
          ),
          const Pill('PENDING', AppColors.orange),
        ]),
        const SizedBox(height: 12),
        Text(m.email,
            style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
        Text(m.phone,
            style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: ActionBtn(
                icon: Icons.close_rounded,
                label: 'Reject',
                height: 44,
                onTap: onReject),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: PopupMenuButton<StaffRole>(
              color: AppColors.card,
              shape: menuShape,
              onSelected: onApprove,
              itemBuilder: (_) => [
                menuItem(StaffRole.agent, Icons.badge_outlined,
                    'Approve as Advisor'),
                menuItem(StaffRole.manager, Icons.workspace_premium_outlined,
                    'Approve as Director'),
              ],
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                    gradient: AppColors.gradient,
                    borderRadius: BorderRadius.circular(14)),
                child: const Center(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.check_rounded, size: 18, color: Colors.black),
                    SizedBox(width: 6),
                    Text('Approve',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800)),
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final StaffMember m;
  final bool canManage;
  final bool isMe;
  final VoidCallback onManage;
  const _MemberCard(
      {required this.m,
        required this.canManage,
        required this.isMe,
        required this.onManage});

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          StaffAvatar(name: m.name, image: m.image, width: 56, height: 56, radius: 16),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(m.name,
                      style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                  RoleBadge(m.role),
                  if (isMe) const Pill('YOU', AppColors.success),
                ],
              ),
              const SizedBox(height: 3),
              if (m.title.isNotEmpty)
                Text(m.title,
                    style: const TextStyle(
                        color: AppColors.orange,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(m.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              Text(m.phone,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ]),
          ),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: ActionBtn(
                icon: Icons.call_outlined,
                label: 'Call',
                height: 42,
                onTap: () => showToast(context, 'Calling ${m.name}...')),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ActionBtn(
                icon: Icons.chat_outlined,
                label: 'Chat',
                height: 42,
                onTap: () => showToast(context, 'Opening chat with ${m.name}')),
          ),
          if (canManage) ...[
            const SizedBox(width: 8),
            Expanded(
              child: ActionBtn(
                  icon: Icons.settings_outlined,
                  label: 'Manage',
                  filled: true,
                  height: 42,
                  onTap: onManage),
            ),
          ],
        ]),
      ]),
    );
  }
}

class _AccessLegend extends StatelessWidget {
  const _AccessLegend();

  @override
  Widget build(BuildContext context) {
    Widget row(StaffRole r, String text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 78, child: RoleBadge(r)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  color: AppColors.muted, fontSize: 12.5, height: 1.4)),
        ),
      ]),
    );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader('Access Levels'),
      const SizedBox(height: 12),
      Panel(
        child: Column(children: [
          row(StaffRole.ceo,
              'Full control: team, approvals, listings, leads and viewings.'),
          const Divider(color: AppColors.border, height: 1),
          row(StaffRole.manager,
              'Manage listings, leads and viewings. Assign work. Cannot manage the team.'),
          const Divider(color: AppColors.border, height: 1),
          row(StaffRole.agent,
              'Add and edit listings. Work only on own assigned leads and viewings.'),
        ]),
      ),
    ]);
  }
}

// ======================================================= Staff form

Future<void> showStaffForm(BuildContext context,
    {StaffMember? member, bool self = false}) {
  return showFormSheet<void>(
    context,
    title: member == null
        ? 'Add Staff'
        : (self ? 'Edit My Profile' : 'Manage ${member.name}'),
    child: _StaffForm(member: member, self: self),
  );
}

class _StaffForm extends StatefulWidget {
  final StaffMember? member;
  final bool self;
  const _StaffForm({this.member, this.self = false});

  @override
  State<_StaffForm> createState() => _StaffFormState();
}

class _StaffFormState extends State<_StaffForm> {
  late final _name = TextEditingController(text: widget.member?.name ?? '');
  late final _email = TextEditingController(text: widget.member?.email ?? '');
  late final _phone = TextEditingController(text: widget.member?.phone ?? '');
  final _pw = TextEditingController();
  late final _title = TextEditingController(text: widget.member?.title ?? '');
  late final _creds =
  TextEditingController(text: widget.member?.credentials ?? '');
  late final _focus = TextEditingController(text: widget.member?.focus ?? '');
  late final _region = TextEditingController(text: widget.member?.region ?? '');
  late final _langs =
  TextEditingController(text: widget.member?.languages ?? 'EN');
  late StaffRole _role = widget.member?.role ?? StaffRole.agent;
  String? _nameErr, _emailErr, _phoneErr, _pwErr;

  bool get _editing => widget.member != null;
  bool get _roleEditable =>
      !widget.self && (widget.member?.role != StaffRole.ceo);

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _pw, _title, _creds, _focus, _region, _langs]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<bool> _save() async {
    setState(() {
      _nameErr = Validators.required(_name.text, 'Name');
      _emailErr = Validators.email(_email.text);
      _phoneErr = Validators.phone(_phone.text);
      if (!_editing) {
        _pwErr = Validators.password(_pw.text);
      } else {
        _pwErr = _pw.text.isEmpty ? null : Validators.password(_pw.text);
      }
      if (_emailErr == null &&
          _phoneErr == null &&
          StaffStore.contactTaken(_email.text, _phone.text,
              exceptId: widget.member?.id)) {
        _emailErr = 'Email or phone already in use';
      }
    });
    if ([_nameErr, _emailErr, _phoneErr, _pwErr].any((e) => e != null)) {
      HapticFeedback.mediumImpact();
      return false;
    }
    await Future.delayed(const Duration(milliseconds: 600));
    final actor = Session.staff!.name;
    final e = widget.member;
    if (e == null) {
      StaffStore.add(StaffMember(
        id: StaffStore.nextId(),
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        password: _pw.text,
        role: _role,
        title: _title.text.trim().isEmpty ? _role.label : _title.text.trim(),
        credentials: _creds.text.trim(),
        focus: _focus.text.trim(),
        portfolio: 'New joiner',
        languages: _langs.text.trim(),
        region: _region.text.trim(),
      ));
      ActivityStore.log(actor, 'added staff ${_name.text.trim()}');
    } else {
      e.name = _name.text.trim();
      e.email = _email.text.trim();
      e.phone = _phone.text.trim();
      if (_pw.text.isNotEmpty) e.password = _pw.text;
      e.title = _title.text.trim();
      e.credentials = _creds.text.trim();
      e.focus = _focus.text.trim();
      e.region = _region.text.trim();
      e.languages = _langs.text.trim();
      if (_roleEditable) e.role = _role;
      StaffStore.notify();
      ActivityStore.log(actor, 'updated staff ${e.name}');
    }
    return true;
  }

  Future<void> _remove() async {
    final m = widget.member!;
    final ok = await confirmDialog(context,
        title: 'Remove ${m.name}?',
        message:
        'They will lose access immediately. Their leads become unassigned.',
        confirmLabel: 'Remove',
        danger: true);
    if (!ok || !mounted) return;
    for (final l in LeadStore.items.value) {
      if (l.assignedTo == m.id) l.assignedTo = null;
    }
    LeadStore.notify();
    StaffStore.remove(m.id);
    ActivityStore.log(Session.staff!.name, 'removed staff ${m.name}');
    showToast(context, '${m.name} removed');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AuthField(
        label: 'Full name',
        hint: 'Staff name',
        icon: Icons.person_outline_rounded,
        controller: _name,
        errorText: _nameErr,
        onChanged: (_) => setState(() => _nameErr = null),
      ),
      const SizedBox(height: 14),
      AuthField(
        label: 'Email',
        hint: 'name@horizon.ae',
        icon: Icons.mail_outline_rounded,
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        errorText: _emailErr,
        onChanged: (_) => setState(() => _emailErr = null),
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
        label: _editing ? 'New password (optional)' : 'Password',
        hint: _editing ? 'Leave blank to keep current' : 'Min 6 characters',
        icon: Icons.key_rounded,
        controller: _pw,
        isPassword: true,
        errorText: _pwErr,
        onChanged: (_) => setState(() => _pwErr = null),
      ),
      if (_roleEditable) ...[
        const SizedBox(height: 16),
        ChipSelect(
          label: 'Role',
          options: const ['Director', 'Advisor'],
          selected: _role == StaffRole.manager ? 'Director' : 'Advisor',
          onChanged: (v) => setState(
                  () => _role = v == 'Director' ? StaffRole.manager : StaffRole.agent),
        ),
      ],
      const SizedBox(height: 14),
      AuthField(
        label: 'Job title',
        hint: 'Senior Advisor',
        icon: Icons.work_outline_rounded,
        controller: _title,
      ),
      const SizedBox(height: 14),
      AuthField(
        label: 'Credentials',
        hint: 'MRICS • MBA',
        icon: Icons.school_outlined,
        controller: _creds,
      ),
      const SizedBox(height: 14),
      AuthField(
        label: 'Focus area',
        hint: 'Commercial & Land',
        icon: Icons.track_changes_rounded,
        controller: _focus,
      ),
      const SizedBox(height: 14),
      AuthField(
        label: 'Region',
        hint: 'Lahore & Islamabad',
        icon: Icons.location_on_outlined,
        controller: _region,
      ),
      const SizedBox(height: 14),
      AuthField(
        label: 'Languages',
        hint: 'EN • UR',
        icon: Icons.language_rounded,
        controller: _langs,
      ),
      const SizedBox(height: 22),
      GradientButton(
        label: _editing ? 'Save Changes' : 'Add Staff Member',
        icon: Icons.check_rounded,
        onPressed: _save,
        onSuccess: () {
          showToast(context, _editing ? 'Staff updated' : 'Staff member added');
          Navigator.of(context).pop();
        },
      ),
      if (_editing && !widget.self && widget.member!.role != StaffRole.ceo) ...[
        const SizedBox(height: 12),
        ActionBtn(
          icon: Icons.person_remove_alt_1_rounded,
          label: 'Remove from team',
          onTap: _remove,
        ),
      ],
    ]);
  }
}