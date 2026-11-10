import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/listings.dart';
import '../data/staff_data.dart';
import '../theme/app_colors.dart';
import '../utils/helpers.dart';
import '../widgets/auth_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/press_scale.dart';
import '../widgets/staff_ui.dart';

class ListingEditorScreen extends StatefulWidget {
  final Listing? existing;
  const ListingEditorScreen({super.key, this.existing});

  @override
  State<ListingEditorScreen> createState() => _ListingEditorScreenState();
}

class _ListingEditorScreenState extends State<ListingEditorScreen> {
  static const _kinds = {
    'Plot': ListingKind.plot,
    'Building': ListingKind.building,
    'Plaza': ListingKind.plaza,
    'Shop': ListingKind.shop,
    'House': ListingKind.house,
  };
  static const _marlaChips = ['3', '5', '7', '10', '20', '40'];
  static const _blocks = [
    'Block A', 'Block B', 'Block C', 'Block D', 'Block E', 'Block F',
  ];

  late ListingKind _kind;
  late Offer _offer;
  String _zone = 'Residential';
  String _houseType = 'House';
  int _phase = 1;
  String _block = 'Block A';
  String _status = 'Available';
  int _beds = 3;
  int _baths = 3;
  int _floors = 2;

  final _number = TextEditingController();
  final _size = TextEditingController();
  final _price = TextEditingController();
  final _features = TextEditingController();
  String? _numErr, _sizeErr, _priceErr;

  bool get _isShop => _kind == ListingKind.shop;
  bool get _isHouse => _kind == ListingKind.house;

  String _num(double d) => d % 1 == 0 ? d.toInt().toString() : d.toString();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e == null) {
      _kind = ListingKind.plot;
      _offer = Offer.sale;
    } else {
      _kind = e.kind;
      _offer = e.offer;
      _zone = e.zone;
      _houseType = e.kind == ListingKind.house ? e.subType : 'House';
      _phase = e.phase;
      _block = e.block;
      _status = e.status;
      _beds = e.beds > 0 ? e.beds : 3;
      _baths = e.baths > 0 ? e.baths : 3;
      _floors = e.floors > 0 ? e.floors : 2;
      _number.text = e.number;
      _size.text = e.kind == ListingKind.shop ? '${e.sqft}' : _num(e.marla);
      _price.text = '${e.price}';
      _features.text = e.features.join(', ');
    }
  }

  @override
  void dispose() {
    _number.dispose();
    _size.dispose();
    _price.dispose();
    _features.dispose();
    super.dispose();
  }

  List<String> get _statusOptions =>
      ['Available', 'Reserved', _offer == Offer.sale ? 'Sold' : 'Rented'];

  void _setOffer(Offer o) {
    setState(() {
      _offer = o;
      if (_status == 'Sold' || _status == 'Rented') {
        _status = o == Offer.sale ? 'Sold' : 'Rented';
      }
    });
  }

  Future<bool> _save() async {
    final n = _number.text.trim();
    final sz = double.tryParse(_size.text.trim());
    final pr = int.tryParse(_price.text.trim());
    setState(() {
      _numErr = n.isEmpty ? 'Unit name is required' : null;
      _sizeErr = (sz == null || sz <= 0) ? 'Enter a valid size' : null;
      _priceErr = (pr == null || pr <= 0) ? 'Enter a valid price' : null;
    });
    if (_numErr != null || _sizeErr != null || _priceErr != null) {
      HapticFeedback.mediumImpact();
      return false;
    }
    await Future.delayed(const Duration(milliseconds: 700));

    final marla = _isShop ? sz! / marlaSqft : sz!;
    final sqft = _isShop ? sz.round() : (sz * marlaSqft).round();
    final zone = switch (_kind) {
      ListingKind.plot => _zone,
      ListingKind.house => 'Residential',
      _ => 'Commercial',
    };
    final subType = switch (_kind) {
      ListingKind.plot => '$_zone Plot',
      ListingKind.building => 'Building',
      ListingKind.plaza => 'Plaza',
      ListingKind.shop => 'Shop',
      ListingKind.house => _houseType,
    };
    var feats = _features.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (feats.isEmpty) feats = ['Standard'];

    final l = Listing(
      id: widget.existing?.id ?? ListingStore.newId(_kind),
      kind: _kind,
      subType: subType,
      zone: zone,
      phase: _phase,
      block: _block,
      number: n,
      marla: marla,
      sqft: sqft,
      price: pr!,
      offer: _offer,
      beds: _isHouse ? _beds : 0,
      baths: _isHouse ? _baths : 0,
      floors: (_isHouse ||
          _kind == ListingKind.building ||
          _kind == ListingKind.plaza)
          ? _floors
          : 0,
      features: feats,
      status: _status,
    );

    final actor = Session.staff!.name;
    if (widget.existing == null) {
      ListingStore.add(l);
      ActivityStore.log(actor, 'added listing ${l.id}');
    } else {
      ListingStore.update(l);
      ActivityStore.log(actor, 'updated listing ${l.id}');
    }
    return true;
  }

  Widget _group(String title, List<Widget> children) {
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(title,
            style: const TextStyle(
                color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          children[i],
        ],
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    final sizeLabel = _isShop ? 'Size (sq ft)' : 'Size (marla)';
    final prefix = _kinds.entries.firstWhere((e) => e.value == _kind).key;

    return StaffPage(
      caption: editing ? widget.existing!.id : 'New listing',
      title: editing ? 'Edit Listing' : 'Add Listing',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _group('Basics', [
            ChipSelect(
              label: 'Type',
              options: _kinds.keys.toList(),
              selected: prefix,
              onChanged: (v) => setState(() => _kind = _kinds[v]!),
            ),
            if (_kind == ListingKind.plot)
              ChipSelect(
                label: 'Zone',
                options: const ['Residential', 'Commercial'],
                selected: _zone,
                onChanged: (v) => setState(() => _zone = v),
              ),
            if (_isHouse)
              ChipSelect(
                label: 'House type',
                options: const ['House', 'Villa', 'Upper Portion'],
                selected: _houseType,
                onChanged: (v) => setState(() => _houseType = v),
              ),
            ChipSelect(
              label: 'Offer',
              options: const ['For Sale', 'For Rent'],
              selected: _offer == Offer.sale ? 'For Sale' : 'For Rent',
              onChanged: (v) => _setOffer(v == 'For Sale' ? Offer.sale : Offer.rent),
            ),
          ]),
          const SizedBox(height: 14),
          _group('Location', [
            ChipSelect(
              label: 'Phase',
              options: const ['Phase 1', 'Phase 2', 'Phase 3', 'Phase 4'],
              selected: 'Phase $_phase',
              onChanged: (v) => setState(() => _phase = int.parse(v.split(' ').last)),
            ),
            ChipSelect(
              label: 'Block',
              options: _blocks,
              selected: _block,
              onChanged: (v) => setState(() => _block = v),
            ),
            AuthField(
              label: 'Unit name',
              hint: '$prefix 245',
              icon: Icons.tag_rounded,
              controller: _number,
              errorText: _numErr,
              onChanged: (_) => setState(() => _numErr = null),
            ),
          ]),
          const SizedBox(height: 14),
          _group('Size & Price', [
            if (!_isShop)
              ChipSelect(
                label: 'Quick size (20 = 1 Kanal)',
                options: _marlaChips,
                selected: _size.text.trim(),
                onChanged: (v) => setState(() {
                  _size.text = v;
                  _sizeErr = null;
                }),
              ),
            AuthField(
              label: sizeLabel,
              hint: _isShop ? '400' : '10',
              icon: Icons.square_foot_rounded,
              controller: _size,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              errorText: _sizeErr,
              onChanged: (_) => setState(() => _sizeErr = null),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AuthField(
                label: _offer == Offer.sale ? 'Price (PKR)' : 'Monthly rent (PKR)',
                hint: '25000000',
                icon: Icons.payments_outlined,
                controller: _price,
                keyboardType: TextInputType.number,
                errorText: _priceErr,
                onChanged: (_) => setState(() => _priceErr = null),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text(fmtPkr(int.tryParse(_price.text.trim()) ?? 0),
                    style: const TextStyle(
                        color: AppColors.peach,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
            ]),
          ]),
          if (_isHouse || _kind == ListingKind.building || _kind == ListingKind.plaza) ...[
            const SizedBox(height: 14),
            _group('Specs', [
              if (_isHouse) ...[
                _Stepper('Bedrooms', _beds, 1, 12, (v) => setState(() => _beds = v)),
                _Stepper('Bathrooms', _baths, 1, 12, (v) => setState(() => _baths = v)),
              ],
              _Stepper('Floors', _floors, 1, 20, (v) => setState(() => _floors = v)),
            ]),
          ],
          const SizedBox(height: 14),
          _group('Features & Status', [
            AuthField(
              label: 'Features (comma separated)',
              hint: 'Corner, Park Facing, Possession Ready',
              icon: Icons.auto_awesome_rounded,
              controller: _features,
            ),
            ChipSelect(
              label: 'Status',
              options: _statusOptions,
              selected: _status,
              onChanged: (v) => setState(() => _status = v),
            ),
          ]),
          const SizedBox(height: 20),
          GradientButton(
            label: editing ? 'Save Changes' : 'Publish Listing',
            icon: Icons.check_rounded,
            onPressed: _save,
            onSuccess: () {
              showToast(context, editing ? 'Listing updated' : 'Listing published');
              Navigator.of(context).pop();
            },
          ),
        ]),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  const _Stepper(this.label, this.value, this.min, this.max, this.onChanged);

  Widget _btn(IconData icon, VoidCallback onTap) => PressScale(
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

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 14)),
      const Spacer(),
      _btn(Icons.remove_rounded, () => onChanged(value > min ? value - 1 : value)),
      SizedBox(
        width: 44,
        child: Text('$value',
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w800)),
      ),
      _btn(Icons.add_rounded, () => onChanged(value < max ? value + 1 : value)),
    ]);
  }
}