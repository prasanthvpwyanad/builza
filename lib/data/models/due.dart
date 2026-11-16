import 'package:cloud_firestore/cloud_firestore.dart';

class Due {
  const Due({
    required this.id,
    required this.party,
    required this.amount,
    required this.projectId,
    required this.projectName,
    required this.note,
    required this.kind,
    required this.status,
    required this.createdBy,
    required this.createdByName,
    this.createdAt,
  });

  final String id;
  final String party;
  final int amount;
  final String projectId;
  final String projectName;
  final String note;
  final String kind;
  final String status;
  final String createdBy;
  final String createdByName;
  final DateTime? createdAt;

  bool get isPayable => kind != 'receivable';
  bool get isOpen => status != 'settled' && amount > 0;

  factory Due.fromMap(String id, Map<String, dynamic> data) {
    return Due(
      id: id,
      party: data['party'] as String? ?? '',
      amount: (data['amount'] as num?)?.toInt() ?? 0,
      projectId: data['projectId'] as String? ?? '',
      projectName: data['projectName'] as String? ?? '',
      note: data['note'] as String? ?? '',
      kind: data['kind'] as String? ?? 'payable',
      status: data['status'] as String? ?? 'open',
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
