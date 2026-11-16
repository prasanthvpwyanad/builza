import 'package:flutter/material.dart';

import '../../core/session/session_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/auth_errors.dart';
import '../../core/utils/validators.dart';
import 'widgets/auth_split.dart';
import 'widgets/auth_widgets.dart';

class JoinCompanyScreen extends StatefulWidget {
  const JoinCompanyScreen({
    super.key,
    this.session,
    required this.onBackToLogin,
  });

  final SessionController? session;
  final VoidCallback onBackToLogin;

  @override
  State<JoinCompanyScreen> createState() => _JoinCompanyScreenState();
}

class _JoinCompanyScreenState extends State<JoinCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _adminName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    _adminName.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final session = widget.session;
    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connect Firebase to join a live company.')),
      );
      return;
    }
    try {
      await session.joinCompany(
        inviteCode: _code.text,
        adminName: _adminName.text,
        email: _email.text,
        password: _password.text,
      );
    } on AuthFailure catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = widget.session?.busy ?? false;
    return AuthSplit(
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Join as Admin 2',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.ink),
              ),
              const SizedBox(height: 8),
              const Text(
                'Use the invite code from Admin 1. You will only see this company’s projects and cashbook.',
                style: TextStyle(color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _code,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                validator: validateInviteCode,
                decoration: const InputDecoration(
                  labelText: 'Invite code',
                  hintText: 'ABCD-2345',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _adminName,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: validatePersonName,
                decoration: const InputDecoration(labelText: 'Full name'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                validator: validateEmail,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              PasswordField(
                controller: _password,
                validator: validatePassword,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
              ),
              const SizedBox(height: 12),
              PasswordField(
                controller: _confirm,
                label: 'Confirm password',
                validator: (value) => validateConfirmPassword(value, _password.text),
                autofillHints: const [AutofillHints.newPassword],
              ),
              const SizedBox(height: 12),
              const Text(
                'A company can have at most two administrators. Each admin sets their own password.',
                style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.35),
              ),
              const SizedBox(height: 20),
              AuthBusyButton(label: 'Join company', busy: busy, onPressed: _submit),
              const SizedBox(height: 12),
              TextButton(
                onPressed: busy ? null : widget.onBackToLogin,
                child: const Text('Back to sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
