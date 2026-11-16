import 'package:flutter/material.dart';

import '../../core/session/session_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import '../../data/models/due.dart';
import 'add_due_sheet.dart';

class DuesScreen extends StatelessWidget {
  const DuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.maybeOf(context);
    return StreamBuilder<List<Due>>(
      stream: session?.watchDues() ?? Stream.value(const <Due>[]),
      builder: (context, snapshot) {
        final dues = snapshot.data ?? const <Due>[];
        final open = dues.where((due) => due.isOpen).toList();
        final payable = open.where((due) => due.isPayable).fold<int>(0, (sum, due) => sum + due.amount);
        if (snapshot.hasError) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Pending dues', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              Text('Could not load dues. ${snapshot.error}', style: const TextStyle(color: AppColors.red)),
            ],
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            const Text('Pending dues', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Track amounts payable and partial payments', style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TOTAL OUTSTANDING', style: TextStyle(color: AppColors.muted, fontSize: 11, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Text(formatInr(payable), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.navy)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => showDueSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Add due'),
            ),
            const SizedBox(height: 8),
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (open.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('No pending dues. Tap Add due to record one.', style: TextStyle(color: AppColors.muted, height: 1.4)),
              )
            else
              ...open.map(
                (due) => Card(
                  child: ListTile(
                    onTap: () => showDueSheet(context, due: due),
                    leading: CircleAvatar(
                      backgroundColor: due.isPayable ? const Color(0xFFFFEDEF) : const Color(0xFFE6F7F0),
                      child: Icon(
                        due.isPayable ? Icons.person_outline : Icons.south_west,
                        color: due.isPayable ? AppColors.red : AppColors.green,
                      ),
                    ),
                    title: Text(due.party, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      [
                        due.projectName,
                        due.isPayable ? 'Payable' : 'Receivable',
                        if (due.note.trim().isNotEmpty) due.note,
                      ].join(' • '),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatInr(due.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: due.isPayable ? AppColors.red : AppColors.green,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.edit_outlined, size: 18, color: AppColors.muted),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
