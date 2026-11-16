import 'package:flutter/material.dart';
import '../../core/session/session_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/company_logo.dart';
import '../../core/utils/money.dart';
import '../../data/demo/sample_projects.dart';
import '../../data/models/cashbook_entry.dart';
import '../../data/models/due.dart';
import '../projects/project_detail_screen.dart';
import '../transactions/add_entry_sheet.dart';
import '../transactions/cashbook_entry_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.maybeOf(context);
    final greetingName = session?.user?.firstName;
    final companyName = session?.company?.name ?? 'Business overview';
    return StreamBuilder<List<CashbookEntry>>(
      stream: session?.watchCashbook() ?? Stream.value(const <CashbookEntry>[]),
      builder: (context, snapshot) {
        final entries = snapshot.data ?? const <CashbookEntry>[];
        final received = entries.where((entry) => !entry.isPaid).fold<int>(0, (sum, entry) => sum + entry.amount);
        final paid = entries.where((entry) => entry.isPaid).fold<int>(0, (sum, entry) => sum + entry.amount);
        final today = DateTime.now();
        final todayPaid = entries
            .where((entry) => entry.isPaid && entry.createdAt != null && isSameDay(entry.createdAt!, today))
            .fold<int>(0, (sum, entry) => sum + entry.amount);
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              greetingName == null ? 'Good morning 👋' : 'Good morning, $greetingName 👋',
              style: const TextStyle(color: AppColors.muted, fontSize: 14),
            ),
            const SizedBox(height: 10),
            CompanyIdentityCard(
              name: companyName,
              bytes: session?.company?.logoBytes,
              url: session?.company?.logoUrl,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.navy, AppColors.blue], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CASH IN HAND', style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Text(formatInr(received - paid), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _MiniBalance(label: 'Received', amount: formatInr(received), icon: Icons.south_west)),
                      Expanded(child: _MiniBalance(label: 'Paid', amount: formatInr(paid), icon: Icons.north_east)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: _MetricCard(title: "Today's paid", amount: formatInr(todayPaid), icon: Icons.today, color: AppColors.red)),
                const SizedBox(width: 12),
                Expanded(
                  child: StreamBuilder<List<Due>>(
                    stream: session?.watchDues() ?? Stream.value(const <Due>[]),
                    builder: (context, duesSnapshot) {
                      final outstanding = (duesSnapshot.data ?? const <Due>[])
                          .where((due) => due.isOpen && due.isPayable)
                          .fold<int>(0, (sum, due) => sum + due.amount);
                      return _MetricCard(title: 'Pending dues', amount: formatInr(outstanding), icon: Icons.pending_actions, color: AppColors.blue);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Text('Project snapshot', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            ...sampleProjects.map((project) {
              final projectReceived = entries.where((entry) => entry.projectId == project.id && !entry.isPaid).fold<int>(0, (sum, entry) => sum + entry.amount);
              final projectPaid = entries.where((entry) => entry.projectId == project.id && entry.isPaid).fold<int>(0, (sum, entry) => sum + entry.amount);
              return _ProjectTile(project: project, balance: projectReceived - projectPaid);
            }),
            const SizedBox(height: 18),
            const Text('Recent activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            if (entries.isEmpty)
              const Text('No cashbook entries yet. Open Cashbook and tap Add entry.', style: TextStyle(color: AppColors.muted, height: 1.4))
            else
              ...entries.take(5).map(
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

class _MiniBalance extends StatelessWidget {
  final String label, amount;
  final IconData icon;
  const _MiniBalance({required this.label, required this.amount, required this.icon});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: Colors.white70, size: 16),
      const SizedBox(width: 6),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        Text(amount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ])),
    ],
  );
}

class _MetricCard extends StatelessWidget {
  final String title, amount;
  final IconData icon;
  final Color color;
  const _MetricCard({required this.title, required this.amount, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        const SizedBox(height: 4),
        Text(amount, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      ]),
    ),
  );
}

class _ProjectTile extends StatelessWidget {
  const _ProjectTile({required this.project, required this.balance});

  final SampleProject project;
  final int balance;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: () => openProjectDetails(context, project),
      leading: const CircleAvatar(backgroundColor: Color(0xFFE7F2FF), child: Icon(Icons.apartment, color: AppColors.blue)),
      title: Text(project.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      subtitle: Text('Client: ${project.client}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatInr(balance),
            style: TextStyle(fontWeight: FontWeight.w800, color: balance >= 0 ? AppColors.green : AppColors.red),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    ),
  );
}
