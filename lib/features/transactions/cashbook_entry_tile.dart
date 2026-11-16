import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/money.dart';
import '../../data/models/cashbook_entry.dart';

class CashbookEntryTile extends StatelessWidget {
  const CashbookEntryTile({super.key, required this.entry, this.onTap});

  final CashbookEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final paid = entry.isPaid;
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: paid ? const Color(0xFFFFEDEF) : const Color(0xFFE6F7F0),
          child: Icon(paid ? Icons.north_east : Icons.south_west, color: paid ? AppColors.red : AppColors.green),
        ),
        title: Text(entry.title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          '${entry.projectName} • ${entry.category} • ${entry.paymentMode} • ${relativeDay(entry.createdAt)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatSignedInr(entry.amount, paid: paid),
              style: TextStyle(fontWeight: FontWeight.w800, color: paid ? AppColors.red : AppColors.green),
            ),
            const SizedBox(width: 6),
            Icon(onTap == null ? Icons.chevron_right : Icons.edit_outlined, size: 18, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
