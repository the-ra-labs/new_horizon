import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../utils/helpers.dart';
import '../widgets/auth_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/press_scale.dart';
import '../widgets/strength_meter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 0; // 0 email, 1 otp, 2 new password, 3 done
  final _id = TextEditingController();
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  String _otp = '';
  String? _idErr, _pwErr, _pw2Err;

  @override
  void dispose() {
    _id.dispose();
    _pw.dispose();
    _pw2.dispose();
    super.dispose();
  }

  void _back() {
    if (_step == 0 || _step == 3) {
      Navigator.of(context).pop();
    } else {
      setState(() => _step--);
    }
  }

  Future<bool> _sendCode() async {
    setState(() => _idErr = Validators.emailOrPhone(_id.text));
    if (_idErr != null) {
      HapticFeedback.mediumImpact();
      return false;
    }
    // TODO: yahan asli "send OTP" API lagani hai
    await Future.delayed(const Duration(milliseconds: 1400));
    return true;
  }

  Future<bool> _verify() async {
    if (_otp.length < 4) {
      HapticFeedback.mediumImpact();
      showToast(context, 'Enter the 4-digit code', error: true);
      return false;
    }
    // TODO: yahan asli OTP verify API lagani hai
    await Future.delayed(const Duration(milliseconds: 1200));
    return true;
  }

  Future<bool> _reset() async {
    setState(() {
      _pwErr = Validators.password(_pw.text);
      _pw2Err = _pw2.text != _pw.text ? 'Passwords do not match' : null;
    });
    if (_pwErr != null || _pw2Err != null) {
      HapticFeedback.mediumImpact();
      return false;
    }
    // TODO: yahan asli reset password API lagani hai
    await Future.delayed(const Duration(milliseconds: 1400));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -1.1),
                radius: 1.0,
                colors: [
                  AppColors.orange.withValues(alpha: 0.14),
                  AppColors.bg,
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(children: [
                  _topBar(),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black54,
                            blurRadius: 30,
                            offset: Offset(0, 16)),
                      ],
                    ),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOutCubic,
                      alignment: Alignment.topCenter,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        layoutBuilder: (current, previous) => Stack(
                          alignment: Alignment.topCenter,
                          children: [...previous, if (current != null) current],
                        ),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.15, 0),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: _stepView(),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _topBar() {
    return Row(children: [
      PressScale(
        onTap: _back,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.card,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 16, color: AppColors.text),
        ),
      ),
      const Spacer(),
      if (_step < 3)
        Row(
          children: List.generate(3, (i) {
            final active = i == _step;
            final done = i < _step;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(left: 6),
              width: active ? 28 : 8,
              height: 8,
              decoration: BoxDecoration(
                gradient: (active || done) ? AppColors.gradient : null,
                color: (active || done) ? null : AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
    ]);
  }

  Widget _stepView() {
    switch (_step) {
      case 0:
        return Column(
          key: const ValueKey(0),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _StepHeader(
              icon: Icons.lock_reset_rounded,
              title: 'Forgot Password?',
              subtitle:
              'Enter your registered email or phone and we will send you a verification code.',
            ),
            const SizedBox(height: 24),
            AuthField(
              label: 'Email/Phone',
              hint: 'investor@horizon.ae',
              icon: Icons.person_outline_rounded,
              controller: _id,
              keyboardType: TextInputType.emailAddress,
              errorText: _idErr,
              onChanged: (_) {
                if (_idErr != null) setState(() => _idErr = null);
              },
            ),
            const SizedBox(height: 22),
            GradientButton(
              label: 'Send Code',
              icon: Icons.send_rounded,
              onPressed: _sendCode,
              onSuccess: () => setState(() => _step = 1),
            ),
          ],
        );
      case 1:
        return Column(
          key: const ValueKey(1),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StepHeader(
              icon: Icons.mark_email_read_outlined,
              title: 'Verify Code',
              subtitle: 'Enter the 4-digit code sent to ${_id.text.trim()}',
            ),
            const SizedBox(height: 24),
            OtpRow(onChanged: (v) => _otp = v),
            const SizedBox(height: 14),
            Center(
              child: PressScale(
                scale: 0.92,
                onTap: () => showToast(context, 'A new code has been sent'),
                child: const Text('Resend code',
                    style: TextStyle(
                      color: AppColors.orange,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    )),
              ),
            ),
            const SizedBox(height: 22),
            GradientButton(
              label: 'Verify',
              icon: Icons.verified_outlined,
              onPressed: _verify,
              onSuccess: () => setState(() => _step = 2),
            ),
          ],
        );
      case 2:
        return Column(
          key: const ValueKey(2),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _StepHeader(
              icon: Icons.password_rounded,
              title: 'New Password',
              subtitle: 'Create a strong password for your account.',
            ),
            const SizedBox(height: 24),
            AuthField(
              label: 'New Password',
              hint: 'Enter new password',
              icon: Icons.key_rounded,
              controller: _pw,
              isPassword: true,
              errorText: _pwErr,
              onChanged: (_) => setState(() => _pwErr = null),
            ),
            StrengthMeter(password: _pw.text),
            const SizedBox(height: 16),
            AuthField(
              label: 'Confirm Password',
              hint: 'Repeat new password',
              icon: Icons.lock_outline_rounded,
              controller: _pw2,
              isPassword: true,
              errorText: _pw2Err,
              onChanged: (_) {
                if (_pw2Err != null) setState(() => _pw2Err = null);
              },
            ),
            const SizedBox(height: 22),
            GradientButton(
              label: 'Reset Password',
              icon: Icons.lock_outline_rounded,
              onPressed: _reset,
              onSuccess: () => setState(() => _step = 3),
            ),
          ],
        );
      default:
        return Column(
          key: const ValueKey(3),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _StepHeader(
              icon: Icons.check_rounded,
              title: 'Password Updated',
              subtitle: 'You can now sign in with your new password.',
              success: true,
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: 'Back to Sign In',
              icon: Icons.login_rounded,
              onPressed: () async => true,
              onSuccess: () => Navigator.of(context).pop(),
            ),
          ],
        );
    }
  }
}

class _StepHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool success;
  const _StepHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.success = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = success ? AppColors.success : AppColors.orange;
    return Column(children: [
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.4, end: 1.0),
        duration: const Duration(milliseconds: 700),
        curve: Curves.elasticOut,
        builder: (_, v, child) => Transform.scale(scale: v, child: child),
        child: Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [
              c.withValues(alpha: 0.28),
              c.withValues(alpha: 0.06),
            ]),
            border: Border.all(color: c.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(color: c.withValues(alpha: 0.25), blurRadius: 24),
            ],
          ),
          child: Icon(icon, color: c, size: 36),
        ),
      ),
      const SizedBox(height: 18),
      Text(title,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: AppColors.text, fontSize: 22, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text(subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: AppColors.muted, fontSize: 13.5, height: 1.4)),
    ]);
  }
}

class OtpRow extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const OtpRow({super.key, required this.onChanged});

  @override
  State<OtpRow> createState() => _OtpRowState();
}

class _OtpRowState extends State<OtpRow> {
  final _ctrls = List.generate(4, (_) => TextEditingController());
  final _nodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c, width: w),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (i) {
        return SizedBox(
          width: 60,
          height: 64,
          child: TextField(
            controller: _ctrls[i],
            focusNode: _nodes[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            cursorColor: AppColors.orange,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            style: const TextStyle(
                color: AppColors.text, fontSize: 24, fontWeight: FontWeight.w800),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.field,
              enabledBorder: b(AppColors.border),
              focusedBorder: b(AppColors.orange, 1.6),
            ),
            onChanged: (v) {
              if (v.isNotEmpty && i < 3) _nodes[i + 1].requestFocus();
              if (v.isNotEmpty && i == 3) _nodes[i].unfocus();
              if (v.isEmpty && i > 0) _nodes[i - 1].requestFocus();
              widget.onChanged(_ctrls.map((c) => c.text).join());
            },
          ),
        );
      }),
    );
  }
}