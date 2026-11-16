import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/session/session_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/auth_errors.dart';
import '../../core/utils/pick_company_logo.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/builza_mark.dart';
import '../../core/widgets/company_logo.dart';
import 'widgets/auth_widgets.dart';

class IncompleteAccountScreen extends StatefulWidget {
  const IncompleteAccountScreen({super.key, required this.session});

  final SessionController session;

  @override
  State<IncompleteAccountScreen> createState() => _IncompleteAccountScreenState();
}

class _IncompleteAccountScreenState extends State<IncompleteAccountScreen> {
  final _registerKey = GlobalKey<FormState>();
  final _joinKey = GlobalKey<FormState>();
  final _companyName = TextEditingController();
  final _adminName = TextEditingController();
  final _inviteCode = TextEditingController();
  Uint8List? _logoBytes;
  String? _logoContentType;

  @override
  void dispose() {
    _companyName.dispose();
    _adminName.dispose();
    _inviteCode.dispose();
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

  Future<void> _createCompany() async {
    final nameError = validatePersonName(_adminName.text);
    if (nameError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(nameError)));
      return;
    }
    if (!_registerKey.currentState!.validate()) return;
    try {
      await widget.session.registerCompanyForCurrentUser(
        companyName: _companyName.text,
        adminName: _adminName.text,
        logoBytes: _logoBytes,
        logoContentType: _logoContentType,
      );
    } on AuthFailure catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _join() async {
    final nameError = validatePersonName(_adminName.text);
    if (nameError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(nameError)));
      return;
    }
    if (!_joinKey.currentState!.validate()) return;
    try {
      await widget.session.joinCompanyForCurrentUser(
        inviteCode: _inviteCode.text,
        adminName: _adminName.text,
      );
    } on AuthFailure catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.session.authEmail ?? 'this account';
    final busy = widget.session.busy;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const BuilzaMark(size: 48, iconSize: 28),
            const SizedBox(height: 20),
            const Text(
              'Finish linking this account',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.navy),
            ),
            const SizedBox(height: 10),
            Text(
              '$email is signed in, but it is not linked to a BUILZA company yet. Create a company as Admin 1, or join with an invite code as Admin 2.',
              style: const TextStyle(color: AppColors.muted, height: 1.4, fontSize: 15),
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: _adminName,
              validator: validatePersonName,
              decoration: const InputDecoration(labelText: 'Your name'),
            ),
            const SizedBox(height: 20),
            Form(
              key: _registerKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Create a company', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _companyName,
                    validator: validateCompanyName,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(labelText: 'Company name'),
                  ),
                  const SizedBox(height: 12),
                  CompanyLogoField(
                    name: _companyName.text,
                    bytes: _logoBytes,
                    enabled: !busy,
                    onPick: _pickLogo,
                  ),
                  const SizedBox(height: 12),
                  AuthBusyButton(label: 'Create company as Admin 1', busy: busy, onPressed: _createCompany),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Form(
              key: _joinKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Or join as Admin 2', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _inviteCode,
                    textCapitalization: TextCapitalization.characters,
                    validator: validateInviteCode,
                    decoration: const InputDecoration(labelText: 'Invite code'),
                  ),
                  const SizedBox(height: 12),
                  AuthBusyButton(label: 'Join with invite code', busy: busy, onPressed: _join),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: busy ? null : widget.session.signOut,
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
