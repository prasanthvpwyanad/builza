import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import 'report_math.dart';

class ReportScaffold extends StatelessWidget {
  const ReportScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: child,
    );
  }
}

class ReportEmpty extends StatelessWidget {
  const ReportEmpty({super.key, this.message = 'Add cashbook entries to generate this report.'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, height: 1.4)),
      ),
    );
  }
}

class TotalsHeader extends StatelessWidget {
  const TotalsHeader({super.key, required this.split, this.caption});

  final MoneySplit split;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.navy, AppColors.blue], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(caption ?? 'BALANCE', style: const TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.2)),
          const SizedBox(height: 6),
          Text(formatInr(split.balance), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Text('Received  ${formatInr(split.received)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
              Expanded(child: Text('Paid  ${formatInr(split.paid)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
            ],
          ),
        ],
      ),
    );
  }
}

class MoneyLine extends StatelessWidget {
  const MoneyLine({
    super.key,
    required this.label,
    required this.split,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final MoneySplit split;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(
          subtitle ?? 'Received ${formatInr(split.received)}  •  Paid ${formatInr(split.paid)}',
          style: const TextStyle(color: AppColors.muted),
        ),
        trailing: Text(
          formatInr(split.balance),
          style: TextStyle(fontWeight: FontWeight.w800, color: split.balance >= 0 ? AppColors.green : AppColors.red),
        ),
      ),
    );
  }
}

