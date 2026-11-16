import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/session/session_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/cashbook_entry.dart';
import '../transactions/add_entry_sheet.dart';
import '../transactions/cashbook_entry_tile.dart';
import 'report_math.dart';
import 'report_widgets.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.maybeOf(context);
    return ReportScaffold(
      title: 'Monthly report',
      child: StreamBuilder<List<CashbookEntry>>(
        stream: session?.watchCashbook() ?? Stream.value(const <CashbookEntry>[]),
        builder: (context, snapshot) {
          final all = snapshot.data ?? const <CashbookEntry>[];
          final months = reportMonths(all);
          final selected = months.firstWhere(
            (month) => month.year == _month.year && month.month == _month.month,
            orElse: () => months.first,
          );
          final entries = sortedEntries(all.where((entry) => isInMonth(entry, selected)).toList());
          final split = totalsOf(entries);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              DropdownButtonFormField<DateTime>(
                initialValue: selected,
                decoration: const InputDecoration(labelText: 'Month'),
                items: months
                    .map(
                      (month) => DropdownMenuItem(
                        value: month,
                        child: Text(DateFormat('MMMM yyyy').format(month)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _month = value);
                },
              ),
              const SizedBox(height: 14),
              TotalsHeader(split: split, caption: DateFormat('MMMM yyyy').format(selected).toUpperCase()),
              const SizedBox(height: 18),
              const Text('Entries this month', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (entries.isEmpty)
                const Text('No entries in this month.', style: TextStyle(color: AppColors.muted))
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
      ),
    );
  }
}
