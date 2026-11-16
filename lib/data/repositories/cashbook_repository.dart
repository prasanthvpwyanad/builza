import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/auth_errors.dart';
import '../models/cashbook_entry.dart';
import '../tenant_paths.dart';

class CashbookRepository {
  CashbookRepository({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Stream<List<CashbookEntry>> watch(String companyId) {
    return TenantPaths.transactions(_db, companyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) => CashbookEntry.fromMap(doc.id, doc.data())).toList(),
        );
  }

  Future<void> add({
    required String companyId,
    required String createdBy,
    required String createdByName,
    required bool isReceived,
    required int amount,
    required String projectId,
    required String projectName,
    required String category,
    required String paymentMode,
    required String description,
  }) async {
    try {
      await TenantPaths.transactions(_db, companyId).add({
        'type': isReceived ? 'received' : 'paid',
        'amount': amount,
        'projectId': projectId,
        'projectName': projectName,
        'category': category,
        'paymentMode': paymentMode,
        'description': description.trim(),
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
    required String entryId,
    required String updatedBy,
    required bool isReceived,
    required int amount,
    required String projectId,
    required String projectName,
    required String category,
    required String paymentMode,
    required String description,
  }) async {
    try {
      await TenantPaths.transactions(_db, companyId).doc(entryId).update({
        'type': isReceived ? 'received' : 'paid',
        'amount': amount,
        'projectId': projectId,
        'projectName': projectName,
        'category': category,
        'paymentMode': paymentMode,
        'description': description.trim(),
        'updatedBy': updatedBy,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      throw AuthFailure(describeFirebaseError(error));
    }
  }
}
