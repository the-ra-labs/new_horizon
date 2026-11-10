import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/auth_demo.dart';
import '../utils/helpers.dart';
import '../widgets/auth_field.dart';
import '../widgets/check_row.dart';
import '../widgets/gradient_button.dart';
import '../widgets/role_selector.dart';
import '../widgets/social_buttons.dart';
import '../widgets/strength_meter.dart';
import 'home_screen.dart';
import 'pending_approval_sheet.dart';

class RegisterForm extends StatefulWidget {
  final VoidCallback onRegistered;
  const RegisterForm({super.key, required this.onRegistered});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  String? _nameErr, _emailErr, _phoneErr, _pwErr, _pw2Err;
  bool _agree = false;
  AccountRole _role = AccountRole.client;

  bool get _isStaff => _role == AccountRole.staff;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _pw, _pw2]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<bool> _register() async {
    setState(() {
      _nameErr = Validators.required(_name.text, 'Full name');
      _emailErr = Validators.email(_email.text);
      _phoneErr = Validators.phone(_phone.text);
      _pwErr = Validators.password(_pw.text);
      _pw2Err = _pw2.text != _pw.text ? 'Passwords do not match' : null;
    });
    final hasError = [_nameErr, _emailErr, _phoneErr, _pwErr, _pw2Err]
        .any((e) => e != null);
    if (hasError) {
      HapticFeedback.mediumImpact();
      return false;
    }
    if (!_agree) {
      HapticFeedback.mediumImpact();
      showToast(context, 'Please accept the terms to continue', error: true);
      return false;
    }
    // TODO: yahan asli signup API lagani hai.
    // Staff ka status backend mein "pending" save hoga jab tak CEO approve na kare.
    AuthDemo.register(
      ids: [_email.text, _phone.text],
      role: _role,
      name: _name.text,
      email: _email.text,
      phone: _phone.text,
      password: _pw.text,
    );    await Future.delayed(const Duration(milliseconds: 1800));
    return true;
  }

  Future<void> _finish() async {
    if (_isStaff) {
      await showPendingApprovalSheet(context);
      if (mounted) widget.onRegistered();
    } else {
      showToast(context, 'Account created! Please sign in.');
      widget.onRegistered();
    }
  }

  Future<void> _social(String provider) async {
    await connectSocial(context, provider);
    if (!mounted) return;
    if (_isStaff) {
      await showPendingApprovalSheet(context);
      if (mounted) widget.onRegistered();
    } else {
      showToast(context, 'Registered with $provider');
      Navigator.of(context).pushReplacement(fadeRoute(const HomeScreen()));
    }
  }

  void _clear(String? current, VoidCallback reset) {
    if (current != null) setState(reset);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RoleSelector(
          role: _role,
          onChanged: (r) => setState(() => _role = r),
        ),
        const SizedBox(height: 18),
        AuthField(
          label: 'Full Name',
          hint: 'Your full name',
          icon: Icons.badge_outlined,
          controller: _name,
          textInputAction: TextInputAction.next,
          errorText: _nameErr,
          onChanged: (_) => _clear(_nameErr, () => _nameErr = null),
        ),
        const SizedBox(height: 16),
        AuthField(
          label: 'Email',
          hint: 'investor@horizon.ae',
          icon: Icons.mail_outline_rounded,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          errorText: _emailErr,
          onChanged: (_) => _clear(_emailErr, () => _emailErr = null),
        ),
        const SizedBox(height: 16),
        AuthField(
          label: 'Phone',
          hint: '+923001234567',
          icon: Icons.phone_outlined,
          controller: _phone,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          errorText: _phoneErr,
          onChanged: (_) => _clear(_phoneErr, () => _phoneErr = null),
        ),
        const SizedBox(height: 16),
        AuthField(
          label: 'Password',
          hint: 'Create a password',
          icon: Icons.key_rounded,
          controller: _pw,
          isPassword: true,
          textInputAction: TextInputAction.next,
          errorText: _pwErr,
          onChanged: (_) => setState(() => _pwErr = null),
        ),
        StrengthMeter(password: _pw.text),
        const SizedBox(height: 16),
        AuthField(
          label: 'Confirm Password',
          hint: 'Repeat password',
          icon: Icons.lock_outline_rounded,
          controller: _pw2,
          isPassword: true,
          textInputAction: TextInputAction.done,
          errorText: _pw2Err,
          onChanged: (_) => _clear(_pw2Err, () => _pw2Err = null),
        ),
        const SizedBox(height: 16),
        CheckRow(
          value: _agree,
          label: 'I agree to the Terms & Privacy Charter',
          onChanged: (v) => setState(() => _agree = v),
        ),
        const SizedBox(height: 22),
        GradientButton(
          label: _isStaff ? 'Request Access' : 'Create Account',
          icon: _isStaff
              ? Icons.send_rounded
              : Icons.person_add_alt_1_rounded,
          onPressed: _register,
          onSuccess: _finish,
        ),
        const SizedBox(height: 22),
        const OrDivider('OR REGISTER WITH'),
        const SizedBox(height: 16),
        SocialRow(onSelected: _social),
      ],
    );
  }
}