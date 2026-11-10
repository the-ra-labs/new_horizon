import 'dart:math' as math;
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Widget next;
  const SplashScreen({super.key, required this.next});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _loader;

  static const orange = Color(0xFFF7931E);

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3200));

    _fade = CurvedAnimation(
        parent: _c, curve: const Interval(0.0, 0.4, curve: Curves.easeOut));
    _scale = Tween(begin: 0.5, end: 1.0).animate(CurvedAnimation(
        parent: _c,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)));
    _loader = CurvedAnimation(
        parent: _c, curve: const Interval(0.5, 1.0, curve: Curves.easeInOut));

    _c.forward().whenComplete(() async {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => widget.next,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ));
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, box) {
          // Responsive size: phone, tablet, web, windows sab par
          final shortest = math.min(box.maxWidth, box.maxHeight);
          final logoSize = math.min(shortest * 0.8, 560.0);
          final barW = math.min(logoSize * 0.5, 240.0);

          return Center(
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                // Entrance ke baad halki breathing pulse
                final pulse = _c.value < 0.5
                    ? 1.0
                    : 1.0 + 0.015 * math.sin((_c.value - 0.5) * 2 * math.pi * 3);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _fade,
                      child: Transform.scale(
                        scale: _scale.value * pulse,
                        child: ShaderMask(
                          blendMode: BlendMode.dstIn,
                          shaderCallback: (rect) => const RadialGradient(
                            radius: 0.7,
                            colors: [Colors.white, Colors.white, Colors.transparent],
                            stops: [0.0, 0.8, 1.0],
                          ).createShader(rect),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stack) {
                              debugPrint('IMAGE ERROR: $error');
                              return const Icon(Icons.broken_image,
                                  color: Colors.red, size: 80);
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: logoSize * 0.04),
                    Opacity(
                      opacity: _loader.value,
                      child: Container(
                        width: barW,
                        height: 3,
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Container(
                          width: barW * _loader.value,
                          decoration: BoxDecoration(
                            color: orange,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}