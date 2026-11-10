import 'dart:math';
import 'package:flutter/material.dart';
import '../data/listings.dart';
import '../data/stores.dart';
import '../theme/app_colors.dart';
import '../utils/helpers.dart';
import '../utils/pickers.dart';
import '../widgets/fade_slide.dart';
import '../widgets/gradient_button.dart';
import '../widgets/listing_card.dart';
import '../widgets/press_scale.dart';
import '../widgets/sub_shell.dart';

class VipViewingScreen extends StatefulWidget {
  const VipViewingScreen({super.key});

  @override
  State<VipViewingScreen> createState() => _VipViewingScreenState();
}

class _VipViewingScreenState extends State<VipViewingScreen> {
  static const _times = ['10:00 AM', '12:00 PM', '02:00 PM', '04:00 PM', '06:00 PM'];
  static const _modes = [
    ('Private Jet', 'Air charter', Icons.flight_rounded),
    ('Helicopter', 'City transfer', Icons.flight_takeoff_rounded),
    ('Chauffeur', 'Luxury ground', Icons.directions_car_filled_rounded),
  ];

  late final List<Listing> _featured = (allListings
      .where((l) => l.offer == Offer.sale)
      .toList()
    ..sort((a, b) => b.price.compareTo(a.price)))
      .take(6)
      .toList();

  Listing? _property;
  DateTime? _date;
  String? _time;
  String? _mode;
  int _guests = 2;
  int _version = 0;
  final _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<bool> _submit() async {
    if (_property == null) {
      showToast(context, 'Please select a property', error: true);
      return false;
    }
    if (_date == null || _time == null) {
      showToast(context, 'Please choose a date and time', error: true);
      return false;
    }
    if (_mode == null) {
      showToast(context, 'Please choose how you would like to travel',
          error: true);
      return false;
    }
    await Future.delayed(const Duration(milliseconds: 1500));
    ViewingStore.add(ViewingRequest(
      ref: 'VV-${1000 + Random().nextInt(9000)}',
      property: _property!.title,
      date: fmtDate(_date!),
      time: _time!,
      mode: _mode!,
      guests: _guests,
    ));
    return true;
  }

  void _done() {
    showToast(context, 'VIP viewing requested. Your advisor will confirm shortly.');
    setState(() {
      _property = null;
      _date = null;
      _time = null;
      _mode = null;
      _guests = 2;
      _notes.clear();
      _version++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SubShell(
      caption: 'Private air & ground',
      title: 'VIP Viewing',
      body: LayoutBuilder(builder: (context, box) {
        final wide = box.maxWidth >= 900;
        final form = _form();
        final upcoming = _upcoming();
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          child: wide
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 3, child: form),
            const SizedBox(width: 20),
            Expanded(flex: 2, child: upcoming),
          ])
              : Column(children: [form, const SizedBox(height: 26), upcoming]),
        );
      }),
    );
  }

  Widget _section(int n, String title, Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                gradient: AppColors.gradient, shape: BoxShape.circle),
            child: Text('$n',
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }

  Widget _form() {
    return FadeSlide(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _section(
          1,
          'Select property',
          Column(children: [
            for (final l in _featured) _propertyTile(l),
          ]),
        ),
        _section(
          2,
          'Date & time',
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                      color: _date != null
                          ? AppColors.orange
                          : AppColors.border),
                ),
                child: Row(children: [
                  Icon(Icons.calendar_month_rounded,
                      size: 20,
                      color:
                      _date != null ? AppColors.orange : AppColors.muted),
                  const SizedBox(width: 10),
                  Text(_date == null ? 'Select date' : fmtDate(_date!),
                      style: TextStyle(
                        color: _date == null
                            ? AppColors.muted
                            : AppColors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      )),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final t in _times)
                _chip(t, _time == t, () => setState(() => _time = t)),
            ]),
          ]),
        ),
        _section(
          3,
          'Travel',
          Row(children: [
            for (var i = 0; i < _modes.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(child: _modeCard(_modes[i])),
            ],
          ]),
        ),
        _section(
          4,
          'Guests & notes',
          Column(children: [
            Row(children: [
              const Text('Guests',
                  style: TextStyle(color: AppColors.muted, fontSize: 14)),
              const Spacer(),
              _stepBtn(Icons.remove_rounded,
                      () => setState(() => _guests = max(1, _guests - 1))),
              SizedBox(
                width: 44,
                child: Text('$_guests',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
              ),
              _stepBtn(Icons.add_rounded,
                      () => setState(() => _guests = min(8, _guests + 1))),
            ]),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.field,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _notes,
                maxLines: 3,
                cursorColor: AppColors.orange,
                style: const TextStyle(color: AppColors.text, fontSize: 14),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Special requests (optional)',
                  hintStyle: TextStyle(
                      color: AppColors.muted.withValues(alpha: 0.7)),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 4),
        GradientButton(
          key: ValueKey(_version),
          label: 'Request VIP Viewing',
          icon: Icons.flight_takeoff_rounded,
          onPressed: _submit,
          onSuccess: _done,
        ),
      ]),
    );
  }

  Widget _propertyTile(Listing l) {
    final sel = _property?.id == l.id;
    return PressScale(
      scale: 0.98,
      onTap: () => setState(() => _property = l),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: sel ? AppColors.orange.withValues(alpha: 0.1) : AppColors.field,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: sel ? AppColors.orange : AppColors.border,
              width: sel ? 1.4 : 1),
        ),
        child: Row(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: kindColors(l)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(kindIcon(l), color: AppColors.orange, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                  style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ]),
          ),
          AnimatedScale(
            scale: sel ? 1 : 0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            child: const Icon(Icons.check_circle_rounded,
                color: AppColors.orange, size: 22),
          ),
        ]),
      ),
    );
  }

  Widget _chip(String label, bool sel, VoidCallback onTap) {
    return PressScale(
      scale: 0.94,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: sel ? AppColors.gradient : null,
          color: sel ? null : AppColors.field,
          borderRadius: BorderRadius.circular(12),
          border:
          Border.all(color: sel ? Colors.transparent : AppColors.border),
        ),
        child: Text(label,
            style: TextStyle(
                color: sel ? Colors.black : AppColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _modeCard((String, String, IconData) m) {
    final sel = _mode == m.$1;
    return PressScale(
      scale: 0.95,
      onTap: () => setState(() => _mode = m.$1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: sel ? AppColors.orange.withValues(alpha: 0.12) : AppColors.field,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: sel ? AppColors.orange : AppColors.border,
              width: sel ? 1.4 : 1),
        ),
        child: Column(children: [
          Icon(m.$3, size: 26, color: sel ? AppColors.orange : AppColors.muted),
          const SizedBox(height: 8),
          Text(m.$1,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(m.$2,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 10.5)),
        ]),
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return PressScale(
      scale: 0.88,
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.field,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 20, color: AppColors.orange),
      ),
    );
  }

  Widget _upcoming() {
    return FadeSlide(
      delayMs: 100,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Your Requests',
            style: TextStyle(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        ValueListenableBuilder<List<ViewingRequest>>(
          valueListenable: ViewingStore.items,
          builder: (_, items, __) {
            if (items.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1F),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.7)),
                ),
                child: const Text(
                  'No viewings requested yet. Your confirmed and pending private viewings will appear here.',
                  style: TextStyle(
                      color: AppColors.muted, fontSize: 13, height: 1.45),
                ),
              );
            }
            return Column(children: [
              for (final r in items)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF242427),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(r.ref,
                              style: const TextStyle(
                                  color: AppColors.orange,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('PENDING',
                                style: TextStyle(
                                    color: AppColors.orange,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8)),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        Text(r.property,
                            style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 15,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(
                            '${r.date} • ${r.time} • ${r.mode} • ${r.guests} guest${r.guests == 1 ? '' : 's'}',
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 12)),
                      ]),
                ),
            ]);
          },
        ),
      ]),
    );
  }
}