import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/app_user.dart';
import '../../data/models/cashbook_entry.dart';
import '../../data/models/company.dart';
import '../../data/models/due.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/cashbook_repository.dart';
import '../../data/repositories/dues_repository.dart';
import '../utils/auth_errors.dart';

enum SessionStatus {
  loading,
  unauthenticated,
  authenticated,
  profileMissing,
  error,
}

class SessionController extends ChangeNotifier {
  SessionController({
    AuthRepository? repository,
    CashbookRepository? cashbook,
    DuesRepository? dues,
  })  : _repository = repository ?? AuthRepository(),
        _cashbook = cashbook ?? CashbookRepository(),
        _dues = dues ?? DuesRepository();

  final AuthRepository _repository;
  final CashbookRepository _cashbook;
  final DuesRepository _dues;
  StreamSubscription<User?>? _authSub;
  int _ops = 0;

  SessionStatus status = SessionStatus.loading;
  AppUser? user;
  Company? company;
  String? errorMessage;
  bool busy = false;
  String? pendingInviteCode;

  bool get isAuthenticated => status == SessionStatus.authenticated && company != null;

  String? get authEmail => _repository.currentUser?.email;

  void start() {
    _authSub ??= _repository.authStateChanges().listen(_onAuthChanged);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) {
    return _run(() => _repository.signIn(email: email, password: password));
  }

  Future<void> registerCompany({
    required String companyName,
    required String adminName,
    required String email,
    required String password,
    String? secondAdminEmail,
    Uint8List? logoBytes,
    String? logoContentType,
  }) {
    return _run(() async {
      pendingInviteCode = await _repository.registerCompany(
        companyName: companyName,
        adminName: adminName,
        email: email,
        password: password,
        secondAdminEmail: secondAdminEmail,
        logoBytes: logoBytes,
        logoContentType: logoContentType,
      );
    });
  }

  Future<void> registerCompanyForCurrentUser({
    required String companyName,
    required String adminName,
    String? secondAdminEmail,
    Uint8List? logoBytes,
    String? logoContentType,
  }) {
    return _run(() async {
      pendingInviteCode = await _repository.registerCompanyForCurrentUser(
        companyName: companyName,
        adminName: adminName,
        secondAdminEmail: secondAdminEmail,
        logoBytes: logoBytes,
        logoContentType: logoContentType,
      );
    });
  }

  Future<void> updateCompany({
    required String name,
    Uint8List? logoBytes,
    String? logoContentType,
  }) {
    return _run(() async {
      final current = company;
      if (current == null) {
        throw const AuthFailure('No company is loaded.');
      }
      await _repository.updateCompany(
        companyId: current.id,
        name: name,
        logoBytes: logoBytes,
        logoContentType: logoContentType,
      );
    });
  }

  Future<void> joinCompany({
    required String inviteCode,
    required String adminName,
    required String email,
    required String password,
  }) {
    return _run(() => _repository.joinCompany(
          inviteCode: inviteCode,
          adminName: adminName,
          email: email,
          password: password,
        ));
  }

  Future<void> joinCompanyForCurrentUser({
    required String inviteCode,
    required String adminName,
  }) {
    return _run(() => _repository.joinCompanyForCurrentUser(
          inviteCode: inviteCode,
          adminName: adminName,
        ));
  }

  Future<String> inviteSecondAdmin({String? email}) {
    return _run(() async {
      final current = company;
      if (current == null) {
        throw const AuthFailure('No company is loaded.');
      }
      final code = await _repository.createInvite(
        company: current,
        secondAdminEmail: email,
      );
      company = await _repository.loadCompany(current.id);
      return code;
    });
  }

  Future<List<AppUser>> loadAdmins() async {
    final companyId = company?.id;
    if (companyId == null) return const [];
    return _repository.loadCompanyAdmins(companyId);
  }

  Stream<List<CashbookEntry>> watchCashbook() {
    final companyId = company?.id;
    if (companyId == null) return Stream.value(const []);
    return _cashbook.watch(companyId);
  }

  Future<void> addCashbookEntry({
    required bool isReceived,
    required int amount,
    required String projectId,
    required String projectName,
    required String category,
    required String paymentMode,
    required String description,
  }) async {
    final currentCompany = company;
    final currentUser = user;
    if (currentCompany == null || currentUser == null) {
      throw const AuthFailure('Sign in to save cashbook entries.');
    }
    if (amount <= 0) {
      throw const AuthFailure('Enter an amount greater than zero.');
    }
    if (projectId.isEmpty) {
      throw const AuthFailure('Select a project.');
    }
    await _cashbook.add(
      companyId: currentCompany.id,
      createdBy: currentUser.uid,
      createdByName: currentUser.displayName,
      isReceived: isReceived,
      amount: amount,
      projectId: projectId,
      projectName: projectName,
      category: category,
      paymentMode: paymentMode,
      description: description,
    );
  }

  Future<void> updateCashbookEntry({
    required String entryId,
    required bool isReceived,
    required int amount,
    required String projectId,
    required String projectName,
    required String category,
    required String paymentMode,
    required String description,
  }) async {
    final currentCompany = company;
    final currentUser = user;
    if (currentCompany == null || currentUser == null) {
      throw const AuthFailure('Sign in to edit cashbook entries.');
    }
    if (amount <= 0) {
      throw const AuthFailure('Enter an amount greater than zero.');
    }
    if (projectId.isEmpty) {
      throw const AuthFailure('Select a project.');
    }
    await _cashbook.update(
      companyId: currentCompany.id,
      entryId: entryId,
      updatedBy: currentUser.uid,
      isReceived: isReceived,
      amount: amount,
      projectId: projectId,
      projectName: projectName,
      category: category,
      paymentMode: paymentMode,
      description: description,
    );
  }

  Stream<List<Due>> watchDues() {
    final companyId = company?.id;
    if (companyId == null) return Stream.value(const []);
    return _dues.watch(companyId);
  }

  Future<void> addDue({
    required String party,
    required int amount,
    required String projectId,
    required String projectName,
    required String note,
    required String kind,
  }) async {
    final currentCompany = company;
    final currentUser = user;
    if (currentCompany == null || currentUser == null) {
      throw const AuthFailure('Sign in to save dues.');
    }
    if (amount <= 0) {
      throw const AuthFailure('Enter an amount greater than zero.');
    }
    if (party.trim().length < 2) {
      throw const AuthFailure('Enter the party name.');
    }
    await _dues.add(
      companyId: currentCompany.id,
      createdBy: currentUser.uid,
      createdByName: currentUser.displayName,
      party: party,
      amount: amount,
      projectId: projectId,
      projectName: projectName,
      note: note,
      kind: kind,
    );
  }

  Future<void> updateDue({
    required String dueId,
    required String party,
    required int amount,
    required String projectId,
    required String projectName,
    required String note,
    required String kind,
    required String status,
  }) async {
    final currentCompany = company;
    final currentUser = user;
    if (currentCompany == null || currentUser == null) {
      throw const AuthFailure('Sign in to edit dues.');
    }
    if (status != 'settled' && amount <= 0) {
      throw const AuthFailure('Enter an amount greater than zero.');
    }
    await _dues.update(
      companyId: currentCompany.id,
      dueId: dueId,
      updatedBy: currentUser.uid,
      party: party,
      amount: amount,
      projectId: projectId,
      projectName: projectName,
      note: note,
      kind: kind,
      status: status,
    );
  }

  Future<void> signOut() async {
    pendingInviteCode = null;
    await _repository.signOut();
  }

  Future<void> retry() => _refresh(_repository.currentUser);

  Future<T> _run<T>(Future<T> Function() action) async {
    busy = true;
    errorMessage = null;
    notifyListeners();
    _ops++;
    try {
      final result = await action();
      await _refresh(_repository.currentUser);
      return result;
    } catch (error) {
      errorMessage = describeFirebaseError(error);
      notifyListeners();
      throw AuthFailure(errorMessage!);
    } finally {
      _ops--;
      busy = false;
      notifyListeners();
    }
  }

  Future<void> _onAuthChanged(User? firebaseUser) async {
    if (_ops > 0) return;
    await _refresh(firebaseUser);
  }

  Future<void> _refresh(User? firebaseUser) async {
    if (firebaseUser == null) {
      user = null;
      company = null;
      status = SessionStatus.unauthenticated;
      notifyListeners();
      return;
    }

    status = SessionStatus.loading;
    notifyListeners();

    try {
      final profile = await _repository.loadProfile(firebaseUser.uid);
      if (profile == null || profile.companyId.isEmpty) {
        user = null;
        company = null;
        status = SessionStatus.profileMissing;
        notifyListeners();
        return;
      }
      final loadedCompany = await _repository.loadCompany(profile.companyId);
      if (loadedCompany == null) {
        user = profile;
        company = null;
        status = SessionStatus.profileMissing;
        notifyListeners();
        return;
      }
      user = profile;
      company = loadedCompany;
      status = SessionStatus.authenticated;
      errorMessage = null;
      notifyListeners();
    } catch (error) {
      errorMessage = describeFirebaseError(error);
      status = SessionStatus.error;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
