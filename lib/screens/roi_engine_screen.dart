import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/listings.dart';
import '../theme/app_colors.dart';
import '../widgets/animated_tab_switch.dart';
import '../widgets/fade_slide.dart';
import '../widgets/press_scale.dart';
import '../widgets/sub_shell.dart';

class _Calc {
  final double price, downPct, rate, years, growth, yieldPct, expPct;
  final int horizon;
  _Calc({
    required this.price,
    required this.downPct,
    required this.rate,
    required this.years,
    required this.growth,
    required this.yieldPct,
    required this.expPct,
    required this.horizon,
  });

  double get down => price * downPct / 100;
  double get loan => price - down;
  double get r => rate / 1200;
  int get n => (years * 12).round();

  double get emi {
    if (loan <= 0 || n <= 0) return 0;
    if (r == 0) return loan / n;
    final f = pow(1 + r, n).toDouble();
    return loan * r * f / (f - 1);
  }

  double get annualRent => price * yieldPct / 100;
  double get netRent => annualRent * (1 - expPct / 100);
  double get annualDebt => emi * 12;
  double get cashFlow => netRent - annualDebt;
  double get netYield => price == 0 ? 0 : netRent / price * 100;
  double get coc => down == 0 ? 0 : cashFlow / down * 100;
  double? get dscr => annualDebt == 0 ? null : netRent / annualDebt;
  double get totalInterest => emi * n - loan;

  double valueAt(int t) => price * pow(1 + growth / 100, t).toDouble();

  double balanceAfter(int months) {
    if (loan <= 0) return 0;
    final p = min(months, n);
    if (r == 0) return loan * (1 - p / n);
    final fn = pow(1 + r, n).toDouble();
    final fp = pow(1 + r, p).toDouble();
    return loan * (fn - fp) / (fn - 1);
  }

  double equityAt(int t) => valueAt(t) - balanceAfter(t * 12);
  double get cumCash => cashFlow * horizon;
  double get totalReturn => equityAt(horizon) + cumCash - down;
  double get roi => down == 0 ? 0 : totalReturn / down * 100;

  double get annualized {
    final end = equityAt(horizon) + cumCash;
    if (end <= 0 || down <= 0 || horizon == 0) return -100;
    return (pow(end / down, 1 / horizon).toDouble() - 1) * 100;
  }
}

String _pct(double v) => '${v.toStringAsFixed(1)}%';

class RoiEngineScreen extends StatefulWidget {
  const RoiEngineScreen({super.key});

  @override
  State<RoiEngineScreen> createState() => _RoiEngineScreenState();
}

class _RoiEngineScreenState extends State<RoiEngineScreen> {
  double _price = 50000000;
  double _down = 30;
  double _rate = 12;
  double _years = 15;
  double _growth = 8;
  double _yield = 5;
  double _exp = 10;
  double _horizon = 10;
  bool _yieldTab = true;
  final _priceCtl = TextEditingController(text: '50000000');

  @override
  void dispose() {
    _priceCtl.dispose();
    super.dispose();
  }

  _Calc get _c => _Calc(
    price: _price,
    downPct: _down,
    rate: _rate,
    years: _years,
    growth: _growth,
    yieldPct: _yield,
    expPct: _exp,
    horizon: _horizon.round(),
  );

  void _setPrice(double v) {
    setState(() => _price = v);
    _priceCtl.text = v.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    return SubShell(
      caption: 'Yield & debt models',
      title: 'ROI Engine',
      body: LayoutBuilder(builder: (context, box) {
        final wide = box.maxWidth >= 900;
        final inputs = FadeSlide(child: _inputs());
        final results = FadeSlide(delayMs: 100, child: _results(c));
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          child: wide
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 5, child: inputs),
            const SizedBox(width: 20),
            Expanded(flex: 6, child: results),
          ])
              : Column(children: [inputs, const SizedBox(height: 20), results]),
        );
      }),
    );
  }

  Widget _card(Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFF1C1C1F),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
    ),
    child: child,
  );

  Widget _inputs() {
    return _card(
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Investment Inputs',
            style: TextStyle(
                color: AppColors.text,
                fontSize: 17,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        const Text('PROPERTY PRICE (PKR)',
            style: TextStyle(
                color: AppColors.text,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1)),
        const SizedBox(height: 8),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(children: [
            const Icon(Icons.payments_outlined,
                size: 20, color: AppColors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _priceCtl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                cursorColor: AppColors.orange,
                style: const TextStyle(color: AppColors.text, fontSize: 16),
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero),
                onChanged: (v) {
                  final p = double.tryParse(v);
                  if (p != null && p > 0) setState(() => _price = p);
                },
              ),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        Text(fmtPkr(_price),
            style: const TextStyle(
                color: AppColors.peach,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final p in const [20000000.0, 50000000.0, 100000000.0, 250000000.0])
            PressScale(
              scale: 0.94,
              onTap: () => _setPrice(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  gradient: _price == p ? AppColors.gradient : null,
                  color: _price == p ? null : AppColors.field,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: _price == p
                          ? Colors.transparent
                          : AppColors.border),
                ),
                child: Text(fmtPkr(p).replaceFirst('PKR ', ''),
                    style: TextStyle(
                        color: _price == p ? Colors.black : AppColors.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ),
        ]),
        const SizedBox(height: 12),
        _SliderRow('Down payment', '${_down.round()}%', _down, 10, 100, 18,
                (v) => setState(() => _down = v)),
        _SliderRow('Loan interest (annual)', _pct(_rate), _rate, 0, 25, 50,
                (v) => setState(() => _rate = v)),
        _SliderRow('Loan tenure', '${_years.round()} yrs', _years, 1, 30, 29,
                (v) => setState(() => _years = v)),
        _SliderRow('Rental yield (gross)', _pct(_yield), _yield, 1, 12, 22,
                (v) => setState(() => _yield = v)),
        _SliderRow('Expenses (% of rent)', '${_exp.round()}%', _exp, 0, 40, 40,
                (v) => setState(() => _exp = v)),
        _SliderRow('Annual appreciation', _pct(_growth), _growth, 0, 20, 40,
                (v) => setState(() => _growth = v)),
        _SliderRow('Holding period', '${_horizon.round()} yrs', _horizon, 1, 20,
            19, (v) => setState(() => _horizon = v)),
      ]),
    );
  }

  Widget _results(_Calc c) {
    final dscr = c.dscr;
    final yieldMetrics = [
      ('Gross Rental Yield', _pct(_yield), 'Before expenses'),
      ('Net Rental Yield', _pct(c.netYield), 'After expenses'),
      ('Annual Net Rent', fmtPkr(c.netRent), 'Per year'),
      ('Annual Cash Flow', fmtPkr(c.cashFlow), 'After loan payments'),
      ('Cash-on-Cash', _pct(c.coc), 'On down payment'),
    ];
    final debtMetrics = [
      ('Monthly Installment', fmtPkr(c.emi), 'EMI'),
      ('Loan Amount', fmtPkr(c.loan), '${_pct(100 - _down)} of price'),
      ('Total Interest', fmtPkr(c.totalInterest), 'Over full tenure'),
      (
      'Coverage (DSCR)',
      dscr == null ? 'No debt' : dscr.toStringAsFixed(2),
      dscr == null
          ? ''
          : (dscr >= 1.25
          ? 'Healthy'
          : (dscr >= 1 ? 'Tight' : 'Rent < installment')),
      ),
      (
      'Balance at Year ${_horizon.round()}',
      fmtPkr(c.balanceAfter(_horizon.round() * 12)),
      'Remaining loan',
      ),
    ];
    final metrics = _yieldTab ? yieldMetrics : debtMetrics;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AnimatedTabSwitch(
        isLeft: _yieldTab,
        left: 'Yield Model',
        right: 'Debt Model',
        onChanged: (v) => setState(() => _yieldTab = v),
      ),
      const SizedBox(height: 14),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: LayoutBuilder(
          key: ValueKey(_yieldTab),
          builder: (context, box) {
            final w = (box.maxWidth - 10) / 2;
            return Wrap(spacing: 10, runSpacing: 10, children: [
              for (final m in metrics)
                SizedBox(width: w, child: _Metric(m.$1, m.$2, m.$3)),
            ]);
          },
        ),
      ),
      const SizedBox(height: 14),
      _card(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Projection • ${_horizon.round()} years',
              style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          SizedBox(
            height: 170,
            width: double.infinity,
            child: CustomPaint(painter: _ChartPainter(c)),
          ),
          const SizedBox(height: 8),
          Row(children: [
            _legend(AppColors.peach, 'Property value'),
            const SizedBox(width: 16),
            _legend(AppColors.orange, 'Your equity'),
          ]),
          const SizedBox(height: 16),
          _line('Projected value', fmtPkr(c.valueAt(_horizon.round()))),
          _line('Equity at exit', fmtPkr(c.equityAt(_horizon.round()))),
          _line('Cumulative cash flow', fmtPkr(c.cumCash)),
          const Divider(color: AppColors.border, height: 22),
          _line('Total return', fmtPkr(c.totalReturn), hi: true),
          _line('Total ROI', _pct(c.roi), hi: true),
          _line('Annualized return', _pct(c.annualized), hi: true),
        ]),
      ),
      const SizedBox(height: 12),
      if (c.cashFlow < 0)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
          ),
          child: const Row(children: [
            Icon(Icons.warning_amber_rounded,
                size: 18, color: AppColors.error),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Rent does not cover loan payments. A larger down payment or longer tenure improves cash flow.',
                style: TextStyle(
                    color: AppColors.text, fontSize: 12.5, height: 1.4),
              ),
            ),
          ]),
        ),
      const SizedBox(height: 12),
      const Text(
        'Illustrative estimates only, based on the inputs above. Not financial advice. Rent growth, taxes and fees are not modelled.',
        style: TextStyle(color: AppColors.muted, fontSize: 11.5, height: 1.4),
      ),
    ]);
  }

  Widget _legend(Color c, String t) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
    const SizedBox(width: 6),
    Text(t, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
  ]);

  Widget _line(String a, String b, {bool hi = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(a, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
      Flexible(
        child: Text(b,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: hi ? AppColors.peach : AppColors.text,
                fontSize: 14,
                fontWeight: FontWeight.w800)),
      ),
    ]),
  );
}

class _SliderRow extends StatelessWidget {
  final String label;
  final String valueText;
  final double value, min, max;
  final int divisions;
  final ValueChanged<double> onChanged;
  const _SliderRow(this.label, this.valueText, this.value, this.min, this.max,
      this.divisions, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Text(label,
            style: const TextStyle(color: AppColors.muted, fontSize: 13)),
        const Spacer(),
        Text(valueText,
            style: const TextStyle(
                color: AppColors.orange,
                fontSize: 13.5,
                fontWeight: FontWeight.w800)),
      ]),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: AppColors.orange,
          inactiveTrackColor: AppColors.border,
          thumbColor: AppColors.orange,
          overlayColor: AppColors.orange.withValues(alpha: 0.15),
          trackHeight: 4,
        ),
        child: Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ),
    ]);
  }
}

class _Metric extends StatelessWidget {
  final String label, value, hint;
  const _Metric(this.label, this.value, this.hint);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF242427),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: AppColors.muted,
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8)),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value,
              style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 19,
                  fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 4),
        Text(hint,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.peach, fontSize: 11.5)),
      ]),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final _Calc c;
  _ChartPainter(this.c);

  @override
  void paint(Canvas canvas, Size size) {
    final t = max(1, c.horizon);
    final values = [for (var i = 0; i <= t; i++) c.valueAt(i)];
    final equity = [for (var i = 0; i <= t; i++) max(0.0, c.equityAt(i))];
    final maxY = values.reduce(max) * 1.05;

    final grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    Offset pt(int i, double v) => Offset(
      size.width * i / t,
      size.height - (v / maxY) * size.height,
    );

    void draw(List<double> data, Color color, {bool fill = false}) {
      final path = Path()..moveTo(pt(0, data[0]).dx, pt(0, data[0]).dy);
      for (var i = 1; i < data.length; i++) {
        final p = pt(i, data[i]);
        path.lineTo(p.dx, p.dy);
      }
      if (fill) {
        final area = Path.from(path)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();
        canvas.drawPath(
          area,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0)],
            ).createShader(Offset.zero & size),
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6
          ..strokeJoin = StrokeJoin.round,
      );
    }

    draw(values, AppColors.peach);
    draw(equity, AppColors.orange, fill: true);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) => true;
}