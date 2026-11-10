import 'dart:math';

const marlaSqft = 272.25; // 1 marla (standard). 1 kanal = 20 marla

enum ListingKind { plot, building, plaza, shop, house }

enum Offer { sale, rent }

String commas(int n) {
  final s = n.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return (n < 0 ? '-' : '') + b.toString();
}

String _trim(double d) =>
    d.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');

String fmtPkr(num v) {
  if (v >= 10000000) return 'PKR ${_trim(v / 10000000)} Crore';
  if (v >= 100000) return 'PKR ${_trim(v / 100000)} Lakh';
  return 'PKR ${commas(v.round())}';
}

const phaseInfo = {
  1: 'Fully developed • Possession ready',
  2: 'Developed • Utilities complete',
  3: 'Development in progress',
  4: 'New launch • Easy installment plans',
};

class Listing {
  final String id;
  final ListingKind kind;
  final String subType;
  final String zone; // Residential | Commercial
  final int phase;
  final String block;
  final String number;
  final double marla;
  final int sqft;
  final int price; // sale price ya monthly rent
  final Offer offer;
  final int beds;
  final int baths;
  final int floors;
  final List<String> features;
  final String status;

  Listing({
    required this.id,
    required this.kind,
    required this.subType,
    required this.zone,
    required this.phase,
    required this.block,
    required this.number,
    required this.marla,
    required this.sqft,
    required this.price,
    required this.offer,
    required this.beds,
    required this.baths,
    required this.floors,
    required this.features,
    required this.status,
  });

  Listing copyWith({
    ListingKind? kind,
    String? subType,
    String? zone,
    int? phase,
    String? block,
    String? number,
    double? marla,
    int? sqft,
    int? price,
    Offer? offer,
    int? beds,
    int? baths,
    int? floors,
    List<String>? features,
    String? status,
  }) =>
      Listing(
        id: id,
        kind: kind ?? this.kind,
        subType: subType ?? this.subType,
        zone: zone ?? this.zone,
        phase: phase ?? this.phase,
        block: block ?? this.block,
        number: number ?? this.number,
        marla: marla ?? this.marla,
        sqft: sqft ?? this.sqft,
        price: price ?? this.price,
        offer: offer ?? this.offer,
        beds: beds ?? this.beds,
        baths: baths ?? this.baths,
        floors: floors ?? this.floors,
        features: features ?? this.features,
        status: status ?? this.status,
      );

  String get sizeLabel {
    if (kind == ListingKind.shop) return '$sqft sq ft';
    if (marla == 20) return '1 Kanal';
    if (marla == 40) return '2 Kanal';
    return '${marla.toStringAsFixed(marla % 1 == 0 ? 0 : 1)} Marla';
  }

  String get phaseLabel => 'Phase $phase';
  String get location => '$block • $phaseLabel';
  String get offerLabel => offer == Offer.sale ? 'For Sale' : 'For Rent';

  String get kindLabel => switch (kind) {
    ListingKind.plot => 'Plot',
    ListingKind.building => 'Building',
    ListingKind.plaza => 'Plaza',
    ListingKind.shop => 'Shop',
    ListingKind.house => 'House',
  };

  String get title {
    switch (kind) {
      case ListingKind.plot:
        return '$sizeLabel $zone Plot';
      case ListingKind.building:
        return '$sizeLabel Commercial Building';
      case ListingKind.plaza:
        return '$sizeLabel Plaza';
      case ListingKind.shop:
        return '$sizeLabel Shop';
      case ListingKind.house:
        return '$sizeLabel $subType';
    }
  }

  String get priceText =>
      offer == Offer.rent ? 'PKR ${commas(price)} /mo' : fmtPkr(price);

  late final String haystack = [
    title,
    sizeLabel,
    '${marla.toStringAsFixed(0)} marla',
    if (marla >= 20) 'kanal',
    phaseLabel,
    'p$phase',
    block,
    number,
    kindLabel,
    subType,
    zone,
    offerLabel,
    ...features,
    if (beds > 0) '$beds bed',
    id,
    status,
    priceText,
  ].join(' ').toLowerCase();

  /// Search token match (numbers poore word ki tarah match hote hain)
  bool matches(String t) {
    if (RegExp(r'^\d+$').hasMatch(t)) {
      return RegExp('\\b$t\\b').hasMatch(haystack);
    }
    return haystack.contains(t);
  }
}

String describe(Listing l) {
  final feats = l.features.take(3).join(', ').toLowerCase();
  switch (l.kind) {
    case ListingKind.plot:
      return 'A ${l.sizeLabel} ${l.zone.toLowerCase()} plot (${commas(l.sqft)} sq ft) in ${l.block}, ${l.phaseLabel}. Highlights: $feats. Ideal for ${l.zone == 'Residential' ? 'building a custom family home' : 'a showroom, office or mixed-use project'}.';
    case ListingKind.building:
      return 'A ${l.floors}-floor commercial building on a ${l.sizeLabel} footprint in ${l.block}, ${l.phaseLabel}. Highlights: $feats. Suited to offices, brands and rental-income investors.';
    case ListingKind.plaza:
      return 'A ${l.floors}-storey plaza on ${l.sizeLabel} in ${l.block}, ${l.phaseLabel}, planned for retail and office use. Highlights: $feats.';
    case ListingKind.shop:
      return 'A ${l.sizeLabel} shop in ${l.block}, ${l.phaseLabel} with strong footfall potential. Highlights: $feats.';
    case ListingKind.house:
      return 'A ${l.sizeLabel} ${l.subType.toLowerCase()} with ${l.beds} bedrooms and ${l.baths} bathrooms across ${l.floors} ${l.floors == 1 ? 'floor' : 'floors'} in ${l.block}, ${l.phaseLabel}. Highlights: $feats. Available ${l.offer == Offer.sale ? 'for sale' : 'for rent'}.';
  }
}

// ---------------- SAMPLE DATA (baad mein backend se aayega) ----------------

final List<Listing> allListings = _generate();

List<Listing> _generate() {
  final r = Random(11);
  final out = <Listing>[];
  var seq = 1000;

  const phases = [1, 2, 3, 4];
  const ppm = <int, int>{1: 4200000, 2: 3600000, 3: 2900000, 4: 2300000};
  const psf = <int, int>{1: 62000, 2: 50000, 3: 40000, 4: 32000};
  const blocks = ['Block A', 'Block B', 'Block C', 'Block D', 'Block E', 'Block F'];
  const statuses = ['Available', 'Available', 'Available', 'Reserved'];

  String blk() => blocks[r.nextInt(blocks.length)];
  String status() => statuses[r.nextInt(statuses.length)];
  List<String> pick(List<String> src, int n) =>
      ([...src]..shuffle(r)).take(n).toList();
  int round(num v, int step) => ((v / step).round() * step).toInt();
  int sqftOf(double m) => (m * marlaSqft).round();
  String id(String p) => 'NH-$p-${seq++}';

  // Residential plots
  const resFeatures = [
    'Corner', 'Park Facing', 'Boulevard', 'Main Road',
    'Possession Ready', 'Installments', 'Near Mosque', 'Near Commercial',
  ];
  for (final ph in phases) {
    for (final m in const [3.0, 5.0, 7.0, 10.0, 20.0, 40.0]) {
      for (var k = 0; k < 2; k++) {
        final f = pick(resFeatures, 2 + r.nextInt(2));
        final bump = (f.contains('Corner') ? 1.07 : 1.0) *
            (f.contains('Park Facing') ? 1.04 : 1.0);
        out.add(Listing(
          id: id('P'),
          kind: ListingKind.plot,
          subType: 'Residential Plot',
          zone: 'Residential',
          phase: ph,
          block: blk(),
          number: 'Plot ${100 + r.nextInt(400)}',
          marla: m,
          sqft: sqftOf(m),
          price: round(m * ppm[ph]! * bump, 50000),
          offer: Offer.sale,
          beds: 0,
          baths: 0,
          floors: 0,
          features: f,
          status: status(),
        ));
      }
    }
  }

  // Commercial plots
  const comFeatures = [
    'Main Boulevard', 'Corner', 'Possession Ready',
    'Installments', 'High Footfall', 'Mixed-Use Zone',
  ];
  for (final ph in phases) {
    for (final m in const [4.0, 8.0, 20.0]) {
      for (var k = 0; k < 2; k++) {
        final f = pick(comFeatures, 2 + r.nextInt(2));
        final bump = f.contains('Corner') ? 1.08 : 1.0;
        out.add(Listing(
          id: id('P'),
          kind: ListingKind.plot,
          subType: 'Commercial Plot',
          zone: 'Commercial',
          phase: ph,
          block: blk(),
          number: 'Plot ${10 + r.nextInt(90)}',
          marla: m,
          sqft: sqftOf(m),
          price: round(m * ppm[ph]! * 2.4 * bump, 100000),
          offer: Offer.sale,
          beds: 0,
          baths: 0,
          floors: 0,
          features: f,
          status: status(),
        ));
      }
    }
  }

  // Buildings
  const bFeatures = [
    'Brand New', 'Lift Ready', 'Basement Parking',
    'Rental Income', 'Corner', 'Fire Safety',
  ];
  for (final ph in phases) {
    for (final m in const [4.0, 8.0, 20.0]) {
      final fl = m <= 4 ? 3 : (m <= 8 ? 4 : 6);
      out.add(Listing(
        id: id('B'),
        kind: ListingKind.building,
        subType: 'Building',
        zone: 'Commercial',
        phase: ph,
        block: blk(),
        number: 'Building ${10 + r.nextInt(90)}',
        marla: m,
        sqft: sqftOf(m),
        price: round(m * ppm[ph]! * 2.4 + fl * m * 1600000, 500000),
        offer: Offer.sale,
        beds: 0,
        baths: 0,
        floors: fl,
        features: pick(bFeatures, 3),
        status: status(),
      ));
    }
  }

  // Plazas
  const pzFeatures = [
    'Shops + Offices', 'Food Court', 'Lift & Escalator',
    'Basement Parking', 'Fire Safety', 'Anchor Tenants',
  ];
  for (final ph in phases) {
    for (final m in const [20.0, 40.0]) {
      final fl = m == 20 ? 6 : 8;
      out.add(Listing(
        id: id('PZ'),
        kind: ListingKind.plaza,
        subType: 'Plaza',
        zone: 'Commercial',
        phase: ph,
        block: blk(),
        number: 'Plaza ${1 + r.nextInt(30)}',
        marla: m,
        sqft: sqftOf(m),
        price: round(m * ppm[ph]! * 2.8 + fl * m * 1200000, 1000000),
        offer: Offer.sale,
        beds: 0,
        baths: 0,
        floors: fl,
        features: pick(pzFeatures, 3),
        status: status(),
      ));
    }
  }

  // Shops
  const shopFeatures = [
    'Main Boulevard', 'Corner Shop', 'Rented',
    'Possession Ready', 'Installments', 'Glass Frontage',
  ];
  for (final ph in phases) {
    for (final s in const [200, 400, 800]) {
      for (var k = 0; k < 2; k++) {
        final ground = k == 0;
        out.add(Listing(
          id: id('S'),
          kind: ListingKind.shop,
          subType: 'Shop',
          zone: 'Commercial',
          phase: ph,
          block: blk(),
          number: 'Shop ${1 + r.nextInt(120)}',
          marla: s / marlaSqft,
          sqft: s,
          price: round(s * psf[ph]! * (ground ? 1.0 : 0.65), 50000),
          offer: Offer.sale,
          beds: 0,
          baths: 0,
          floors: 0,
          features: [ground ? 'Ground Floor' : 'First Floor', ...pick(shopFeatures, 2)],
          status: status(),
        ));
      }
    }
  }

  // Houses (sale + rent)
  const hFeatures = [
    'Brand New', 'Corner', 'Park Facing', 'Servant Quarter', 'Solar Ready',
    'Gated Street', 'Imported Fittings', 'Double Unit', 'Basement',
  ];
  const bedsFor = <int, int>{3: 3, 5: 4, 7: 5, 10: 5, 20: 6, 40: 7};
  const specs = [
    ('House', [3.0, 5.0, 7.0, 10.0]),
    ('Villa', [10.0, 20.0, 40.0]),
    ('Upper Portion', [5.0, 10.0]),
  ];
  var h = 0;
  for (final ph in phases) {
    for (final spec in specs) {
      for (final m in spec.$2) {
        h++;
        final type = spec.$1;
        final upper = type == 'Upper Portion';
        final unit = type == 'Villa'
            ? (ppm[ph]! + 4200000) * 1.05
            : (ppm[ph]! + 3000000).toDouble();
        final value = m * unit * (upper ? 0.45 : 1.0);
        final bd = upper ? (m <= 5 ? 2 : 3) : bedsFor[m.toInt()]!;
        final fl = upper ? 1 : (m >= 20 ? 3 : 2);
        final f = pick(hFeatures, 3);

        void add(Offer o) {
          out.add(Listing(
            id: id('H'),
            kind: ListingKind.house,
            subType: type,
            zone: 'Residential',
            phase: ph,
            block: blk(),
            number: 'House ${10 + r.nextInt(300)}',
            marla: m,
            sqft: sqftOf(m),
            price: o == Offer.sale ? round(value, 100000) : round(value * 0.0032, 5000),
            offer: o,
            beds: bd,
            baths: bd,
            floors: fl,
            features: f,
            status: status(),
          ));
        }

        if (!upper) add(Offer.sale);
        if (upper || h.isEven) add(Offer.rent);
      }
    }
  }
  return out;
}