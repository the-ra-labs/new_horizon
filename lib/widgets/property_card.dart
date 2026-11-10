import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/helpers.dart';
import 'press_scale.dart';

class Property {
  final String location;
  final String price;
  final String title;
  final String description;
  final int beds;
  final int baths;
  final String sqft;
  final String? image; // asset path, null = placeholder

  const Property({
    required this.location,
    required this.price,
    required this.title,
    required this.description,
    required this.beds,
    required this.baths,
    required this.sqft,
    this.image,
  });
}

class PropertyCard extends StatelessWidget {
  final Property property;
  final int index;
  final bool saved;
  final VoidCallback onSave;

  const PropertyCard({
    super.key,
    required this.property,
    required this.index,
    required this.saved,
    required this.onSave,
  });

  static const _cardColor = Color(0xFF1C1C1F);

  static const _palettes = [
    [Color(0xFF3A2A12), Color(0xFF14212E)],
    [Color(0xFF2E2415), Color(0xFF1B1B26)],
    [Color(0xFF332016), Color(0xFF12262A)],
  ];

  Future<void> _schedule(BuildContext context) async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.orange,
            onPrimary: Colors.black,
            surface: AppColors.card,
            onSurface: AppColors.text,
          ),
        ),
        child: child!,
      ),
    );
    if (d != null && context.mounted) {
      showToast(context, 'Viewing requested for ${d.day}/${d.month}/${d.year}');
    }
  }

  Widget _placeholder() {
    final p = _palettes[index % _palettes.length];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: p,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(Icons.villa_rounded,
            size: 72, color: Colors.white.withValues(alpha: 0.12)),
      ),
    );
  }

  Widget _image() {
    if (property.image == null) return _placeholder();
    return Image.asset(
      property.image!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _stat(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: AppColors.orange),
      const SizedBox(width: 6),
      Text(text,
          style: const TextStyle(
              color: AppColors.text,
              fontSize: 12,
              fontWeight: FontWeight.w700)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 180,
          child: Stack(fit: StackFit.expand, children: [
            _image(),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, _cardColor],
                  stops: [0.55, 1],
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.verified_rounded,
                      size: 12, color: AppColors.orange),
                  SizedBox(width: 5),
                  Text('EXCLUSIVE MANDATE',
                      style: TextStyle(
                        color: AppColors.orange,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      )),
                ]),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: PressScale(
                onTap: onSave,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (c, a) => ScaleTransition(
                        scale: CurvedAnimation(
                            parent: a, curve: Curves.easeOutBack),
                        child: c),
                    child: Icon(
                      saved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      key: ValueKey(saved),
                      size: 20,
                      color: saved ? AppColors.orange : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(property.location,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        )),
                  ),
                  const SizedBox(width: 8),
                  Text(property.price,
                      style: const TextStyle(
                        color: AppColors.peach,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      )),
                ],
              ),
              const SizedBox(height: 6),
              Text(property.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  )),
              const SizedBox(height: 4),
              Text(property.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.muted, fontSize: 12.5, height: 1.35)),
              const Spacer(),
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF141416),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(children: [
                    _stat(Icons.bed_outlined, '${property.beds} Beds'),
                    const SizedBox(width: 18),
                    _stat(Icons.bathtub_outlined, '${property.baths} Baths'),
                    const SizedBox(width: 18),
                    _stat(Icons.square_foot_rounded, '${property.sqft} sqft'),
                  ]),
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: PressScale(
                    scale: 0.97,
                    onTap: () => showToast(
                        context, 'Preparing dossier: ${property.title}'),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFFF7A10A), Color(0xFFD97706)]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.orange.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('Private Dossier',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              )),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_rounded,
                              size: 16, color: Colors.black),
                        ]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                PressScale(
                  onTap: () => _schedule(context),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2D),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.calendar_month_rounded,
                        color: AppColors.orange, size: 22),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ]),
    );
  }
}