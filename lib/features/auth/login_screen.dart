import 'package:flutter/material.dart';

import '../../core/session/session_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/auth_errors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/builza_mark.dart';
import 'widgets/auth_split.dart';
import 'widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.session,
    required this.onRegister,
    required this.onJoin,
    this.onPreviewSignedIn,
  });

  final SessionController? session;
  final VoidCallback onRegister;
  final VoidCallback onJoin;
  final VoidCallback? onPreviewSignedIn;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _rememberMe = true;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final session = widget.session;
    if (session == null) {
      widget.onPreviewSignedIn?.call();
      return;
    }
    setState(() => _busy = true);
    try {
      await session.signIn(email: _email.text, password: _password.text);
    } on AuthFailure catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _forgotPassword() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot password'),
        content: const Text(
          'Only two authorized administrators can access this company. Ask the other administrator to help you recover the password.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy = _busy || (widget.session?.busy ?? false);
    return AuthSplit(
      showMobileBrand: false,
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BuilzaLogo(height: 64),
              const SizedBox(height: 28),
              const Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to your account',
                style: TextStyle(color: AppColors.muted, fontSize: 16),
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                validator: validateEmail,
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
              ),
              const SizedBox(height: 14),
              PasswordField(
                controller: _password,
                label: 'Enter your password',
                validator: validatePassword,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
              ),
              const SizedBox(height: 8),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        visualDensity: VisualDensity.compact,
                        value: _rememberMe,
                        onChanged: busy ? null : (value) => setState(() => _rememberMe = value ?? false),
                      ),
                      const Text('Remember me'),
                    ],
                  ),
                  TextButton(
                    onPressed: busy ? null : _forgotPassword,
                    child: const Text('Forgot password?'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: busy ? null : _submit,
                  child: busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Sign in', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: busy ? null : widget.onRegister,
                  child: const Text(
                    'Register a company',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: busy ? null : widget.onJoin,
                  child: const Text('Join as Admin 2'),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'New company? Use Register a company. Only two authorized administrators.',
                style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
