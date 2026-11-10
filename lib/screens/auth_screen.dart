import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/helpers.dart';
import '../widgets/animated_tab_switch.dart';
import '../widgets/fade_slide.dart';
import '../widgets/press_scale.dart';
import 'login_form.dart';
import 'register_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(desktop ? -0.5 : 0, -1.1),
                radius: desktop ? 1.2 : 1.0,
                colors: [
                  AppColors.orange.withValues(alpha: 0.16),
                  AppColors.bg,
                ],
              ),
            ),
          ),
        ),
        SafeArea(child: desktop ? _desktop() : _mobile()),
      ]),
    );
  }

  Widget _mobile() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(children: [
            const FadeSlide(from: Offset(0, -0.1), child: _Header()),
            const SizedBox(height: 36),
            FadeSlide(delayMs: 150, child: _buildCard()),
            const SizedBox(height: 28),
            const FadeSlide(delayMs: 300, child: _Footer()),
          ]),
        ),
      ),
    );
  }

  Widget _desktop() {
    return Row(children: [
      const Expanded(flex: 5, child: _BrandPanel()),
      Container(width: 1, color: AppColors.border),
      Expanded(
        flex: 4,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(children: [
                FadeSlide(from: const Offset(0.05, 0), child: _buildCard()),
                const SizedBox(height: 28),
                const FadeSlide(delayMs: 200, child: _Footer()),
              ]),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
              color: Colors.black54, blurRadius: 30, offset: Offset(0, 16)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedTabSwitch(
            isLeft: _isLogin,
            left: 'Sign In',
            right: 'Register',
            onChanged: (v) => setState(() => _isLogin = v),
          ),
          const SizedBox(height: 22),
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.topCenter,
                children: [...previous, if (current != null) current],
              ),
              transitionBuilder: (child, anim) {
                final fromLeft = child.key == const ValueKey('login');
                return FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(fromLeft ? -0.15 : 0.15, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                );
              },
              child: _isLogin
                  ? const LoginForm(key: ValueKey('login'))
                  : RegisterForm(
                key: const ValueKey('register'),
                onRegistered: () => setState(() => _isLogin = true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Desktop left panel ----------
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final logo = math.max(150.0, math.min(c.maxHeight * 0.38, 340.0));
      final radius = BorderRadius.circular(logo * 0.18);
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: FadeSlide(
            from: const Offset(-0.05, 0),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: logo,
                height: logo,
                decoration: BoxDecoration(
                  borderRadius: radius,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.orange.withValues(alpha: 0.3),
                      blurRadius: 60,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: radius,
                  child: Image.asset('assets/images/logo.png',
                      fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 32),
              const Text('NEW HORIZON',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: AppColors.text,
                  )),
              const SizedBox(height: 8),
              const Text('PRIVATE ESTATES & ADVISORY',
                  style: TextStyle(
                    fontSize: 13,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w700,
                    color: AppColors.peach,
                  )),
              const SizedBox(height: 12),
              const Text('Your Gateway to Exclusive Real Estate',
                  style: TextStyle(fontSize: 15, color: AppColors.muted)),
              const SizedBox(height: 20),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('EST. 2011',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                    )),
              ),
            ]),
          ),
        ),
      );
    });
  }
}

// ---------- Mobile header ----------
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
        Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1B1B1D),
            border: Border.all(
                color: AppColors.orange.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.orange.withValues(alpha: 0.35),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
            ),
          ),
        ),
        Positioned(
          bottom: -12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2D),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('EST. 2011',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                )),
          ),
        ),
      ]),
      const SizedBox(height: 28),
      const Text('NEW HORIZON',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: AppColors.text,
          )),
      const SizedBox(height: 6),
      const Text('PRIVATE ESTATES & ADVISORY',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w700,
            color: AppColors.peach,
          )),
      const SizedBox(height: 8),
      const Text('Your Gateway to Exclusive Real Estate',
          style: TextStyle(fontSize: 13, color: AppColors.muted)),
    ]);
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    Widget link(String t) => PressScale(
      scale: 0.92,
      onTap: () => showToast(context, '$t coming soon'),
      child: Text(t,
          style: const TextStyle(color: AppColors.muted, fontSize: 12)),
    );

    return Column(children: [
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 8,
        children: [
          link('Privacy & Charter'),
          link('Investor Relations'),
          link('Jurisdiction'),
        ],
      ),
      const SizedBox(height: 14),
      Text(
        '© NEW HORIZON PRIME REAL ESTATE HOLDINGS LLC.\nALL RIGHTS RESERVED.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.orange.withValues(alpha: 0.35),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          height: 1.5,
        ),
      ),
    ]);
  }
}