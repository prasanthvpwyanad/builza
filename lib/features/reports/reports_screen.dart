import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../core/session/session_scope.dart';
import '../../core/theme/app_theme.dart';
import 'category_report_screen.dart';
import 'monthly_report_screen.dart';
import 'project_report_screen.dart';
import 'statement_pdf.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _exporting = false;

  Future<void> _exportPdf() async {
    final session = SessionScope.maybeOf(context);
    if (session == null || !session.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to export a statement.')),
      );
      return;
    }
    setState(() => _exporting = true);
    try {
      final entries = await session.watchCashbook().first;
      final bytes = await buildCompanyStatementPdf(
        companyName: session.company?.name ?? 'BUILZA company',
        entries: entries,
      );
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'builza-${_fileStamp()}-statement.pdf',
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not export PDF. $error')),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  String _fileStamp() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Reports', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        const Text('Review business performance and export statements', style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_month, color: AppColors.blue),
                title: const Text('Monthly report'),
                subtitle: const Text('Income, expenses and monthly balance'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const MonthlyReportScreen()),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.apartment, color: AppColors.blue),
                title: const Text('Project-wise statement'),
                subtitle: const Text('Compare each project account'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const ProjectReportScreen()),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.category, color: AppColors.blue),
                title: const Text('Expense category report'),
                subtitle: const Text('Material, labour, transport and other'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const CategoryReportScreen()),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: AppColors.blue),
                title: const Text('Export PDF statement'),
                subtitle: const Text('Prepare a shareable financial statement'),
                trailing: _exporting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.chevron_right),
                onTap: _exporting ? null : _exportPdf,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Reports use live cashbook entries saved for this company.',
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ],
    );
  }
}
