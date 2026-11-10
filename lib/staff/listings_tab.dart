import 'package:flutter/material.dart';
import '../data/listings.dart';
import '../data/staff_data.dart';
import '../screens/listing_detail_screen.dart';
import '../theme/app_colors.dart';
import '../utils/helpers.dart';
import '../widgets/listing_card.dart';
import '../widgets/press_scale.dart';
import '../widgets/search_bar_field.dart';
import '../widgets/staff_ui.dart';
import 'listing_editor_screen.dart';

class ListingsMgmtTab extends StatefulWidget {
  const ListingsMgmtTab({super.key});

  @override
  State<ListingsMgmtTab> createState() => _ListingsMgmtTabState();
}

class _ListingsMgmtTabState extends State<ListingsMgmtTab> {
  static const _kinds = ['All', 'Plot', 'Building', 'Plaza', 'Shop', 'House'];
  static const _statuses = ['All', 'Available', 'Reserved', 'Sold', 'Rented'];
  static const _sorts = [
    'Newest',
    'Price: Low to High',
    'Price: High to Low',
    'Size: Large to Small',
  ];

  final _qc = TextEditingController();
  String _q = '';
  String _kind = 'All';
  String _status = 'All';
  String _sort = _sorts.first;

  @override
  void dispose() {
    _qc.dispose();
    super.dispose();
  }

  List<Listing> _results() {
    var items = allListings
        .where((l) =>
    (_kind == 'All' || l.kindLabel == _kind) &&
        (_status == 'All' || l.status == _status))
        .toList();
    final tokens = _q
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    if (tokens.isNotEmpty) {
      items = items.where((l) => tokens.every(l.matches)).toList();
    }
    switch (_sort) {
      case 'Price: Low to High':
        items.sort((a, b) => a.price.compareTo(b.price));
      case 'Price: High to Low':
        items.sort((a, b) => b.price.compareTo(a.price));
      case 'Size: Large to Small':
        items.sort((a, b) => b.sqft.compareTo(a.sqft));
    }
    return items;
  }

  Future<void> _delete(Listing l) async {
    final ok = await confirmDialog(
      context,
      title: 'Delete listing?',
      message: '${l.title} (${l.id}) will be removed for staff and clients.',
      confirmLabel: 'Delete',
      danger: true,
    );
    if (!ok || !mounted) return;
    ListingStore.remove(l.id);
    ActivityStore.log(Session.staff!.name, 'deleted listing ${l.id}');
    showToast(context, 'Listing deleted');
  }

  void _setStatus(Listing l, String s) {
    ListingStore.update(l.copyWith(status: s));
    ActivityStore.log(Session.staff!.name, 'marked ${l.id} as $s');
    showToast(context, '${l.id} marked as $s');
  }

  @override
  Widget build(BuildContext context) {
    final me = Session.staff!;
    return AnimatedBuilder(
      animation: ListingStore.revision,
      builder: (context, _) {
        final res = _results();
        return LayoutBuilder(builder: (context, box) {
          final cols = box.maxWidth >= 900 ? 2 : 1;
          return CustomScrollView(slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(children: [
                        Expanded(
                          child: ListingSearchBar(
                            controller: _qc,
                            hint: 'Search ID, size, phase, block...',
                            sort: _sort,
                            sortOptions: _sorts,
                            onChanged: (v) => setState(() => _q = v),
                            onSort: (v) => setState(() => _sort = v),
                          ),
                        ),
                        const SizedBox(width: 10),
                        PressScale(
                          scale: 0.92,
                          onTap: () => Navigator.of(context)
                              .push(fadeRoute(const ListingEditorScreen())),
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: AppColors.gradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.orange
                                        .withValues(alpha: 0.3),
                                    blurRadius: 14)
                              ],
                            ),
                            child: const Icon(Icons.add_rounded,
                                color: Colors.black, size: 26),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 14),
                      ChipSelect(
                        options: _kinds,
                        selected: _kind,
                        scroll: true,
                        onChanged: (v) => setState(() => _kind = v),
                      ),
                      const SizedBox(height: 8),
                      ChipSelect(
                        options: _statuses,
                        selected: _status,
                        scroll: true,
                        onChanged: (v) => setState(() => _status = v),
                      ),
                      const SizedBox(height: 14),
                      Row(children: [
                        Text('${res.length} listings',
                            style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 15,
                                fontWeight: FontWeight.w800)),
                        const Spacer(),
                        Text(_sort,
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 12)),
                      ]),
                    ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              sliver: res.isEmpty
                  ? const SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No listings found',
                  message: 'Change the filters or add a new listing.',
                ),
              )
                  : SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  mainAxisExtent: 112,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, i) {
                    final l = res[i];
                    return _ListingRow(
                      l: l,
                      canDelete: me.role.deleteListings,
                      onView: () => Navigator.of(context)
                          .push(fadeRoute(ListingDetailScreen(l: l))),
                      onEdit: () => Navigator.of(context).push(
                          fadeRoute(ListingEditorScreen(existing: l))),
                      onDelete: () => _delete(l),
                      onStatus: (s) => _setStatus(l, s),
                    );
                  },
                  childCount: res.length,
                ),
              ),
            ),
          ]);
        });
      },
    );
  }
}

class _ListingRow extends StatelessWidget {
  final Listing l;
  final bool canDelete;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<String> onStatus;
  const _ListingRow({
    required this.l,
    required this.canDelete,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onStatus,
  });

  @override
  Widget build(BuildContext context) {
    final closed = l.offer == Offer.sale ? 'Sold' : 'Rented';
    return Panel(
      padding: const EdgeInsets.all(14),
      onTap: onEdit,
      child: Row(children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: kindColors(l)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(kindIcon(l), color: AppColors.orange, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('${l.id} • ${l.number} • ${l.location}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 11.5)),
                const SizedBox(height: 6),
                Row(children: [
                  Flexible(
                    child: Text(l.priceText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.peach,
                            fontSize: 14,
                            fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 8),
                  Pill(l.status, statusColor(l.status)),
                ]),
              ]),
        ),
        PopupMenuButton<String>(
          color: AppColors.card,
          shape: menuShape,
          icon: const Icon(Icons.more_vert_rounded, color: AppColors.muted),
          onSelected: (v) {
            switch (v) {
              case 'view':
                onView();
              case 'edit':
                onEdit();
              case 'delete':
                onDelete();
              default:
                onStatus(v);
            }
          },
          itemBuilder: (_) => [
            menuItem('view', Icons.visibility_outlined, 'View as client'),
            menuItem('edit', Icons.edit_outlined, 'Edit listing'),
            const PopupMenuDivider(),
            menuItem('Available', Icons.check_circle_outline_rounded,
                'Mark Available'),
            menuItem('Reserved', Icons.bookmark_added_outlined, 'Mark Reserved'),
            menuItem(closed, Icons.sell_outlined, 'Mark $closed'),
            if (canDelete) ...[
              const PopupMenuDivider(),
              menuItem('delete', Icons.delete_outline_rounded, 'Delete',
                  danger: true),
            ],
          ],
        ),
      ]),
    );
  }
}