import 'dart:math' show min;
import 'package:flutter/material.dart';
import '../data/listings.dart';
import '../theme/app_colors.dart';
import '../utils/helpers.dart';
import '../utils/responsive.dart';
import '../widgets/fade_slide.dart';
import '../widgets/listing_card.dart';
import '../widgets/press_scale.dart';
import '../widgets/search_bar_field.dart';
import '../widgets/step_menu.dart';
import '../widgets/sub_shell.dart';
import 'listing_detail_screen.dart';

class ListingsScreen extends StatefulWidget {
  final String caption;
  final String title;
  final String banner;
  final String searchHint;
  final bool Function(Listing) base;
  final List<MenuStep> steps;

  const ListingsScreen({
    super.key,
    required this.caption,
    required this.title,
    required this.banner,
    required this.searchHint,
    required this.base,
    required this.steps,
  });

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  static const _sorts = [
    'Recommended',
    'Price: Low to High',
    'Price: High to Low',
    'Size: Large to Small',
  ];

  late final List<Listing> _base = allListings.where(widget.base).toList();
  late final List<String?> _sel =
  List<String?>.filled(widget.steps.length, null);
  final _qc = TextEditingController();
  String _query = '';
  String _sort = _sorts.first;

  @override
  void dispose() {
    _qc.dispose();
    super.dispose();
  }

  List<Listing> _filtered(int upTo) {
    var items = _base;
    for (var j = 0; j < upTo; j++) {
      final s = _sel[j];
      if (s != null && s != 'All') {
        final step = widget.steps[j];
        items = items.where((l) => step.value(l) == s).toList();
      }
    }
    return items;
  }

  List<String> _options(int i) {
    final map = <String, num>{};
    for (final l in _filtered(i)) {
      map[widget.steps[i].value(l)] = widget.steps[i].order(l);
    }
    final keys = map.keys.toList()..sort((a, b) => map[a]!.compareTo(map[b]!));
    return ['All', ...keys];
  }

  List<Listing> _results() {
    var items = _filtered(widget.steps.length);
    final tokens = _query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    if (tokens.isNotEmpty) {
      items = items.where((l) => tokens.every(l.matches)).toList();
    }
    items = [...items];
    switch (_sort) {
      case 'Price: Low to High':
        items.sort((a, b) => a.price.compareTo(b.price));
      case 'Price: High to Low':
        items.sort((a, b) => b.price.compareTo(a.price));
      case 'Size: Large to Small':
        items.sort((a, b) => b.sqft.compareTo(a.sqft));
      default:
        items.sort((a, b) {
          final c = a.phase.compareTo(b.phase);
          return c != 0 ? c : a.sqft.compareTo(b.sqft);
        });
    }
    return items;
  }

  void _select(int i, String v) {
    setState(() {
      _sel[i] = _sel[i] == v ? null : v;
      for (var j = i + 1; j < _sel.length; j++) {
        _sel[j] = null;
      }
    });
  }

  void _resetMenu() => setState(() {
    for (var j = 0; j < _sel.length; j++) {
      _sel[j] = null;
    }
  });

  void _clearAll() {
    _qc.clear();
    setState(() {
      _query = '';
      for (var j = 0; j < _sel.length; j++) {
        _sel[j] = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final results = _results();
    final groups = <int, List<Listing>>{};
    for (final l in results) {
      groups.putIfAbsent(l.phase, () => <Listing>[]).add(l);
    }
    final phases = groups.keys.toList()..sort();
    final options = [
      for (var i = 0; i < widget.steps.length; i++) _options(i),
    ];

    final available = _base.where((l) => l.status == 'Available').length;
    final phaseCount = _base.map((l) => l.phase).toSet().length;

    final w = min(MediaQuery.sizeOf(context).width,
        Responsive.maxContentWidth(context)) -
        40;
    final cols = w >= 960 ? 3 : (w >= 600 ? 2 : 1);

    return SubShell(
      caption: widget.caption,
      title: widget.title,
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Column(children: [
              FadeSlide(
                child: _Summary(
                  text: widget.banner,
                  stats: [
                    ('${_base.length}', 'LISTINGS'),
                    ('$phaseCount', 'PHASES'),
                    ('$available', 'AVAILABLE'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FadeSlide(
                delayMs: 80,
                child: ListingSearchBar(
                  controller: _qc,
                  hint: widget.searchHint,
                  sort: _sort,
                  sortOptions: _sorts,
                  onChanged: (v) => setState(() => _query = v),
                  onSort: (v) => setState(() => _sort = v),
                ),
              ),
              const SizedBox(height: 14),
              FadeSlide(
                delayMs: 160,
                child: StepMenu(
                  steps: widget.steps,
                  selected: _sel,
                  options: options,
                  onSelect: _select,
                  onReset: _resetMenu,
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Text('${results.length} Results',
                    style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                const Spacer(),
                Text(_sort == 'Recommended' ? 'Grouped by phase' : _sort,
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 12)),
              ]),
            ]),
          ),
        ),
        for (final ph in phases) ...[
          SliverToBoxAdapter(
              child: _PhaseHeader(phase: ph, count: groups[ph]!.length)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisExtent: ListingCard.height,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, i) {
                  final l = groups[ph]![i];
                  return FadeSlide(
                    key: ValueKey(l.id),
                    delayMs: (i % 6) * 50,
                    child: ListingCard(
                      l: l,
                      onTap: () => Navigator.of(context)
                          .push(fadeRoute(ListingDetailScreen(l: l))),
                    ),
                  );
                },
                childCount: groups[ph]!.length,
              ),
            ),
          ),
        ],
        if (results.isEmpty) SliverToBoxAdapter(child: _Empty(onClear: _clearAll)),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ]),
    );
  }
}

class _Summary extends StatelessWidget {
  final String text;
  final List<(String, String)> stats;
  const _Summary({required this.text, required this.stats});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: const BoxDecoration(color: Color(0xFF242427)),
        child: Stack(children: [
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 180,
              height: 180,
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
            Text(text,
                style: const TextStyle(
                    color: AppColors.muted, fontSize: 13, height: 1.45)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF18181A),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(children: [
                for (var i = 0; i < stats.length; i++) ...[
                  if (i > 0)
                    Container(width: 1, height: 30, color: AppColors.border),
                  Expanded(
                    child: Column(children: [
                      Text(stats[i].$1,
                          style: TextStyle(
                            color: i == 1 ? AppColors.peach : AppColors.text,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          )),
                      const SizedBox(height: 3),
                      Text(stats[i].$2,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          )),
                    ]),
                  ),
                ],
              ]),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _PhaseHeader extends StatelessWidget {
  final int phase;
  final int count;
  const _PhaseHeader({required this.phase, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(children: [
        Container(
          width: 4,
          height: 34,
          decoration: BoxDecoration(
              color: AppColors.orange, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('PHASE $phase',
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                )),
            Text(phaseInfo[phase] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2D),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('$count listings',
              style: const TextStyle(
                  color: AppColors.peach,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800)),
        ),
      ]),
    );
  }
}

class _Empty extends StatelessWidget {
  final VoidCallback onClear;
  const _Empty({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 0),
      child: Column(children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.orange.withValues(alpha: 0.1),
            border: Border.all(color: AppColors.orange.withValues(alpha: 0.4)),
          ),
          child: const Icon(Icons.search_off_rounded,
              color: AppColors.orange, size: 34),
        ),
        const SizedBox(height: 16),
        const Text('No matching listings',
            style: TextStyle(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('Try a different search or reset the filter menu.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 13)),
        const SizedBox(height: 18),
        PressScale(
          onTap: onClear,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: AppColors.gradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text('Clear filters',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w800)),
          ),
        ),
      ]),
    );
  }
}