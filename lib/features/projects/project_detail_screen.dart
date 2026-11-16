import 'package:flutter/material.dart';

import '../../core/session/session_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import '../../data/demo/sample_projects.dart';
import '../../data/models/cashbook_entry.dart';
import '../../data/models/due.dart';
import '../dues/add_due_sheet.dart';
import '../transactions/add_entry_sheet.dart';
import '../transactions/cashbook_entry_tile.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key, required this.project});

  final SampleProject project;

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.maybeOf(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Project details')),
      body: StreamBuilder<List<CashbookEntry>>(
        stream: session?.watchCashbook() ?? Stream.value(const <CashbookEntry>[]),
        builder: (context, snapshot) {
          final entries = (snapshot.data ?? const <CashbookEntry>[]).where((entry) => entry.projectId == project.id).toList();
          final received = entries.where((entry) => !entry.isPaid).fold<int>(0, (sum, entry) => sum + entry.amount);
          final paid = entries.where((entry) => entry.isPaid).fold<int>(0, (sum, entry) => sum + entry.amount);
          return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(project.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.ink)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(project.status), visualDensity: VisualDensity.compact),
              Chip(
                avatar: const Icon(Icons.place_outlined, size: 16),
                label: Text(project.location),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Started ${project.startedOn}', style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Client', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 10),
                  _InfoRow(icon: Icons.person_outline, label: 'Name', value: project.client),
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.phone_outlined, label: 'Phone', value: project.clientPhone),
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.apartment_outlined, label: 'Site', value: project.location),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Account', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 12),
                  _MoneyRow(label: 'Agreement value', value: project.agreement),
                  _MoneyRow(label: 'Received from client', value: formatInr(received), color: AppColors.green),
                  _MoneyRow(label: 'Paid on site', value: formatInr(paid), color: AppColors.red),
                  const Divider(height: 22),
                  _MoneyRow(label: 'Project balance', value: formatInr(received - paid), emphasize: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Recent entries', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          if (entries.isEmpty)
            const Text('No cashbook entries on this project yet.', style: TextStyle(color: AppColors.muted))
          else
            ...entries.map(
              (entry) => CashbookEntryTile(
                entry: entry,
                onTap: () => showCashbookEntrySheet(context, entry: entry),
              ),
            ),
          const SizedBox(height: 18),
          const Text('Pending dues', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          StreamBuilder<List<Due>>(
            stream: session?.watchDues() ?? Stream.value(const <Due>[]),
            builder: (context, duesSnapshot) {
              final dues = (duesSnapshot.data ?? const <Due>[])
                  .where((due) => due.isOpen && due.projectId == project.id)
                  .toList();
              if (dues.isEmpty) {
                return const Text('No pending dues on this project.', style: TextStyle(color: AppColors.muted));
              }
              return Column(
                children: dues
                    .map(
                      (due) => Card(
                        child: ListTile(
                          onTap: () => showDueSheet(context, due: due),
                          leading: CircleAvatar(
                            backgroundColor: due.isPayable ? const Color(0xFFFFEDEF) : const Color(0xFFE6F7F0),
                            child: Icon(Icons.pending_actions_outlined, color: due.isPayable ? AppColors.red : AppColors.green),
                          ),
                          title: Text(due.party, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(due.note.trim().isEmpty ? (due.isPayable ? 'Payable' : 'Receivable') : due.note),
                          trailing: Text(
                            formatInr(due.amount),
                            style: TextStyle(fontWeight: FontWeight.w800, color: due.isPayable ? AppColors.red : AppColors.green),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 18),
          const Text('Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(project.notes, style: const TextStyle(color: AppColors.ink, height: 1.4)),
          const SizedBox(height: 16),
          const Text(
            'Cashbook figures are live. Client and site details are still sample project cards.',
            style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.35),
          ),
        ],
      );
        },
      ),
    );
  }
}

void openProjectDetails(BuildContext context, SampleProject project) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => ProjectDetailScreen(project: project)),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.blue),
        const SizedBox(width: 10),
        Text('$label  ', style: const TextStyle(color: AppColors.muted)),
        Expanded(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700), textAlign: TextAlign.right),
        ),
      ],
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({
    required this.label,
    required this.value,
    this.color,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Color? color;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: emphasize ? AppColors.ink : AppColors.muted,
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: emphasize ? 18 : 15,
              color: color ?? AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
