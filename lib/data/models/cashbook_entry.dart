import 'package:cloud_firestore/cloud_firestore.dart';

class CashbookEntry {
  const CashbookEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.projectId,
    required this.projectName,
    required this.category,
    required this.paymentMode,
    required this.description,
    required this.createdBy,
    required this.createdByName,
    this.createdAt,
  });

  final String id;
  final String type;
  final int amount;
  final String projectId;
  final String projectName;
  final String category;
  final String paymentMode;
  final String description;
  final String createdBy;
  final String createdByName;
  final DateTime? createdAt;

  bool get isPaid => type == 'paid';

  String get title {
    final text = description.trim();
    if (text.isNotEmpty) return text;
    return isPaid ? category : (category == 'Advance' ? 'Client advance' : category);
  }

  factory CashbookEntry.fromMap(String id, Map<String, dynamic> data) {
    return CashbookEntry(
      id: id,
      type: data['type'] as String? ?? 'paid',
      amount: (data['amount'] as num?)?.toInt() ?? 0,
      projectId: data['projectId'] as String? ?? '',
      projectName: data['projectName'] as String? ?? '',
      category: data['category'] as String? ?? 'Other',
      paymentMode: data['paymentMode'] as String? ?? 'Cash',
      description: data['description'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      createdByName: data['createdByName'] as String? ?? '',
      createdAt: _readDate(data['createdAt']),
    );
  }
}

DateTime? _readDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}
