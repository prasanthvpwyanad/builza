import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/utils/auth_errors.dart';
import '../../core/utils/join_code.dart';
import '../models/app_user.dart';
import '../models/company.dart';
import '../tenant_paths.dart';

class AuthRepository {
  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } catch (error) {
      throw AuthFailure(describeFirebaseError(error));
    }
  }

  Future<String?> registerCompany({
    required String companyName,
    required String adminName,
    required String email,
    required String password,
    String? secondAdminEmail,
    Uint8List? logoBytes,
    String? logoContentType,
  }) async {
    UserCredential? credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthFailure('Could not create the administrator account.');
      }

      await user.updateDisplayName(adminName.trim());
      try {
        await user.sendEmailVerification();
      } catch (_) {}

      return _writeFirstAdminCompany(
        user: user,
        companyName: companyName,
        adminName: adminName,
        email: email,
        secondAdminEmail: secondAdminEmail,
        logoBytes: logoBytes,
        logoContentType: logoContentType,
      );
    } catch (error) {
      final uid = credential?.user?.uid;
      final linked = uid != null && await loadProfile(uid) != null;
      if (!linked) await _rollbackAuthUser(credential);
      throw AuthFailure(describeFirebaseError(error));
    }
  }

  Future<void> joinCompany({
    required String inviteCode,
    required String adminName,
    required String email,
    required String password,
  }) async {
    final code = normalizeJoinCode(inviteCode);
    if (!isValidJoinCode(code)) {
      throw const AuthFailure('Enter a valid 8-character invite code.');
    }

    UserCredential? credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthFailure('Could not create the administrator account.');
      }
      await user.updateDisplayName(adminName.trim());
      await _attachSecondAdmin(
        user: user,
        code: code,
        adminName: adminName,
        email: email,
      );
    } catch (error) {
      await _rollbackAuthUser(credential);
      throw AuthFailure(describeFirebaseError(error));
    }
  }

  Future<String?> registerCompanyForCurrentUser({
    required String companyName,
    required String adminName,
    String? secondAdminEmail,
    Uint8List? logoBytes,
    String? logoContentType,
  }) async {
    final user = _requireCurrentUser();
    try {
      await user.updateDisplayName(adminName.trim());
      return _writeFirstAdminCompany(
        user: user,
        companyName: companyName,
        adminName: adminName,
        email: user.email ?? '',
        secondAdminEmail: secondAdminEmail,
        logoBytes: logoBytes,
        logoContentType: logoContentType,
      );
    } catch (error) {
      throw AuthFailure(describeFirebaseError(error));
    }
  }

  Future<void> updateCompany({
    required String companyId,
    required String name,
    Uint8List? logoBytes,
    String? logoContentType,
  }) async {
    try {
      final trimmed = name.trim();
      if (trimmed.length < 2 || trimmed.length > 80) {
        throw const AuthFailure('Enter a company name between 2 and 80 characters.');
      }
      final data = <String, dynamic>{'name': trimmed};
      if (logoBytes != null && logoBytes.isNotEmpty) {
        final type = (logoContentType ?? 'image/jpeg').trim().toLowerCase();
        data['logoBytes'] = Blob(logoBytes);
        data['logoContentType'] = type == 'image/jpg' ? 'image/jpeg' : type;
        data['hasLogo'] = true;
        data['logoUpdatedAt'] = FieldValue.serverTimestamp();
      }
      await TenantPaths.company(_db, companyId).update(data);
    } catch (error) {
      throw AuthFailure(describeFirebaseError(error));
    }
  }

  Future<void> updateCompanyLogo({
    required String companyId,
    required Uint8List bytes,
    required String contentType,
  }) async {
    try {
      await _uploadCompanyLogo(
        companyId: companyId,
        bytes: bytes,
        contentType: contentType,
      );
    } catch (error) {
      throw AuthFailure(describeFirebaseError(error));
    }
  }

  Future<void> joinCompanyForCurrentUser({
    required String inviteCode,
    required String adminName,
  }) async {
    final user = _requireCurrentUser();
    final code = normalizeJoinCode(inviteCode);
    if (!isValidJoinCode(code)) {
      throw const AuthFailure('Enter a valid 8-character invite code.');
    }
    try {
      await user.updateDisplayName(adminName.trim());
      await _attachSecondAdmin(
        user: user,
        code: code,
        adminName: adminName,
        email: user.email ?? '',
      );
    } catch (error) {
      throw AuthFailure(describeFirebaseError(error));
    }
  }

  Future<String> createInvite({
    required Company company,
    String? secondAdminEmail,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthFailure('Sign in to invite the second administrator.');
    }
    if (!company.canInviteSecondAdmin) {
      throw const AuthFailure('This company already has two administrators.');
    }

    final code = generateJoinCode();
    final inviteEmail = _optionalEmail(secondAdminEmail);
    final expiresAt = Timestamp.fromDate(
      DateTime.now().toUtc().add(const Duration(days: joinInviteDays)),
    );

    try {
      final batch = _db.batch();
      final previous = company.activeInviteCode;
      if (previous != null && previous.isNotEmpty) {
        batch.delete(TenantPaths.joinCode(_db, normalizeJoinCode(previous)));
      }
      batch.set(TenantPaths.joinCode(_db, code), {
        'companyId': company.id,
        'email': inviteEmail,
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': expiresAt,
        'used': false,
      });
      batch.update(TenantPaths.company(_db, company.id), {
        'activeInviteCode': code,
        'activeInviteEmail': inviteEmail,
        'activeInviteExpiresAt': expiresAt,
      });
      await batch.commit();
      return code;
    } catch (error) {
      throw AuthFailure(describeFirebaseError(error));
    }
  }

  Future<AppUser?> loadProfile(String uid) async {
    final snap = await TenantPaths.user(_db, uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return AppUser.fromMap(uid, snap.data()!);
  }

  Future<Company?> loadCompany(String companyId) async {
    final snap = await TenantPaths.company(_db, companyId).get();
    if (!snap.exists || snap.data() == null) return null;
    final data = snap.data()!;
    return Company.fromMap(
      companyId,
      data,
      logoBytes: _readBytes(data['logoBytes']),
    );
  }

  Future<List<AppUser>> loadCompanyAdmins(String companyId) async {
    final snap = await TenantPaths.users(_db)
        .where('companyId', isEqualTo: companyId)
        .get();
    final admins = snap.docs.map((doc) => AppUser.fromMap(doc.id, doc.data())).toList()
      ..sort((a, b) => a.adminSlot.compareTo(b.adminSlot));
    return admins;
  }

  Future<void> signOut() => _auth.signOut();

  User _requireCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthFailure('Sign in to continue.');
    }
    return user;
  }

  Future<String?> _writeFirstAdminCompany({
    required User user,
    required String companyName,
    required String adminName,
    required String email,
    String? secondAdminEmail,
    Uint8List? logoBytes,
    String? logoContentType,
  }) async {
    final existing = await loadProfile(user.uid);
    if (existing != null) {
      throw const AuthFailure('This account is already linked to a company.');
    }

    final companyRef = TenantPaths.companies(_db).doc();
    final inviteEmail = _optionalEmail(secondAdminEmail);
    final hasLogo = logoBytes != null && logoBytes.isNotEmpty;
    final batch = _db.batch();
    batch.set(companyRef, {
      'name': companyName.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': user.uid,
      'adminUids': [user.uid],
      'adminCount': 1,
      'status': 'active',
      'hasLogo': hasLogo,
      if (hasLogo) 'logoBytes': Blob(logoBytes!),
      if (hasLogo) 'logoContentType': logoContentType ?? 'image/jpeg',
    });
    batch.set(TenantPaths.user(_db, user.uid), {
      'companyId': companyRef.id,
      'email': email.trim().toLowerCase(),
      'displayName': adminName.trim(),
      'role': 'admin',
      'adminSlot': 1,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();

    if (inviteEmail == null) return null;
    try {
      return await createInvite(
        company: Company(
          id: companyRef.id,
          name: companyName.trim(),
          createdBy: user.uid,
          adminUids: [user.uid],
          adminCount: 1,
          status: 'active',
        ),
        secondAdminEmail: inviteEmail,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _attachSecondAdmin({
    required User user,
    required String code,
    required String adminName,
    required String email,
  }) async {
    final inviteRef = TenantPaths.joinCode(_db, code);
    final userRef = TenantPaths.user(_db, user.uid);

    await _db.runTransaction((tx) async {
      final inviteSnap = await tx.get(inviteRef);
      if (!inviteSnap.exists) {
        throw const AuthFailure('This invite code is invalid.');
      }
      final invite = inviteSnap.data()!;
      if (invite['used'] == true) {
        throw const AuthFailure('This invite code has already been used.');
      }
      final expiresAt = invite['expiresAt'];
      if (expiresAt is Timestamp && expiresAt.toDate().isBefore(DateTime.now())) {
        throw const AuthFailure('This invite code has expired.');
      }
      final expectedEmail = (invite['email'] as String?)?.trim().toLowerCase();
      if (expectedEmail != null &&
          expectedEmail.isNotEmpty &&
          expectedEmail != email.trim().toLowerCase()) {
        throw const AuthFailure('This invite is locked to a different email address.');
      }

      final companyId = invite['companyId'] as String? ?? '';
      final companyRef = TenantPaths.company(_db, companyId);
      final companySnap = await tx.get(companyRef);
      if (!companySnap.exists) {
        throw const AuthFailure('The company for this invite no longer exists.');
      }
      final company = companySnap.data()!;
      final adminUids = List<String>.from(company['adminUids'] as List? ?? const []);
      if (adminUids.length >= 2 || (company['adminCount'] as num?)?.toInt() == 2) {
        throw const AuthFailure('This company already has two administrators.');
      }
      if (adminUids.contains(user.uid)) {
        throw const AuthFailure('This account is already an administrator.');
      }

      tx.update(companyRef, {
        'adminUids': [...adminUids, user.uid],
        'adminCount': 2,
        'activeInviteCode': FieldValue.delete(),
        'activeInviteEmail': FieldValue.delete(),
        'activeInviteExpiresAt': FieldValue.delete(),
      });
      tx.set(userRef, {
        'companyId': companyId,
        'email': email.trim().toLowerCase(),
        'displayName': adminName.trim(),
        'role': 'admin',
        'adminSlot': 2,
        'joinCode': code,
        'createdAt': FieldValue.serverTimestamp(),
      });
      tx.update(inviteRef, {
        'used': true,
        'usedBy': user.uid,
        'usedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> _uploadCompanyLogo({
    required String companyId,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final type = contentType.trim().toLowerCase();
    await TenantPaths.company(_db, companyId).update({
      'logoBytes': Blob(bytes),
      'logoContentType': type == 'image/jpg' ? 'image/jpeg' : type,
      'hasLogo': true,
      'logoUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  Uint8List? _readBytes(dynamic value) {
    if (value is Uint8List) return value;
    if (value is Blob) return value.bytes;
    if (value is List<int>) return Uint8List.fromList(value);
    return null;
  }

  String? _optionalEmail(String? value) {
    final trimmed = value?.trim().toLowerCase() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _rollbackAuthUser(UserCredential? credential) async {
    final user = credential?.user;
    if (user == null) return;
    try {
      await user.delete();
    } catch (_) {}
  }
}
