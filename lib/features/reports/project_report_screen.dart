import 'package:flutter/material.dart';

import '../../core/session/session_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/cashbook_entry.dart';
import 'report_math.dart';
import 'report_widgets.dart';

class ProjectReportScreen extends StatelessWidget {
  const ProjectReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.maybeOf(context);
    return ReportScaffold(
      title: 'Project-wise statement',
      child: StreamBuilder<List<CashbookEntry>>(
        stream: session?.watchCashbook() ?? Stream.value(const <CashbookEntry>[]),
        builder: (context, snapshot) {
          final entries = snapshot.data ?? const <CashbookEntry>[];
          final overall = totalsOf(entries);
          final byProject = totalsByProject(entries);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              TotalsHeader(split: overall, caption: 'ALL PROJECTS'),
              const SizedBox(height: 18),
              const Text('By project', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (entries.isEmpty)
                const Text('No cashbook entries yet.', style: TextStyle(color: AppColors.muted))
              else
                ...byProject.entries.map(
                  (item) => MoneyLine(label: item.key, split: item.value),
                ),
            ],
          );
        },
      ),
    );
  }
}
