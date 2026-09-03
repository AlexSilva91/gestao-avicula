import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failures.dart';
import '../data/repositories/local_auth_repository.dart';
import '../domain/entities/auth_session.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repository);
  final LocalAuthRepository _repository;
  AuthSession? session;
  bool isLoading = false;
  String? error;
  String? notice;
  bool get isAuthenticated => session != null;
  Future<bool> hasUsers() => _repository.hasUsers();

  Future<bool> signIn(String username, String password) async {
    isLoading = true;
    error = null;
    notice = null;
    notifyListeners();
    try {
      session = await _repository.signIn(username, password);
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
  }) async {
    isLoading = true;
    error = null;
    notice = null;
    notifyListeners();
    try {
      final result = await _repository.createAccount(
        username: username,
        displayName: displayName,
        password: password,
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
    await _repository.signOut();
    session = null;
    error = null;
    notice = null;
    notifyListeners();
  }

  bool allows(String permission) => session?.allows(permission) ?? false;

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
