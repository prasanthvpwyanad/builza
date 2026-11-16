import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/session/session_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/auth_errors.dart';
import '../../core/utils/pick_company_logo.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/company_logo.dart';
import 'widgets/auth_split.dart';
import 'widgets/auth_widgets.dart';

class RegisterCompanyScreen extends StatefulWidget {
  const RegisterCompanyScreen({
    super.key,
    this.session,
    required this.onBackToLogin,
  });

  final SessionController? session;
  final VoidCallback onBackToLogin;

  @override
  State<RegisterCompanyScreen> createState() => _RegisterCompanyScreenState();
}

class _RegisterCompanyScreenState extends State<RegisterCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyName = TextEditingController();
  final _adminName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _secondEmail = TextEditingController();
  Uint8List? _logoBytes;
  String? _logoContentType;

  @override
  void dispose() {
    _companyName.dispose();
    _adminName.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _secondEmail.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    try {
      final logo = await pickCompanyLogo();
      if (logo == null || !mounted) return;
      setState(() {
        _logoBytes = logo.bytes;
        _logoContentType = logo.contentType;
      });
    } on AuthFailure catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final session = widget.session;
    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connect Firebase to register a live company. You can still preview the workspace from Sign in.')),
      );
      return;
    }
    try {
      await session.registerCompany(
        companyName: _companyName.text,
        adminName: _adminName.text,
        email: _email.text,
        password: _password.text,
        secondAdminEmail: _secondEmail.text,
        logoBytes: _logoBytes,
        logoContentType: _logoContentType,
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
                'Register a company',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.ink),
              ),
              const SizedBox(height: 8),
              const Text(
                'Creates an isolated workspace. You become Admin 1. Admin 2 joins later with their own password.',
                style: TextStyle(color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 24),
              const Text('Company', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _companyName,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                validator: validateCompanyName,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Company name',
                  hintText: 'DRUVA',
                ),
              ),
              const SizedBox(height: 12),
              CompanyLogoField(
                name: _companyName.text,
                bytes: _logoBytes,
                enabled: !busy,
                onPick: _pickLogo,
              ),
              const SizedBox(height: 20),
              const Text('Administrator 1 (you)', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
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
              const SizedBox(height: 20),
              const Text('Administrator 2 (optional)', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text(
                'Leave blank to invite later from Company settings. If you enter an email, BUILZA creates a one-time invite locked to that address.',
                style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.35),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _secondEmail,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                validator: validateOptionalEmail,
                decoration: const InputDecoration(labelText: 'Second admin email (optional)'),
              ),
              const SizedBox(height: 20),
              AuthBusyButton(label: 'Create company', busy: busy, onPressed: _submit),
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
