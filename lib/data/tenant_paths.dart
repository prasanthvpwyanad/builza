import 'package:cloud_firestore/cloud_firestore.dart';

/// Canonical multi-tenant paths. Every financial record lives under a company.
class TenantPaths {
  TenantPaths._();

  static CollectionReference<Map<String, dynamic>> companies(FirebaseFirestore db) =>
      db.collection('companies');

  static DocumentReference<Map<String, dynamic>> company(
    FirebaseFirestore db,
    String companyId,
  ) =>
      companies(db).doc(companyId);

  static CollectionReference<Map<String, dynamic>> users(FirebaseFirestore db) =>
      db.collection('users');

  static DocumentReference<Map<String, dynamic>> user(FirebaseFirestore db, String uid) =>
      users(db).doc(uid);

  static CollectionReference<Map<String, dynamic>> joinCodes(FirebaseFirestore db) =>
      db.collection('joinCodes');

  static DocumentReference<Map<String, dynamic>> joinCode(
    FirebaseFirestore db,
    String code,
  ) =>
      joinCodes(db).doc(code);

  static CollectionReference<Map<String, dynamic>> projects(
    FirebaseFirestore db,
    String companyId,
  ) =>
      company(db, companyId).collection('projects');

  static CollectionReference<Map<String, dynamic>> transactions(
    FirebaseFirestore db,
    String companyId,
  ) =>
      company(db, companyId).collection('transactions');

  static CollectionReference<Map<String, dynamic>> dues(
    FirebaseFirestore db,
    String companyId,
  ) =>
      company(db, companyId).collection('dues');
}
