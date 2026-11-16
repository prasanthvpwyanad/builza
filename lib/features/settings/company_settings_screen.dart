import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/session/session_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/auth_errors.dart';
import '../../core/utils/join_code.dart';
import '../../core/utils/pick_company_logo.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/company_logo.dart';
import '../../data/models/app_user.dart';

class CompanySettingsScreen extends StatefulWidget {
  const CompanySettingsScreen({super.key});

  @override
  State<CompanySettingsScreen> createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends State<CompanySettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  late Future<List<AppUser>> _admins;
  bool _loadedAdmins = false;
  bool _nameReady = false;
  Uint8List? _pendingLogoBytes;
  String? _pendingLogoType;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = SessionScope.of(context);
    if (!_nameReady && session.company != null) {
      _name.text = session.company!.name;
      _nameReady = true;
    }
    if (_loadedAdmins) return;
    _loadedAdmins = true;
    _admins = session.loadAdmins();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool _hasChanges(String currentName, Uint8List? savedLogo) {
    final nameChanged = _name.text.trim() != currentName.trim();
    final logoChanged = _pendingLogoBytes != null && _pendingLogoBytes!.isNotEmpty;
    return nameChanged || logoChanged;
  }

  Future<void> _pickLogo() async {
    try {
      final logo = await pickCompanyLogo();
      if (logo == null || !mounted) return;
      setState(() {
        _pendingLogoBytes = logo.bytes;
        _pendingLogoType = logo.contentType;
      });
    } on AuthFailure catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final session = SessionScope.of(context);
    try {
      await session.updateCompany(
        name: _name.text,
        logoBytes: _pendingLogoBytes,
        logoContentType: _pendingLogoType,
      );
      if (!mounted) return;
      setState(() {
        _pendingLogoBytes = null;
        _pendingLogoType = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company details saved.')),
      );
    } on AuthFailure catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _invite() async {
    final session = SessionScope.of(context);
    final emailController = TextEditingController(
      text: session.company?.activeInviteEmail ?? '',
    );
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite second administrator'),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Admin 2 email (optional)',
            helperText: 'If set, only this email can use the invite.',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final error = validateOptionalEmail(emailController.text);
              if (error != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                return;
              }
              Navigator.pop(context, emailController.text.trim());
            },
            child: const Text('Create invite'),
          ),
        ],
      ),
    );
    emailController.dispose();
    if (email == null || !mounted) return;

    try {
      final code = await session.inviteSecondAdmin(email: email);
      if (!mounted) return;
      setState(() => _admins = session.loadAdmins());
      await _showCode(code);
    } on AuthFailure catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _showCode(String code) async {
    final formatted = formatJoinCode(code);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share this code with Admin 2. It expires in 7 days and can be used once.'),
            const SizedBox(height: 16),
            SelectableText(
              formatted,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: formatted));
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Copy and close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    final company = session.company;
    final me = session.user;
    if (company == null || me == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final dirty = _hasChanges(company.name, company.logoBytes);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company'),
        actions: [
          TextButton(
            onPressed: session.busy || !dirty ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Company details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  validator: validateCompanyName,
                  enabled: !session.busy,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(labelText: 'Company name'),
                ),
                const SizedBox(height: 12),
                CompanyLogoField(
                  name: _name.text,
                  bytes: _pendingLogoBytes ?? company.logoBytes,
                  enabled: !session.busy,
                  helper: _pendingLogoBytes != null
                      ? 'New logo selected. Tap Save to keep it.'
                      : company.hasLogo
                          ? 'Tap to choose a new logo, then Save.'
                          : 'Optional. PNG, JPG, or WEBP, up to 700 KB.',
                  onPick: _pickLogo,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: session.busy || !dirty ? null : _save,
                    icon: session.busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(session.busy ? 'Saving…' : 'Save changes'),
                  ),
                ),
                if (dirty)
                  TextButton(
                    onPressed: session.busy
                        ? null
                        : () => setState(() {
                              _name.text = company.name;
                              _pendingLogoBytes = null;
                              _pendingLogoType = null;
                            }),
                    child: const Text('Discard changes'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This workspace is isolated. Administrators of other companies cannot see these records.',
            style: TextStyle(color: AppColors.muted, height: 1.4),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline, color: AppColors.blue),
              title: Text(me.displayName, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${me.email}\nAdministrator ${me.adminSlot} of 2'),
              isThreeLine: true,
            ),
          ),
          const SizedBox(height: 18),
          const Text('Administrators', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          FutureBuilder<List<AppUser>>(
            future: _admins,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return Column(
                children: snapshot.data!
                    .map(
                      (admin) => Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFE7F2FF),
                            child: Text('${admin.adminSlot}', style: const TextStyle(color: AppColors.blue, fontWeight: FontWeight.w800)),
                          ),
                          title: Text(admin.displayName, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(admin.email),
                          trailing: admin.uid == me.uid
                              ? const Chip(label: Text('You'), visualDensity: VisualDensity.compact)
                              : null,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 12),
          if (company.canInviteSecondAdmin) ...[
            FilledButton.icon(
              onPressed: session.busy ? null : _invite,
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text('Invite second administrator'),
            ),
            if (company.hasActiveInvite) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _showCode(company.activeInviteCode!),
                icon: const Icon(Icons.vpn_key_outlined),
                label: Text('Show code ${formatJoinCode(company.activeInviteCode!)}'),
              ),
              if (company.activeInviteEmail != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Locked to ${company.activeInviteEmail}',
                    style: const TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
                ),
            ],
          ] else
            const Text(
              'This company already has two administrators.',
              style: TextStyle(color: AppColors.muted),
            ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign out?'),
                  content: const Text('You will need your administrator password to access this company again.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sign out')),
                  ],
                ),
              );
              if (confirmed == true) {
                if (context.mounted) Navigator.of(context).pop();
                await session.signOut();
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
