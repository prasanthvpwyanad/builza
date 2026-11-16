import 'package:flutter/material.dart';
import '../../core/session/session_scope.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/join_code.dart';
import '../../core/widgets/builza_mark.dart';
import '../dashboard/dashboard_screen.dart';
import '../dues/dues_screen.dart';
import '../projects/projects_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/company_settings_screen.dart';
import '../transactions/add_entry_sheet.dart';
import '../transactions/transactions_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = const [
    DashboardScreen(),
    ProjectsScreen(),
    TransactionsScreen(),
    DuesScreen(),
    ReportsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowInvite());
  }

  void _maybeShowInvite() {
    final session = SessionScope.maybeOf(context);
    final code = session?.pendingInviteCode;
    if (session == null || code == null || !mounted) return;
    session.pendingInviteCode = null;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite Admin 2'),
        content: Text(
          'Share this one-time code with the second administrator:\n\n${formatJoinCode(code)}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            BuilzaMark(),
            SizedBox(width: 10),
            Text('BUILZA', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1)),
          ],
        ),
        actions: [
          if (SessionScope.maybeOf(context) != null)
            IconButton(
              tooltip: 'Company',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const CompanySettingsScreen()),
                );
              },
              icon: const Icon(Icons.manage_accounts_outlined),
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(child: _pages[_index]),
      floatingActionButton: _index == 2
          ? FloatingActionButton.extended(
              onPressed: () => _showAddEntry(context),
              backgroundColor: AppColors.blue,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add entry'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.apartment_rounded), label: 'Projects'),
          NavigationDestination(icon: Icon(Icons.swap_horiz_rounded), label: 'Cashbook'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Dues'),
          NavigationDestination(icon: Icon(Icons.bar_chart_rounded), label: 'Reports'),
        ],
      ),
    );
  }

  void _showAddEntry(BuildContext context) {
    showCashbookEntrySheet(context);
  }
}
