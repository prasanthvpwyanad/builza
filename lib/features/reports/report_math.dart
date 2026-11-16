import '../../data/demo/sample_projects.dart';
import '../../data/models/cashbook_entry.dart';

class MoneySplit {
  const MoneySplit({this.received = 0, this.paid = 0});

  final int received;
  final int paid;

  int get balance => received - paid;
  int get volume => received + paid;
}

MoneySplit totalsOf(Iterable<CashbookEntry> entries) {
  var received = 0;
  var paid = 0;
  for (final entry in entries) {
    if (entry.isPaid) {
      paid += entry.amount;
    } else {
      received += entry.amount;
    }
  }
  return MoneySplit(received: received, paid: paid);
}

DateTime monthOf(CashbookEntry entry) {
  final date = entry.createdAt ?? DateTime.now();
  return DateTime(date.year, date.month);
}

bool isInMonth(CashbookEntry entry, DateTime month) {
  final value = monthOf(entry);
  return value.year == month.year && value.month == month.month;
}

List<DateTime> reportMonths(List<CashbookEntry> entries) {
  final months = <String, DateTime>{};
  for (final entry in entries) {
    final month = monthOf(entry);
    months['${month.year}-${month.month}'] = month;
  }
  final now = DateTime(DateTime.now().year, DateTime.now().month);
  months['${now.year}-${now.month}'] = now;
  final list = months.values.toList()..sort((a, b) => b.compareTo(a));
  return list;
}

Map<String, MoneySplit> totalsByProject(List<CashbookEntry> entries) {
  final splits = <String, MoneySplit>{
    for (final project in sampleProjects) project.name: const MoneySplit(),
  };
  for (final entry in entries) {
    final name = entry.projectName.trim().isEmpty ? 'Unassigned' : entry.projectName;
    final current = splits[name] ?? const MoneySplit();
    splits[name] = entry.isPaid
        ? MoneySplit(received: current.received, paid: current.paid + entry.amount)
        : MoneySplit(received: current.received + entry.amount, paid: current.paid);
  }
  return splits;
}

List<CashbookEntry> sortedEntries(List<CashbookEntry> entries) {
  final copy = [...entries];
  copy.sort((a, b) {
    final left = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final right = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return right.compareTo(left);
  });
  return copy;
}

Map<String, int> paidByCategory(List<CashbookEntry> entries) {
  const order = ['Material', 'Labour', 'Transport', 'Advance', 'Other'];
  final totals = {for (final category in order) category: 0};
  for (final entry in entries.where((item) => item.isPaid)) {
    final category = totals.containsKey(entry.category) ? entry.category : 'Other';
    totals[category] = (totals[category] ?? 0) + entry.amount;
  }
  return totals;
}
