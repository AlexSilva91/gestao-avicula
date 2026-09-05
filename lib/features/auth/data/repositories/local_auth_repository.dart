import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/errors/app_failures.dart';
import '../../../../core/utils/password_hasher.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

class AccountCreationResult {
  const AccountCreationResult({this.session, required this.message});
  final AuthSession? session;
  final String message;
  bool get signedIn => session != null;
}

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._database);
  final AppDatabase _database;
  static const _rememberedUserIdKey = 'seleto.remembered_user_id';
  static const _rememberedUsernameKey = 'seleto.remembered_username';

  Future<bool> hasUsers() => _database.hasUsers();

  Future<AuthSession?> restoreRememberedSession() async {
    final preferences = await SharedPreferences.getInstance();
    final userId = preferences.getString(_rememberedUserIdKey);
    if (userId == null || userId.isEmpty) return null;
    final user = await _database.userById(userId);
    if (user == null || !user.isActive) {
      await _clearRememberedLogin(preferences);
      return null;
    }
    return _sessionFromUser(user);
  }

  Future<String?> rememberedUsername() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_rememberedUsernameKey);
  }

  @override
  Future<AuthSession> signIn(
    String username,
    String password, {
    bool rememberLogin = false,
  }) async {
    final normalizedUsername = username.trim().toLowerCase();
    final existing = await _database.userByUsername(normalizedUsername);
    if (existing == null) {
      throw const AuthenticationFailure(
        'Usuário não encontrado. Confira o nome digitado ou crie uma conta.',
      );
    }
    if (!existing.isActive) {
      throw const AuthenticationFailure(
        'Esta conta existe, mas ainda está inativa. Peça ao administrador para ativar seu acesso.',
      );
    }
    if (!PasswordHasher.verify(password, existing.passwordHash)) {
      throw const AuthenticationFailure('Senha incorreta para este usuário.');
    }
    final user = await _database.authenticate(normalizedUsername, password);
    if (user == null) {
      throw const AuthenticationFailure(
        'Não foi possível entrar. Revise usuário e senha.',
      );
    }
    final session = await _sessionFromUser(user);
    await _setRememberedLogin(user: user, rememberLogin: rememberLogin);
    return session;
  }

  Future<AccountCreationResult> createAccount({
    required String username,
    required String displayName,
    required String password,
    bool rememberLogin = false,
  }) async {
    final hadUsers = await _database.hasUsers();
    final user = await _database.createSelfServiceAccount(
      username: username,
      displayName: displayName,
      password: password,
    );
    if (hadUsers) {
      return const AccountCreationResult(
        message:
            'Conta criada, mas ainda não está ativa. Peça ao administrador para ativar seu usuário e liberar as permissões.',
      );
    }
    await _setRememberedLogin(user: user, rememberLogin: rememberLogin);
    return AccountCreationResult(
      message: 'Conta administradora criada com sucesso.',
      session: await _sessionFromUser(user),
    );
  }

  @override
  Future<void> signOut() async {
    final preferences = await SharedPreferences.getInstance();
    await _clearRememberedLogin(preferences);
  }

  Future<AuthSession> _sessionFromUser(User user) async => AuthSession(
    userId: user.id,
    displayName: user.displayName,
    isSuperuser: user.isSuperuser,
    permissions: (await _database.permissionsOf(user.id)).toSet(),
  );

  Future<void> _setRememberedLogin({
    required User user,
    required bool rememberLogin,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    if (!rememberLogin) {
      await _clearRememberedLogin(preferences);
      return;
    }
    await preferences.setString(_rememberedUserIdKey, user.id);
    await preferences.setString(_rememberedUsernameKey, user.username);
  }

  Future<void> _clearRememberedLogin(SharedPreferences preferences) async {
    await preferences.remove(_rememberedUserIdKey);
    await preferences.remove(_rememberedUsernameKey);
  }
}
