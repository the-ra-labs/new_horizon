import 'dart:math';
import 'package:flutter/material.dart';
import '../data/listings.dart';
import '../data/stores.dart';
import '../theme/app_colors.dart';
import '../utils/helpers.dart';
import '../utils/pickers.dart';
import '../widgets/action_button.dart';
import '../widgets/fade_slide.dart';
import '../widgets/listing_card.dart';
import '../widgets/sub_shell.dart';

class ListingDetailScreen extends StatelessWidget {
  final Listing l;
  const ListingDetailScreen({super.key, required this.l});

  static const _amenities = [
    'Gated Community',
    '24/7 Security',
    'Underground Utilities',
    'Mosque & Park',
    'Wide Boulevards',
  ];

  Widget _stack(List<Widget> items) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < items.length; i++) ...[
        if (i > 0) const SizedBox(height: 18),
        items[i],
      ],
    ],
  );

  @override
  Widget build(BuildContext context) {
    return SubShell(
      caption: l.id,
      title: 'Listing Details',
      body: LayoutBuilder(builder: (context, box) {
        final wide = box.maxWidth >= 760;
        final hero = _hero();
        final headline = _headline();
        final specs = _specs();
        final plan = _plan();
        final actions = _actions(context);
        final features = _features();
        final about = _about();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: wide
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: FadeSlide(
                    child: _stack([hero, features, about]))),
            const SizedBox(width: 20),
            Expanded(
                child: FadeSlide(
                    delayMs: 100,
                    child: _stack([headline, specs, plan, actions]))),
          ])
              : FadeSlide(
              child: _stack(
                  [hero, headline, specs, plan, actions, features, about])),
        );
      }),
    );
  }

  Widget _card(String title, Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF1C1C1F),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: const TextStyle(
              color: AppColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      child,
    ]),
  );

  Widget _hero() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 230,
        child: Stack(fit: StackFit.expand, children: [
          CoverImage(l),
          Positioned(top: 14, left: 14, child: StatusChip(l.status)),
          Positioned(top: 12, right: 12, child: SaveButton(id: l.id, size: 40)),
          Positioned(
            left: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(l.offerLabel.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  )),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _headline() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.title,
          style: const TextStyle(
              color: AppColors.text,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.15)),
      const SizedBox(height: 6),
      Row(children: [
        const Icon(Icons.location_on_outlined,
            size: 16, color: AppColors.orange),
        const SizedBox(width: 4),
        Expanded(
          child: Text('${l.number}, ${l.block}, ${l.phaseLabel}',
              style: const TextStyle(color: AppColors.muted, fontSize: 13)),
        ),
      ]),
      const SizedBox(height: 12),
      Text(l.priceText,
          style: const TextStyle(
              color: AppColors.peach,
              fontSize: 28,
              fontWeight: FontWeight.w800)),
      if (l.kind == ListingKind.plot && l.marla > 0)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('≈ ${fmtPkr(l.price / l.marla)} per marla',
              style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
        ),
    ]);
  }

  Widget _specs() {
    final items = <(IconData, String, String)>[
      (Icons.square_foot_rounded, 'Size', l.sizeLabel),
      (Icons.straighten_rounded, 'Area', '${commas(l.sqft)} sq ft'),
      (Icons.layers_outlined, 'Phase', l.phaseLabel),
      (Icons.grid_view_rounded, 'Block', l.block),
      (Icons.category_outlined, 'Type', l.subType),
      (Icons.tag_rounded, 'Unit', l.number),
      if (l.beds > 0) (Icons.bed_outlined, 'Bedrooms', '${l.beds}'),
      if (l.baths > 0) (Icons.bathtub_outlined, 'Bathrooms', '${l.baths}'),
      if (l.floors > 0) (Icons.stairs_rounded, 'Floors', '${l.floors}'),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 190,
        mainAxisExtent: 70,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (_, i) {
        final s = items[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1F),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
          ),
          child: Row(children: [
            Icon(s.$1, size: 20, color: AppColors.orange),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.$2,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(s.$3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800)),
                  ]),
            ),
          ]),
        );
      },
    );
  }

  Widget _row(String a, String b, {bool hi = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(a, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
      Text(b,
          style: TextStyle(
              color: hi ? AppColors.peach : AppColors.text,
              fontSize: 13.5,
              fontWeight: FontWeight.w800)),
    ]),
  );

  Widget _plan() {
    final sale = l.offer == Offer.sale;
    return _card(
      sale ? 'Payment Plan (indicative)' : 'Rental Terms (indicative)',
      Column(children: [
        if (sale) ...[
          _row('Down payment (30%)', fmtPkr(l.price * 0.3), hi: true),
          _row('Balance (70%)', fmtPkr(l.price * 0.7)),
          _row('Monthly installment (36 months)',
              fmtPkr((l.price * 0.7 / 36 / 1000).round() * 1000)),
        ] else ...[
          _row('Monthly rent', 'PKR ${commas(l.price)}', hi: true),
          _row('Security deposit (2 months)', 'PKR ${commas(l.price * 2)}'),
          _row('Advance (1 month)', 'PKR ${commas(l.price)}'),
        ],
        const SizedBox(height: 8),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Final terms are confirmed by your advisor.',
              style: TextStyle(color: AppColors.muted, fontSize: 11.5)),
        ),
      ]),
    );
  }

  Widget _actions(BuildContext context) {
    return Column(children: [
      ActionBtn(
        icon: Icons.calendar_today_outlined,
        label: 'Request Viewing',
        filled: true,
        height: 52,
        onTap: () => _request(context),
      ),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(
          child: ActionBtn(
            icon: Icons.call_outlined,
            label: 'Call Advisor',
            onTap: () => showToast(context, 'Connecting to your advisor...'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ActionBtn(
            icon: Icons.chat_outlined,
            label: 'WhatsApp',
            onTap: () => showToast(context, 'Opening WhatsApp...'),
          ),
        ),
      ]),
    ]);
  }

  Future<void> _request(BuildContext context) async {
    final d = await pickDate(context);
    if (d == null || !context.mounted) return;
    final t = await pickTime(context);
    if (t == null || !context.mounted) return;
    final time = t.format(context);
    ViewingStore.add(ViewingRequest(
      ref: 'VV-${1000 + Random().nextInt(9000)}',
      property: l.title,
      date: fmtDate(d),
      time: time,
      mode: 'Chauffeur',
      guests: 1,
    ));
    showToast(context, 'Viewing requested: ${fmtDate(d)} at $time');
  }

  Widget _features() {
    final all = [...l.features, ..._amenities.take(3)];
    return _card(
      'Features & Amenities',
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final f in all)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border:
              Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.check_rounded,
                  size: 14, color: AppColors.orange),
              const SizedBox(width: 6),
              Text(f,
                  style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
      ]),
    );
  }

  Widget _about() => _card(
    'About this listing',
    Text(describe(l),
        style: const TextStyle(
            color: AppColors.muted, fontSize: 13.5, height: 1.55)),
  );
}