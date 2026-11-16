import 'package:flutter/material.dart';

import '../../core/session/session_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/cashbook_entry.dart';
import 'add_entry_sheet.dart';
import 'cashbook_entry_tile.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _search = TextEditingController();
  String _filter = 'all';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<CashbookEntry> _apply(List<CashbookEntry> entries) {
    final query = _search.text.trim().toLowerCase();
    return entries.where((entry) {
      if (_filter == 'paid' && !entry.isPaid) return false;
      if (_filter == 'received' && entry.isPaid) return false;
      if (query.isEmpty) return true;
      return entry.title.toLowerCase().contains(query) ||
          entry.projectName.toLowerCase().contains(query) ||
          entry.category.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.maybeOf(context);
    return StreamBuilder<List<CashbookEntry>>(
      stream: session?.watchCashbook() ?? Stream.value(const <CashbookEntry>[]),
      builder: (context, snapshot) {
        final entries = _apply(snapshot.data ?? const []);
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
          children: [
            const Text('Cashbook', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('All received and paid transactions', style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 16),
            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search description or project'),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _filter == 'all',
                  onSelected: (_) => setState(() => _filter = 'all'),
                ),
                FilterChip(
                  label: const Text('Received'),
                  selected: _filter == 'received',
                  onSelected: (_) => setState(() => _filter = 'received'),
                ),
                FilterChip(
                  label: const Text('Paid'),
                  selected: _filter == 'paid',
                  onSelected: (_) => setState(() => _filter = 'paid'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData)
              const Padding(
                padding: EdgeInsets.only(top: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (snapshot.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Text(
                  'Could not load entries. ${snapshot.error}',
                  style: const TextStyle(color: AppColors.red),
                ),
              )
            else if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 32),
                child: Text(
                  'No cashbook entries yet. Tap Add entry to save the first one.',
                  style: TextStyle(color: AppColors.muted, height: 1.4),
                ),
              )
            else
              ...entries.map(
                (entry) => CashbookEntryTile(
                  entry: entry,
                  onTap: () => showCashbookEntrySheet(context, entry: entry),
                ),
              ),
          ],
        );
      },
    );
  }
}
