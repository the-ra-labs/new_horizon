import 'package:flutter/material.dart';
import '../data/listings.dart';
import '../widgets/step_menu.dart';
import 'listings_screen.dart';

/// Land & Plots: Type -> Phase -> Size
class LandPlotsScreen extends StatelessWidget {
  const LandPlotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListingsScreen(
      caption: 'Prime Land',
      title: 'Land & Plots',
      banner:
      'Residential and commercial plots, phase by phase. Search by marla, kanal, phase or block.',
      searchHint: 'Try "10 marla phase 2" or "corner"',
      base: (l) => l.kind == ListingKind.plot,
      steps: [
        MenuStep('Type', (l) => l.zone, (l) => l.zone == 'Residential' ? 0 : 1),
        MenuStep('Phase', (l) => l.phaseLabel, (l) => l.phase),
        MenuStep('Plot Size', (l) => l.sizeLabel, (l) => l.sqft),
      ],
    );
  }
}

/// Commercial: Category -> Phase -> Size
class CommercialScreen extends StatelessWidget {
  const CommercialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListingsScreen(
      caption: 'Towers & Yields',
      title: 'Commercial',
      banner:
      'Commercial plots, buildings, plazas and shops. Pick a category, then phase and size.',
      searchHint: 'Try "shop phase 1" or "8 marla building"',
      base: (l) => l.zone == 'Commercial',
      steps: [
        MenuStep('Category', (l) => l.kindLabel, (l) => l.kind.index),
        MenuStep('Phase', (l) => l.phaseLabel, (l) => l.phase),
        MenuStep('Size', (l) => l.sizeLabel, (l) => l.sqft),
      ],
    );
  }
}

/// Houses: Offer -> Type -> Phase -> Size
class HousesScreen extends StatelessWidget {
  const HousesScreen({super.key});

  static const _typeOrder = {'House': 0, 'Villa': 1, 'Upper Portion': 2};

  @override
  Widget build(BuildContext context) {
    return ListingsScreen(
      caption: 'Homes for sale & rent',
      title: 'Houses',
      banner:
      'Houses, villas and upper portions. Choose For Sale or For Rent, then type, phase and size.',
      searchHint: 'Try "5 marla for rent" or "4 bed"',
      base: (l) => l.kind == ListingKind.house,
      steps: [
        MenuStep('Offer', (l) => l.offerLabel, (l) => l.offer.index),
        MenuStep('Type', (l) => l.subType, (l) => _typeOrder[l.subType] ?? 9),
        MenuStep('Phase', (l) => l.phaseLabel, (l) => l.phase),
        MenuStep('Size', (l) => l.sizeLabel, (l) => l.sqft),
      ],
    );
  }
}