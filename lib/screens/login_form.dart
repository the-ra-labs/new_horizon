import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../utils/auth_demo.dart';
import '../utils/helpers.dart';
import '../widgets/auth_field.dart';
import '../widgets/check_row.dart';
import '../widgets/gradient_button.dart';
import '../widgets/press_scale.dart';
import '../widgets/social_buttons.dart';
import 'biometric_sheet.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';
import '../data/staff_data.dart';
import '../staff/staff_shell.dart';
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _id = TextEditingController();
  final _pw = TextEditingController();
  String? _idErr;
  String? _pwErr;
  bool _remember = false;

  @override
  void dispose() {
    _id.dispose();
    _pw.dispose();
    super.dispose();
  }

  Future<bool> _login() async {
    setState(() {
      _idErr = Validators.emailOrPhone(_id.text);
      _pwErr = Validators.password(_pw.text);
    });
    if (_idErr != null || _pwErr != null) {
      HapticFeedback.mediumImpact();
      return false;
    }
    // TODO: yahan asli API / Firebase login lagana hai
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return false;

    if (AuthDemo.statusOf(_id.text) == AccountStatus.pending) {
      HapticFeedback.mediumImpact();
      showToast(context, 'Your staff account is awaiting CEO approval',
          error: true);
      return false;
    }
    if (!AuthDemo.passwordOk(_id.text, _pw.text)) {
      HapticFeedback.mediumImpact();
      setState(() => _pwErr = 'Incorrect password');
      return false;
    }
    return true;
  }

  void _goHome() {
    final staff = AuthDemo.staffFor(_id.text);
    final nav = Navigator.of(context);
    if (staff != null) {
      Session.staff = staff;
      nav.pushReplacement(fadeRoute(const StaffShell()));
    } else {
      Session.staff = null;
      nav.pushReplacement(fadeRoute(const HomeScreen()));
    }
  }

  Future<void> _social(String provider) async {
    await connectSocial(context, provider);
    if (!mounted) return;
    _goHome(); // TODO: asli Gmail/Facebook auth ke baad
  }

  Future<void> _biometric() async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 440),
      builder: (_) => const BiometricSheet(),
    );
    if (ok == true && mounted) _goHome();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthField(
          label: 'Email/Phone',
          hint: 'investor@horizon.ae',
          icon: Icons.person_outline_rounded,
          controller: _id,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          errorText: _idErr,
          onChanged: (_) {
            if (_idErr != null) setState(() => _idErr = null);
          },
        ),
        const SizedBox(height: 18),
        AuthField(
          label: 'Password',
          hint: '••••••••••••',
          icon: Icons.key_rounded,
          controller: _pw,
          isPassword: true,
          textInputAction: TextInputAction.done,
          errorText: _pwErr,
          onChanged: (_) {
            if (_pwErr != null) setState(() => _pwErr = null);
          },
          trailingLabel: PressScale(
            scale: 0.92,
            onTap: () => Navigator.of(context)
                .push(fadeRoute(const ForgotPasswordScreen())),
            child: const Text('Forgot Password?',
                style: TextStyle(
                  color: AppColors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                )),
          ),
        ),
        const SizedBox(height: 16),
        CheckRow(
          value: _remember,
          label: 'Recognize authorized terminal',
          onChanged: (v) => setState(() => _remember = v),
        ),
        const SizedBox(height: 22),
        GradientButton(
          label: 'Login',
          icon: Icons.arrow_forward_rounded,
          onPressed: _login,
          onSuccess: _goHome,
        ),
        const SizedBox(height: 22),
        const OrDivider('OR LOGIN WITH'),
        const SizedBox(height: 16),
        SocialRow(onSelected: _social),
        const SizedBox(height: 10),
        PressScale(
          onTap: _biometric,
          scale: 0.97,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF222225),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.fingerprint_rounded,
                      color: AppColors.orange, size: 22),
                  SizedBox(width: 10),
                  Text('Authenticate with Face ID / Touch',
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      )),
                ]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}