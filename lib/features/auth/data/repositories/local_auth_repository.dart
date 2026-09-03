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
  Future<bool> hasUsers() => _database.hasUsers();

  @override
  Future<AuthSession> signIn(String username, String password) async {
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
    return AuthSession(
      userId: user.id,
      displayName: user.displayName,
      isSuperuser: user.isSuperuser,
      permissions: (await _database.permissionsOf(user.id)).toSet(),
    );
  }

  Future<AccountCreationResult> createAccount({
    required String username,
    required String displayName,
    required String password,
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
    return AccountCreationResult(
      message: 'Conta administradora criada com sucesso.',
      session: AuthSession(
        userId: user.id,
        displayName: user.displayName,
        isSuperuser: user.isSuperuser,
        permissions: (await _database.permissionsOf(user.id)).toSet(),
      ),
    );
  }

  @override
  Future<void> signOut() async {}
}
