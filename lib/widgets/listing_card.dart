import 'package:flutter/material.dart';
import '../data/listings.dart';
import '../data/stores.dart';
import '../theme/app_colors.dart';
import '../utils/helpers.dart';
import 'press_scale.dart';
import 'smart_image.dart';

List<Color> kindColors(Listing l) => switch (l.kind) {
  ListingKind.plot => const [Color(0xFF2B2A18), Color(0xFF16261D)],
  ListingKind.building => const [Color(0xFF2A2218), Color(0xFF1B1F2A)],
  ListingKind.plaza => const [Color(0xFF2E2415), Color(0xFF241B2A)],
  ListingKind.shop => const [Color(0xFF332016), Color(0xFF2A1B1B)],
  ListingKind.house => const [Color(0xFF3A2A12), Color(0xFF14212E)],
};

IconData kindIcon(Listing l) => switch (l.kind) {
  ListingKind.plot => Icons.terrain_rounded,
  ListingKind.building => Icons.apartment_rounded,
  ListingKind.plaza => Icons.domain_rounded,
  ListingKind.shop => Icons.storefront_rounded,
  ListingKind.house => l.subType == 'Villa'
      ? Icons.villa_rounded
      : (l.subType == 'Upper Portion'
      ? Icons.home_work_rounded
      : Icons.house_rounded),
};

// ---------------------------------------------------------------------
// PHOTO VARIETY
//
// Har category ki kitni photos `assets/images/categories/` mein hain,
// wo number yahan likho. Naming:
//   pehli photo : plot.jpg
//   baqi        : plot_2.jpg, plot_3.jpg ... plot_20.jpg
// Kam photos rakho to number kam kar do (0 = us category ke liye
// commercial_plot -> plot, upper -> house ki photos use hongi).
// ---------------------------------------------------------------------
const Map<String, int> kPhotoCounts = {
  'plot': 20, // Residential plot
  'commercial_plot': 20, // Commercial plot
  'building': 20,
  'plaza': 20,
  'shop': 20,
  'house': 20,
  'villa': 20,
  'upper': 20, // Upper portion
};

String photoKey(Listing l) => switch (l.kind) {
  ListingKind.plot => l.zone == 'Commercial' ? 'commercial_plot' : 'plot',
  ListingKind.building => 'building',
  ListingKind.plaza => 'plaza',
  ListingKind.shop => 'shop',
  ListingKind.house => l.subType == 'Villa'
      ? 'villa'
      : (l.subType == 'Upper Portion' ? 'upper' : 'house'),
};

/// Listing ki category aur us ki photos ki ginti
(String, int) _photoPool(Listing l) {
  var key = photoKey(l);
  var n = kPhotoCounts[key] ?? 0;
  if (n < 1) {
    key = key == 'commercial_plot' ? 'plot' : (key == 'upper' ? 'house' : key);
    n = kPhotoCounts[key] ?? 1;
  }
  return (key, n < 1 ? 1 : n);
}

String photoFolder(String key) => switch (key) {
      'plot' => 'Residential plot',
      'commercial_plot' => 'Commercial plot',
      'building' => 'Building',
      'plaza' => 'Plaza',
      'shop' => 'Shop',
      'house' => 'House',
      'villa' => 'Villa',
      _ => 'House',
    };

/// Har listing ki ID se ek fixed photo chunta hai (har bar wahi, random nahi)
String kindImage(Listing l) {
  final (key, n) = _photoPool(l);
  final folder = photoFolder(key);
  final hash = l.id.codeUnits.fold<int>(7, (a, c) => (a * 31 + c) & 0x7fffffff);
  final v = hash % n;
  return 'assets/images/categories/$folder/$key${v == 0 ? '' : '_${v + 1}'}.jpg';
}

/// Category ki pehli photo (jab koi photo file na mile to ye dikhti hai)
String kindBaseImage(Listing l) {
  final (key, _) = _photoPool(l);
  final folder = photoFolder(key);
  return 'assets/images/categories/$folder/$key.jpg';
}

/// Listing ka cover: gradient + photo (smart fit) + halka dark overlay
class CoverImage extends StatelessWidget {
  final Listing l;
  const CoverImage(this.l, {super.key});

  Widget _fallback() => Stack(fit: StackFit.expand, children: [
    DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: kindColors(l),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ),
    Align(
      alignment: Alignment.bottomRight,
      child: Icon(kindIcon(l),
          size: 100, color: Colors.white.withValues(alpha: 0.07)),
    ),
    // Variant file na ho to category ki pehli photo
    SmartImage.asset(
      kindBaseImage(l),
      alignment: const Alignment(0, 0.15),
    ),
  ]);

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      SmartImage.asset(
        kindImage(l),
        alignment: const Alignment(0, 0.15),
        fallback: _fallback(),
      ),
      const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x66000000), Colors.transparent, Color(0x99000000)],
          ),
        ),
      ),
    ]);
  }
}

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = status == 'Available' ? AppColors.success : AppColors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(status.toUpperCase(),
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            )),
      ]),
    );
  }
}

class SaveButton extends StatelessWidget {
  final String id;
  final double size;
  const SaveButton({super.key, required this.id, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: SavedStore.ids,
      builder: (_, ids, __) {
        final saved = ids.contains(id);
        return PressScale(
          onTap: () {
            final added = SavedStore.toggle(id);
            showToast(context, added ? 'Added to Saved' : 'Removed from Saved');
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (c, a) => ScaleTransition(
                  scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack),
                  child: c),
              child: Icon(
                saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                key: ValueKey(saved),
                size: 20,
                color: saved ? AppColors.orange : Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

class ListingCard extends StatelessWidget {
  /// Card ki kul height = imageHeight + bodyHeight
  static const double bodyHeight = 188;
  static const double height = 292; // purana naam (ab use nahi hota)

  final Listing l;
  final double imageHeight;
  final VoidCallback onTap;
  const ListingCard({
    super.key,
    required this.l,
    required this.onTap,
    this.imageHeight = 140,
  });

  List<(IconData, String)> _specs() {
    switch (l.kind) {
      case ListingKind.plot:
        return [
          (Icons.square_foot_rounded, l.sizeLabel),
          (Icons.straighten_rounded, '${commas(l.sqft)} sq ft'),
        ];
      case ListingKind.building:
      case ListingKind.plaza:
        return [
          (Icons.square_foot_rounded, l.sizeLabel),
          (Icons.layers_rounded, '${l.floors} Floors'),
        ];
      case ListingKind.shop:
        return [
          (Icons.square_foot_rounded, l.sizeLabel),
          (Icons.stairs_rounded, l.features.first),
        ];
      case ListingKind.house:
        return [
          (Icons.square_foot_rounded, l.sizeLabel),
          (Icons.bed_outlined, '${l.beds} Beds'),
          (Icons.bathtub_outlined, '${l.baths} Baths'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return PressScale(
      scale: 0.98,
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF242427),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: imageHeight,
            child: Stack(fit: StackFit.expand, children: [
              CoverImage(l),
              Positioned(top: 10, left: 10, child: StatusChip(l.status)),
              Positioned(top: 8, right: 8, child: SaveButton(id: l.id)),
              Positioned(
                bottom: 10,
                left: 12,
                child: Row(children: [
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(l.offerLabel.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.orange,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        )),
                  ),
                  const SizedBox(width: 8),
                  Text(l.id,
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ]),
              ),
            ]),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        )),
                    const SizedBox(height: 2),
                    Text('${l.number} • ${l.location}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12)),
                    const SizedBox(height: 8),
                    Text(l.priceText,
                        style: const TextStyle(
                          color: AppColors.peach,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        )),
                    const Spacer(),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(children: [
                        for (final s in _specs()) ...[
                          Icon(s.$1, size: 15, color: AppColors.orange),
                          const SizedBox(width: 5),
                          Text(s.$2,
                              style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(width: 14),
                        ],
                      ]),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF18181A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('View Details',
                              style: TextStyle(
                                color: AppColors.orange,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              )),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_rounded,
                              size: 16, color: AppColors.orange),
                        ]),
                      ),
                    ),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }
}