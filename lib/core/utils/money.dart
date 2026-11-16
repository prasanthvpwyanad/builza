import 'package:intl/intl.dart';

final _inr = NumberFormat.decimalPattern('en_IN');

String formatInr(int rupees) => '₹ ${_inr.format(rupees)}';

String formatSignedInr(int rupees, {required bool paid}) {
  final prefix = paid ? '- ' : '+ ';
  return '$prefix${formatInr(rupees)}';
}

int? parseRupees(String? raw) {
  final cleaned = (raw ?? '').replaceAll(',', '').replaceAll('₹', '').trim();
  if (cleaned.isEmpty) return null;
  final value = double.tryParse(cleaned);
  if (value == null || value <= 0) return null;
  return value.round();
}

String relativeDay(DateTime? date) {
  if (date == null) return 'Just now';
  final now = DateTime.now();
  final day = DateTime(date.year, date.month, date.day);
  final today = DateTime(now.year, now.month, now.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return DateFormat('d MMM yyyy').format(date);
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
