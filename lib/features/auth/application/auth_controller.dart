import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failures.dart';
import '../data/repositories/local_auth_repository.dart';
import '../domain/entities/auth_session.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repository) {
    _restoreRememberedSession();
  }
  final LocalAuthRepository _repository;
  AuthSession? session;
  bool isLoading = false;
  bool isRestoringSession = true;
  String? error;
  String? notice;
  int _sessionGeneration = 0;
  bool _disposed = false;
  bool get isAuthenticated => session != null;
  Future<bool> hasUsers() => _repository.hasUsers();
  Future<String?> rememberedUsername() => _repository.rememberedUsername();

  Future<bool> signIn(
    String username,
    String password, {
    bool rememberLogin = false,
  }) async {
    _sessionGeneration++;
    isLoading = true;
    error = null;
    notice = null;
    notifyListeners();
    try {
      session = await _repository.signIn(
        username,
        password,
        rememberLogin: rememberLogin,
      );
      return true;
    } catch (e) {
      error = _messageFrom(e, fallback: 'Não foi possível entrar.');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAccount({
    required String username,
    required String displayName,
    required String password,
    bool rememberLogin = false,
  }) async {
    _sessionGeneration++;
    isLoading = true;
    error = null;
    notice = null;
    notifyListeners();
    try {
      final result = await _repository.createAccount(
        username: username,
        displayName: displayName,
        password: password,
        rememberLogin: rememberLogin,
      );
      session = result.session;
      notice = result.message;
      return result.signedIn;
    } catch (e) {
      error = _messageFrom(e, fallback: 'Não foi possível criar a conta.');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _sessionGeneration++;
    await _repository.signOut();
    session = null;
    error = null;
    notice = null;
    notifyListeners();
  }

  bool allows(String permission) => session?.allows(permission) ?? false;

  Future<void> _restoreRememberedSession() async {
    final restoreGeneration = _sessionGeneration;
    try {
      final restoredSession = await _repository.restoreRememberedSession();
      if (restoreGeneration == _sessionGeneration) {
        session = restoredSession;
      }
    } catch (_) {
      if (restoreGeneration == _sessionGeneration) session = null;
    } finally {
      isRestoringSession = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  String _messageFrom(Object error, {required String fallback}) {
    if (error is AppFailure) return error.message;
    if (error is ArgumentError) {
      final message = error.message;
      return message == null ? fallback : message.toString();
    }
    if (error is StateError) return error.message;
    return fallback;
  }
}

final authControllerProvider = ChangeNotifierProvider<AuthController>(
  (ref) => AuthController(LocalAuthRepository(ref.watch(databaseProvider))),
);
