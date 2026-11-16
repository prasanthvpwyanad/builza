import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.companyId,
    required this.email,
    required this.displayName,
    required this.role,
    required this.adminSlot,
    this.createdAt,
  });

  final String uid;
  final String companyId;
  final String email;
  final String displayName;
  final String role;
  final int adminSlot;
  final DateTime? createdAt;

  bool get isAdmin => role == 'admin';

  String get firstName {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty || parts.first.isEmpty ? 'there' : parts.first;
  }

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      companyId: data['companyId'] as String? ?? '',
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      role: data['role'] as String? ?? 'admin',
      adminSlot: (data['adminSlot'] as num?)?.toInt() ?? 1,
      createdAt: _readDate(data['createdAt']),
    );
  }
}

DateTime? _readDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}
