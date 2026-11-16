import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/auth_errors.dart';
import '../models/due.dart';
import '../tenant_paths.dart';

class DuesRepository {
  DuesRepository({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Stream<List<Due>> watch(String companyId) {
    return TenantPaths.dues(_db, companyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Due.fromMap(doc.id, doc.data())).toList());
  }

  Future<void> add({
    required String companyId,
    required String createdBy,
    required String createdByName,
    required String party,
    required int amount,
    required String projectId,
    required String projectName,
    required String note,
    required String kind,
  }) async {
    try {
      await TenantPaths.dues(_db, companyId).add({
        'party': party.trim(),
        'amount': amount,
        'projectId': projectId,
        'projectName': projectName,
        'note': note.trim(),
        'kind': kind,
        'status': 'open',
        'createdBy': createdBy,
        'createdByName': createdByName,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      throw AuthFailure(describeFirebaseError(error));
    }
  }

  Future<void> update({
    required String companyId,
    required String dueId,
    required String updatedBy,
    required String party,
    required int amount,
    required String projectId,
    required String projectName,
    required String note,
    required String kind,
    required String status,
  }) async {
    try {
      await TenantPaths.dues(_db, companyId).doc(dueId).update({
        'party': party.trim(),
        'amount': amount,
        'projectId': projectId,
        'projectName': projectName,
        'note': note.trim(),
        'kind': kind,
        'status': status,
        'updatedBy': updatedBy,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      throw AuthFailure(describeFirebaseError(error));
    }
  }
}
