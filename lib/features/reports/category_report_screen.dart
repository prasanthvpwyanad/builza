import 'package:flutter/material.dart';

import '../../core/session/session_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import '../../data/models/cashbook_entry.dart';
import 'report_math.dart';
import 'report_widgets.dart';

class CategoryReportScreen extends StatelessWidget {
  const CategoryReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.maybeOf(context);
    return ReportScaffold(
      title: 'Expense category report',
      child: StreamBuilder<List<CashbookEntry>>(
        stream: session?.watchCashbook() ?? Stream.value(const <CashbookEntry>[]),
        builder: (context, snapshot) {
          final entries = snapshot.data ?? const <CashbookEntry>[];
          final paidEntries = entries.where((entry) => entry.isPaid).toList();
          final overall = totalsOf(entries);
          final categories = paidByCategory(entries);
          final paidTotal = categories.values.fold<int>(0, (sum, value) => sum + value);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              TotalsHeader(split: overall, caption: 'PAID BY CATEGORY'),
              const SizedBox(height: 18),
              const Text('Expense split', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (paidEntries.isEmpty)
                const Text('No paid entries yet.', style: TextStyle(color: AppColors.muted))
              else
                ...categories.entries.map((item) {
                  final fraction = paidTotal == 0 ? 0.0 : item.value / paidTotal;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(item.key, style: const TextStyle(fontWeight: FontWeight.w800))),
                              Text(formatInr(item.value), style: const TextStyle(fontWeight: FontWeight.w800)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              minHeight: 8,
                              value: fraction,
                              color: AppColors.blue,
                              backgroundColor: const Color(0xFFE7F2FF),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text('${(fraction * 100).toStringAsFixed(0)}% of paid', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
