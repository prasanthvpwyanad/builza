import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class Company {
  const Company({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.adminUids,
    required this.adminCount,
    required this.status,
    this.createdAt,
    this.logoUrl,
    this.logoBytes,
    this.activeInviteCode,
    this.activeInviteEmail,
    this.activeInviteExpiresAt,
  });

  final String id;
  final String name;
  final String createdBy;
  final List<String> adminUids;
  final int adminCount;
  final String status;
  final DateTime? createdAt;
  final String? logoUrl;
  final Uint8List? logoBytes;
  final String? activeInviteCode;
  final String? activeInviteEmail;
  final DateTime? activeInviteExpiresAt;

  bool get hasLogo =>
      (logoBytes != null && logoBytes!.isNotEmpty) || (logoUrl != null && logoUrl!.trim().isNotEmpty);

  bool get canInviteSecondAdmin => adminCount < 2;

  bool get hasActiveInvite {
    if (activeInviteCode == null || activeInviteCode!.isEmpty) return false;
    final expires = activeInviteExpiresAt;
    if (expires == null) return true;
    return expires.isAfter(DateTime.now());
  }

  factory Company.fromMap(String id, Map<String, dynamic> data, {Uint8List? logoBytes}) {
    return Company(
      id: id,
      name: data['name'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      adminUids: List<String>.from(data['adminUids'] as List? ?? const []),
      adminCount: (data['adminCount'] as num?)?.toInt() ?? 0,
      status: data['status'] as String? ?? 'active',
      createdAt: _readDate(data['createdAt']),
      logoUrl: data['logoUrl'] as String?,
      logoBytes: logoBytes,
      activeInviteCode: data['activeInviteCode'] as String?,
      activeInviteEmail: data['activeInviteEmail'] as String?,
      activeInviteExpiresAt: _readDate(data['activeInviteExpiresAt']),
    );
  }

  Company copyWith({Uint8List? logoBytes, String? logoUrl}) {
    return Company(
      id: id,
      name: name,
      createdBy: createdBy,
      adminUids: adminUids,
      adminCount: adminCount,
      status: status,
      createdAt: createdAt,
      logoUrl: logoUrl ?? this.logoUrl,
      logoBytes: logoBytes ?? this.logoBytes,
      activeInviteCode: activeInviteCode,
      activeInviteEmail: activeInviteEmail,
      activeInviteExpiresAt: activeInviteExpiresAt,
    );
  }
}

DateTime? _readDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}
