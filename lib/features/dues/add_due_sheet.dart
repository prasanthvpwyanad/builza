import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/session/session_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/auth_errors.dart';
import '../../core/utils/money.dart';
import '../../data/demo/sample_projects.dart';
import '../../data/models/due.dart';

Future<void> showDueSheet(BuildContext context, {Due? due}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => AddDueSheet(due: due),
  );
}

class AddDueSheet extends StatefulWidget {
  const AddDueSheet({super.key, this.due});

  final Due? due;

  @override
  State<AddDueSheet> createState() => _AddDueSheetState();
}

class _AddDueSheetState extends State<AddDueSheet> {
  final _formKey = GlobalKey<FormState>();
  final _party = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  String? _projectId;
  bool _isPayable = true;
  bool _saving = false;

  bool get _isEditing => widget.due != null;

  @override
  void initState() {
    super.initState();
    final due = widget.due;
    _isPayable = due?.isPayable ?? true;
    _projectId = sampleProjects.any((project) => project.id == due?.projectId) ? due!.projectId : null;
    if (due != null) {
      _party.text = due.party;
      _amount.text = due.amount.toString();
      _note.text = due.note;
    }
  }

  @override
  void dispose() {
    _party.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save({bool settle = false}) async {
    if (!_formKey.currentState!.validate()) return;
    final session = SessionScope.maybeOf(context);
    if (session == null || !session.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to save dues.')),
      );
      return;
    }
    final amount = settle ? 0 : parseRupees(_amount.text);
    if (!settle && amount == null) return;
    final project = sampleProjects.firstWhere((item) => item.id == _projectId);
    setState(() => _saving = true);
    try {
      if (_isEditing) {
        await session.updateDue(
          dueId: widget.due!.id,
          party: _party.text,
          amount: amount ?? 0,
          projectId: project.id,
          projectName: project.name,
          note: _note.text,
          kind: _isPayable ? 'payable' : 'receivable',
          status: settle ? 'settled' : 'open',
        );
      } else {
        await session.addDue(
          party: _party.text,
          amount: amount ?? 0,
          projectId: project.id,
          projectName: project.name,
          note: _note.text,
          kind: _isPayable ? 'payable' : 'receivable',
        );
      }
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context, true);
      messenger.showSnackBar(
        SnackBar(content: Text(settle ? 'Due settled.' : (_isEditing ? 'Due updated.' : 'Due saved.'))),
      );
    } on AuthFailure catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing ? 'Edit due' : 'Add due',
                style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Payable'), icon: Icon(Icons.north_east)),
                  ButtonSegment(value: false, label: Text('Receivable'), icon: Icon(Icons.south_west)),
                ],
                selected: {_isPayable},
                onSelectionChanged: _saving ? null : (value) => setState(() => _isPayable = value.first),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _party,
                enabled: !_saving,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.length < 2) return 'Enter the party name.';
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Party name',
                  hintText: 'Supplier, labour, or client',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amount,
                enabled: !_saving,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
                validator: (value) => parseRupees(value) == null ? 'Enter a valid amount.' : null,
                decoration: const InputDecoration(labelText: 'Amount (₹)', prefixText: '₹ '),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _projectId,
                decoration: const InputDecoration(labelText: 'Project'),
                hint: const Text('Select project'),
                items: sampleProjects
                    .map((project) => DropdownMenuItem(value: project.id, child: Text(project.name)))
                    .toList(),
                validator: (value) => value == null || value.isEmpty ? 'Select a project.' : null,
                onChanged: _saving ? null : (value) => setState(() => _projectId = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _note,
                enabled: !_saving,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  hintText: 'Pending bill, partial payment, balance…',
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _saving ? null : () => _save(),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_isEditing ? 'Save changes' : 'Save due'),
                ),
              ),
              if (_isEditing && widget.due!.isOpen) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _saving ? null : () => _save(settle: true),
                    child: const Text('Mark settled'),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              const Text(
                'Payable is money this company still owes. Receivable is money still due to this company.',
                style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
