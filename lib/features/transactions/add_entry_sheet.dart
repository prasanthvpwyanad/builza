import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/session/session_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/auth_errors.dart';
import '../../core/utils/money.dart';
import '../../data/demo/sample_projects.dart';
import '../../data/models/cashbook_entry.dart';

Future<void> showCashbookEntrySheet(BuildContext context, {CashbookEntry? entry}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => AddEntrySheet(entry: entry),
  );
}

class AddEntrySheet extends StatefulWidget {
  const AddEntrySheet({super.key, this.entry});

  final CashbookEntry? entry;

  @override
  State<AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<AddEntrySheet> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _description = TextEditingController();
  late bool _isReceived;
  late String _category;
  late String _paymentMode;
  String? _projectId;
  bool _saving = false;

  static const _categories = ['Material', 'Labour', 'Transport', 'Advance', 'Other'];
  static const _modes = ['Cash', 'UPI', 'Bank'];

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _isReceived = entry != null && !entry.isPaid;
    _category = _categories.contains(entry?.category) ? entry!.category : 'Material';
    _paymentMode = _modes.contains(entry?.paymentMode) ? entry!.paymentMode : 'Cash';
    _projectId = sampleProjects.any((project) => project.id == entry?.projectId) ? entry!.projectId : null;
    if (entry != null) {
      _amount.text = entry.amount.toString();
      _description.text = entry.description;
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final session = SessionScope.maybeOf(context);
    if (session == null || !session.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to save cashbook entries.')),
      );
      return;
    }
    final amount = parseRupees(_amount.text);
    if (amount == null) return;
    final project = sampleProjects.firstWhere((item) => item.id == _projectId);
    setState(() => _saving = true);
    try {
      if (_isEditing) {
        await session.updateCashbookEntry(
          entryId: widget.entry!.id,
          isReceived: _isReceived,
          amount: amount,
          projectId: project.id,
          projectName: project.name,
          category: _category,
          paymentMode: _paymentMode,
          description: _description.text,
        );
      } else {
        await session.addCashbookEntry(
          isReceived: _isReceived,
          amount: amount,
          projectId: project.id,
          projectName: project.name,
          category: _category,
          paymentMode: _paymentMode,
          description: _description.text,
        );
      }
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context, true);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Entry updated.'
                : '${_isReceived ? 'Received' : 'Paid'} ${formatInr(amount)} saved.',
          ),
        ),
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
                _isEditing ? 'Edit cashbook entry' : 'New cashbook entry',
                style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Paid'), icon: Icon(Icons.arrow_upward)),
                  ButtonSegment(value: true, label: Text('Received'), icon: Icon(Icons.arrow_downward)),
                ],
                selected: {_isReceived},
                onSelectionChanged: _saving ? null : (value) => setState(() => _isReceived = value.first),
              ),
              const SizedBox(height: 14),
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
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                onChanged: _saving ? null : (value) => setState(() => _category = value ?? _category),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _paymentMode,
                decoration: const InputDecoration(labelText: 'Payment mode'),
                items: _modes.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                onChanged: _saving ? null : (value) => setState(() => _paymentMode = value ?? _paymentMode),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                enabled: !_saving,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Cement, carpenter wages, client advance…',
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_isEditing ? 'Save changes' : 'Save entry'),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isEditing
                    ? 'This updates the saved entry for this company.'
                    : 'Saved only for this company. Only the two administrators can see it.',
                style: const TextStyle(color: AppColors.muted, fontSize: 12, height: 1.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
